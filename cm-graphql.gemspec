Gem::Specification.new do |spec|
  spec.name        = 'cm-graphql'
  spec.version     = '0.0.1'
  spec.date        = '2022-09-14'
  spec.summary     = "A gem to setup grapqhl basics like pagination, file upload"
  spec.description = "A gem to setup grapqhl basics like pagination, file upload"
  spec.authors     = ["Anbazhagan Palani"]
  spec.email       = 'anbu@commutatus.com'
  spec.homepage    =
    'https://github.com/commutatus/template-paging-api'
  spec.license       = 'MIT'

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'graphql', '~> 1.13.1'
  spec.add_runtime_dependency 'graphql-errors', '~> 0.4.0'
  spec.add_runtime_dependency 'graphql-rails_logger', '~> 1.2.3'
  spec.add_runtime_dependency 'graphiql-rails', '~> 1.8.0'
  spec.add_runtime_dependency 'kaminari', '~> 1.2.2'
end