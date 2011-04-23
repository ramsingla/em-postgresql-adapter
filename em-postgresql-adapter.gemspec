Gem::Specification.new do |s|
  s.name     = "em-postgresql-adapter"
  s.version  = "0.1"
  s.date     = "2011-04-23"
  s.summary  = "PostgreSQL fiber-based ActiveRecord connection adapter for Ruby 1.9"
  s.email    = "ruben@leftbee.net"
  s.homepage = "http://github.com/leftbee/em-postgresql-adapter"
  s.has_rdoc = false
  s.authors  = ["Ruben Nine"]
  s.files    = [
    "em-postgresql-adapter.gemspec",
    "README.md",
    "lib/active_record/connection_adapters/em_postgresql_adapter.rb",
    "lib/fibered_postgresql_connection.rb"
  ]
  s.add_dependency('pg', '>= 0.8.0')
end
