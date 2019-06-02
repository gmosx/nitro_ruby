class File

    def self.write(path, str)
        File.open(path, "w") { |f| f << str }
    end
    
end
