Gem::Specification.new do |s|
  s.name          = 'grpcx'
  s.version       = '0.0.2'
  s.authors       = ['Black Square Media Ltd']
  s.email         = ['info@blacksquaremedia.com']
  s.summary       = %(gRPC extensions/helpers)
  s.description   = %()
  s.homepage      = 'https://bitbucket.org/bsm/grpcx'
  s.license       = 'MIT'

  s.files         = `git ls-files -z`.split("\x0").reject {|f| f.match(%r{^spec/}) }
  s.test_files    = `git ls-files -z -- spec/*`.split("\x0")
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 2.2'

  s.add_dependency 'grpc' # TODO: investigate which version is compatible (like when interceptors were introduced)

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rubocop'
end