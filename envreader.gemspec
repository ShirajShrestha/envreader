Gem::Specification.new do |s|
  s.name = "envreader"
  s.version = "0.1.5"
  s.executables = ["envreader"]
  s.summary = "Reads all the .env variable"
  s.description = "Reads the keys of the env variable. Use envreader -h for help and check all commands."
  s.required_ruby_version = ">= 3.0.0"
  s.authors = ["Shiraj Shrestha"]
  s.license = "MIT"
  s.files = ["lib/envreader.rb", "bin/envreader","README.md"]
  s.homepage = "https://github.com/ShirajShrestha/envreader"
end