# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'parliament/open_search/version'

Gem::Specification.new do |spec|
  spec.name          = 'parliament-opensearch'
  spec.version       = Parliament::OpenSearch::VERSION
  spec.authors       = ['Rebecca Appleyard']
  spec.email         = ['rklappleyard@gmail.com']

  spec.summary       = %q{Parliamentary OpenSearch response builder }
  spec.description   = %q{Parliamentary OpenSearch response builder }
  spec.homepage      = 'http://github.com/ukparliament/parliament_opensearch'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'feedjira', '~> 2.1', '>= 2.1.2'
  spec.add_dependency 'parliament-ruby', '~> 0.7.2.pre'

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.47'
  spec.add_development_dependency 'simplecov', '~> 0.12'
  spec.add_development_dependency 'vcr', '~> 3.0'
  spec.add_development_dependency 'webmock', '~> 2.3'
end
