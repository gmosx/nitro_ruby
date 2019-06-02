#!/usr/bin/env ruby

# Run all specs.

Dir.glob(File.join("spec", "**", "*.rb")).each { |f|
    unless "spec/run.rb" == f
        unless system("spec #{f} --format specdoc")
            puts "\n----"
            puts "ERROR IN SPEC, PLEASE FIX IT!"
            exit(-1)
        end
    end
}
puts "\n----"
puts "ALL SPECS PASSED!"
    
