
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'paypal_event/version'

Gem::Specification.new do |spec|
  spec.name        = 'paypal_event'
  spec.version       = PaypalEvent::VERSION
  spec.authors       = ['Dean Lin']
  spec.email         = ['dean.lin@iscreen.com']

  spec.summary       = %q{Paypal webhook integration for Rails applications.}
  spec.description     = %q{Paypal webhook integration for Rails applications.}
  spec.homepage      = 'https://github.com/iscreen/paypal_event'


  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '>= 3.1'
  spec.add_dependency 'paypal-sdk-rest'

  spec.add_development_dependency 'rails', '>= 3.1'
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'webmock', '~> 1.9'
  spec.add_development_dependency 'coveralls'
end
