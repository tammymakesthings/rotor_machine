
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rotor_machine/version'

Gem::Specification.new do |spec|
  spec.name          = 'rotor_machine'
  spec.version       = RotorMachine::VERSION
  spec.authors       = ['Tammy Cravit']
  spec.email         = ['tammycravit@me.com']
  spec.cert_chain    = ['certs/tammycravit.pem']
  spec.signing_key   = File.expand_path("~/.ssh/gem-private_key.pem") if $0 =~ /gem\z/

  spec.summary       = %q{Simple Enigma-like rotor machine in Ruby}
  spec.homepage      = 'https://github.com/tammycravit/rotor_machine'
  spec.license       = 'Apache-2.0'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'tcravit_ruby_lib'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'

  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'guard-bundler'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'simplecov-erb'
end
