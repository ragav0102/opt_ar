
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'opt_ar/version'

Gem::Specification.new do |spec|
  spec.name          = 'opt_ar'
  spec.version       = OptAR::VERSION
  spec.authors       = ['ragav0102']
  spec.email         = ['ragavh123@gmail.com']

  spec.summary       = 'Generates memory-optimal immutable ActiveRecord dupes'
  spec.description   = 'Generates memory-optimal immutable ActiveRecord dupes '\
                       'that are easily serializable and behaves much like '\
                       'them. Define required attributes before-hand and use'\
                       ' them just as you would on an AR, for better memory '\
                       'optimization.\n Ideally, suitable in place of caching '\
                       'AR objects with cache stores like Memcached, where '\
                       'serialization and de-serialization are memory-hungry'
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split('\x0').reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 10.0'
end
