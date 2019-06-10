
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "jar_gem/version"

Gem::Specification.new do |gem|
  gem.name          = "jar_gem"
  gem.version       = JarGem::VERSION
  gem.authors       = ["Masashi Morita"]
  gem.email         = ["masashi.morita@opentone.co.jp"]

  gem.summary       = "sample jar gem"
  gem.description   = "sample jar gem"
  gem.license       = "MIT"

  gem.files = Dir[ 'lib/**/*.rb' ]
  gem.files += Dir[ 'lib/*.jar' ]
  gem.files += Dir[ '*file' ]
  gem.files += Dir[ '*.gemspec' ]

  gem.platform = 'java'
  gem.require_paths = ["lib"]

  # jar dependencies
  # gem.requirements << "jar org.apache.poi, poi, 4.0.1"
  # gem.requirements << "jar org.apache.poi, poi-ooxml, 4.0.1"

  gem.add_runtime_dependency 'jar-dependencies', "~> 0.3.0"
  gem.add_development_dependency "bundler", "~> 1.17"
  gem.add_development_dependency "rake", "~> 10.0"
  gem.add_development_dependency "rspec", "~> 3.0"
end
