# frozen_string_literal: true

require "optparse"
require "set"

module EnvReader
  class Error < StandardError; end

  class << self
     # ANSI escape codes for coloring
     RESET = "\e[0m"
     GREEN = "\e[32m"
     RED = "\e[31m"
     YELLOW = "\e[33m"

    # Find and list all the keys used in the project
    def read_keys(directory = Dir.pwd, extensions: ["rb", "erb"])
      all_keys = scan_files(directory, extensions)
                 .flat_map { |file| extract_keys_from_file(file) }
                 .uniq

      puts "#{GREEN}Environment keys found:#{RESET}"
      all_keys.each { |key| puts "#{GREEN} - #{key}#{RESET}" }
      all_keys
    end

    # Find all the used environment keys in the project
    def find_keys(directory = Dir.pwd, extensions: ["rb", "erb"])
      usage = scan_files(directory, extensions)
              .map { |file| [file, extract_keys_from_file(file)] }
              .to_h
              .reject { |_, keys| keys.empty? }

      output_key_usage(usage)
    end

    # Validating environment keys
    def validate_keys(keys, custom_optional_keys = [])
      invalid_keys = keys.reject do |key|
        ENV[key].to_s.strip != "" || optional_keys(custom_optional_keys).include?(key)
      end

      if invalid_keys.empty?
        puts "#{GREEN}All environment keys are valid!#{RESET}"
      else
        puts "#{RED}Invalid environment keys:#{RESET}"
        invalid_keys.each { |key| puts "#{RED} - #{key}#{RESET}" }
      end
    end

    # Define default optional keys
    def optional_keys(custom_keys = [])
      # Add these if you don't want to see them as invalid 
      # %w[CI PIDFILE RAILS_ENV RAILS_MASTER_KEY BUNDLE_GEMFILE HOME LOG_LEVEL DATABASE_URL SECRET_KEY_BASE] + custom_keys
      %w[BUNDLE_GEMFILE] + custom_keys
    end

    # CLI interface for the program
    def cli
      options = {}
      OptionParser.new do |opts|
        opts.banner = "Usage: env_reader [options]"

        opts.on("-f", "--find-keys [DIRECTORY]", "Find used keys in a directory (default: current project)") do |dir|
          options[:find_keys] = dir || Dir.pwd
        end

        opts.on("-r", "--read-keys [DIRECTORY]", "Read and list all keys used in a directory (default: current project)") do |dir|
          options[:read_keys] = dir || Dir.pwd
        end

        opts.on("-v", "--validate-keys", "Validate the environment keys (check if they have values)") do
          options[:validate_keys] = true
        end

        opts.on("-e", "--extensions x,y,z", Array, "File extensions to scan (default: rb, erb)") do |ext|
          options[:extensions] = ext
        end

        opts.on("-h", "--help", "Prints this help") do
          puts opts
          exit
        end
      end.parse!(ARGV)

      if options[:read_keys]
        directory = options[:read_keys]
        validate_directory(directory)
        extensions = options[:extensions] || ["rb", "erb"]
        puts "#{YELLOW}Reading environment keys from directory: #{directory}#{RESET}"
        puts "#{YELLOW}File extensions: #{extensions.join(', ')}#{RESET}"
        read_keys(directory, extensions: extensions)
      elsif options[:find_keys]
        directory = options[:find_keys]
        validate_directory(directory)
        extensions = options[:extensions] || ["rb", "erb"]
        puts "#{YELLOW}Scanning directory: #{directory}#{RESET}"
        puts "#{YELLOW}File extensions: #{extensions.join(', ')}#{RESET}"
        find_keys(directory, extensions: extensions)
      elsif options[:validate_keys]
        directory = options[:read_keys] || Dir.pwd
        validate_directory(directory)
        extensions = options[:extensions] || ["rb", "erb"]
        puts "#{YELLOW}Validating environment keys in directory: #{directory}#{RESET}"
        all_keys = read_keys(directory, extensions: extensions)
        validate_keys(all_keys, options[:optional_keys] || [])
      else
        puts "#{RED}Invalid command. Use --help for usage.#{RESET}"
      end
    end

    private

    # Validate if a directory exists
    def validate_directory(directory)
      unless Dir.exist?(directory)
        puts "#{RED}Error: Directory '#{directory}' does not exist.#{RESET}"
        exit(1)
      end
    end

    # Scan files with specific extensions in the directory
    def scan_files(directory, extensions)
      Dir.glob(File.join(directory, "**", "*.{#{extensions.join(",")}}"))
         .select { |file| File.file?(file) }
    end

    # Extract environment keys from a file
    def extract_keys_from_file(file_path)
      used_keys = []

      File.foreach(file_path) do |line|
        # Check for any ENV["KEY"] or ENV.fetch("KEY") pattern
        line.scan(/ENV\[['"]([^'"]+)['"]\]/).each do |match|
          used_keys << match.first
        end
        line.scan(/ENV\.fetch\(['"]([^'"]+)['"]\)/).each do |match|
          used_keys << match.first
        end
      end

      used_keys.uniq
    end

    # Output environment key usage
    def output_key_usage(usage)
      if usage.empty?
        puts "#{YELLOW}No environment keys found in the scanned files.#{RESET}"
        return
      end

      puts "#{GREEN}Environment Key Usage:#{RESET}"
      usage.each do |file, keys|
        puts "\n#{YELLOW}#{file}:#{RESET}"
        keys.each { |key| puts "#{GREEN} - #{key}#{RESET}" }
      end
    end
  end
end
