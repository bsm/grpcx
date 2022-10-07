Gem::Specification.new do |s|
  s.name          = 'grpcx'
  s.version       = '0.3.2'
  s.authors       = ['Black Square Media Ltd']
  s.email         = ['info@blacksquaremedia.com']
  s.summary       = %(gRPC extensions/helpers)
  s.description   = %()
  s.homepage      = 'https://github.com/bsm/grpcx'
  s.license       = 'MIT'

  s.files         = `git ls-files -z`.split("\x0").reject {|f| f.match(%r{^spec/}) }
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 2.7'

  s.add_dependency 'activesupport', '>= 5.0'
  s.add_dependency 'grpc', '>= 1.8.0'

  s.add_development_dependency 'activerecord'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rubocop-bsm'
  s.metadata['rubygems_mfa_required'] = 'true'
end
