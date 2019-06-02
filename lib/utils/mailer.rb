require "tmail"
require "liquid"

require "stdx/logger"
require "stdx/net/smtp"

require "utils/settings"

# Example:
#
# require "utils/mailer"
# 
# Mailer.template_root = "mails"
# Mailer.delivery_method = "dump"
# Mailer.send(
#   "hello.html", 
#   "from" => "gmosx@nitroproject.org", "to" => "stella@gmail.com", 
#   "subject" => "This is a test", "name" => "George"
# )

class Mailer

    setting :delivery_method, :value => "smtp"
    
    setting :template_root, :value => "root/mails"
    
    setting :from, :value => "postmaster@nitroproject.org"

    setting :smtp_server, :value => "smtp.gmail.com"

    setting :smtp_port, :value => 587

    setting :smtp_domain, :value => "localhost.localhost"
    
    setting :smtp_username, :value => ""
    
    setting :smtp_password, :value => ""
    
    class << self
        
        # Send a mail using the given template.
        #
        # Example:
        #
        #   Mailer.send("signup.html", 
        #       "subject" => "Hello there", 
        #       "from" => "info@gmosx.com", 
        #       "to" => user.email, "user" => user, 
        #       "karma" => user.karma
        #   )
        
        def send(template_path, scope)
            Settings.configure(self) # to be on the safe side.

            mail = TMail::Mail.new
            mail.date = Time.now
            mail.from = scope.fetch("from", Mailer.from)
            mail.to = scope["to"]
            mail.cc = scope["cc"]
            mail.bcc = scope["bcc"]
            mail.subject = scope["subject"]
            mail.mime_version = "1.0"
            mail.body = get_template(template_path).render(scope)
            if File.extname(template_path) == ".html"
                mail.set_content_type("text", "html")
            else
                mail.set_content_type("text", "plain")
            end

            deliver(mail)
        rescue Object => ex
            error "Error while sending mail to #{scope['to']}\n#{ex.to_s}"
            # error ex.backtrace()
        end
        
        private

        def deliver(mail)
            case(Mailer.delivery_method) 
            when "smtp"
                Net::SMTP.start(
                    Mailer.smtp_server, 
                    Mailer.smtp_port, 
                    Mailer.smtp_domain, 
                    Mailer.smtp_username, 
                    Mailer.smtp_password, 
                    "plain" 
                    # FIXME: add cc, bcc, investigate end of file error.
                ) { |smtp| smtp.send_message(mail.encoded, mail.from, mail.to) }
            else # "dump"
                info "Delivering mail:\n#{mail.encoded}"
            end
        end

        def get_template(template_path)
            t = File.read(File.join(File.join(Mailer.template_root, template_path)))
            return Liquid::Template.parse(t)
        end

    end # self

end    

