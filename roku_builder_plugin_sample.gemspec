# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "roku_builder_plugin_sample/version"

Gem::Specification.new do |spec|
  spec.name          = "roku_builder_plugin_sample"
  spec.version       = RokuBuilderPluginSample::VERSION
  spec.authors       = ["Charles Greene"]
  spec.email         = ["charles.greene@redspace.com"]

  spec.summary       = %q{Sample RokuBuilder Plugin}
  spec.description   = %q{Sample plugin for RokuBuilder to be used as a template}
  spec.homepage      = ""

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "roku_builder", "~> 4.4"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
end
