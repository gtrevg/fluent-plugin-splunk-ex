# encoding: utf-8

Gem::Specification.new do |gem|
  gem.name         = "fluent-plugin-splunk-ex"
  gem.version      = "1.0.3"

  gem.authors      = ["Trevor Gattis"]
  gem.email        = "github@trevorgattis.com"
  gem.description  = "Splunk output plugin for Fluent event collector.  It supports reconnecting on socket failure as well as exporting the data as json or in key/value pairs"
  gem.homepage     = "https://github.com/gtrevg/fluent-plugin-splunk-ex"
  gem.summary      = gem.description
  gem.license      = "APLv2"
  gem.has_rdoc = false

  gem.files = `git ls-files`.split("\n")
  gem.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ['lib']

  gem.add_dependency "fluentd", "~> 0.12.22"
  gem.add_runtime_dependency "json"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "pry"
  gem.add_development_dependency "pry-nav"
end

