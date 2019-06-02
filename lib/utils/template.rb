require "xml"
require "xslt"
require "liquid"

# A template engine based on Liquid templates and XSLT.

module LiquidTemplateEngine

    # Two level cache:
    #
    # - Memory cache
    # - Disk cache (used in live cgi mode, maybe USELESS?)
    
    def get(template_path, scope)
        unless t = Web::Resource.template_cache[template_path]
            compiled = ".compiled/#{template_path}"

            if (!$DBG) and File.exist?(compiled)
                t = Marshal.load(File.read(compiled))
            else
                t = Template.parse(template_path, scope)
                FileUtils.mkdir_p(File.dirname(compiled))
                File.write(compiled, Marshal.dump(t))
            end
            
            Web::Resource.template_cache[template_path] = t unless $DBG
        end
        
        return t
    end

    def parse(template_path, scope)
        if xsl_path = scope.fetch("XSL", default_xsl_path(template_path))
            t = XML::Document.file("#{Template.root}#{template_path}")
            xsl = XML::Document.file("#{Template.root}#{xsl_path}")
            xsl = XSLT::Stylesheet.new(xsl)
            # t = XML::Parser.string(t).parse
            script_paths = process_script_paths(t.to_s, "#{Template.root}#{template_path}.inc.js")
            t.xinclude
            t = xsl.apply(t)
            t = process_scripts(t.to_s, script_paths)
            # XSLT gets fucked up with {{..}} inside attributes so we 
            # use ((..)) as an alias.
            t.gsub!(/\$\(/, "{{")
            t.gsub!(/\)\$/, "}}")
        else
            t = File.read("#{Template.root}#{template_path}")
            t = process_includes(t)
        end
        
        t = process_script_loader(t, scope)
=begin        
        t.gsub!(/<\?xml version="1.0" encoding="UTF-8" standalone="yes"\?>/, '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">')
=end
        t.gsub!(/<\?xml version="1.0" encoding="UTF-8" standalone="yes"\?>/, '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">')
        
        return Liquid::Template.parse(t)
    end

private

    # ...
    
    def default_xsl_path(template_path)
        xsl_path = "/default#{File.extname(template_path)}.xsl"

        if File.exist? "#{Template.root}#{xsl_path}"
            return xsl_path
        else
            return nil
        end
    end

    # Process static includes.
    #--
    # TODO: handle relative includes.
    #++
    
    def process_includes(str)
        return str.gsub(/<xi\:include href=["|'](.*?)["|'](.*) \/>/) do |match|
            fragment = File.read("#{Template.root}#{$1}")
            fragment.gsub!(/<\?xml.*\?>/, "")
            process_includes(fragment)
        end
    end    

    # Generate a list of potential script paths.

    def process_script_paths(template, template_path = nil)
        script_paths = [] 
        script_paths << template_path if template_path

        base = File.dirname(template_path)

        template.gsub(/<xi:include href=["|'](.*?)["|']/) { |m|
            path = "#{base}/#{$1}" 
            if File.exist? path
                fragment = File.read(path)
                script_paths.concat(process_script_paths(fragment, "#{path}.inc.js"))
            end
        } 

        return script_paths
    end

    # Process script_loader files.

    def process_script_loader(template, scope)
        loader = scope.fetch("script_loader", [])
        loader = loader.flatten.uniq.map { |f| f.inspect }.join(", ")
        return template.gsub(/\{\{SCRIPT_LOADER\}\}/, loader)
    end
         
    # Inline scripts.
    
    def process_scripts(template, script_paths)
        scripts = []

        script_paths.flatten.uniq.each { |sp|
            if File.exist? sp
                scripts << File.read(sp)
            end
        }

        return template.gsub(/\{\{SCRIPT\}\}/, scripts.join("\n"))
    end    

end

# The template engine.

class Template

    extend LiquidTemplateEngine
    
    setting :root, :value => "root"

end

