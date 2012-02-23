$:.push File.expand_path("../lib", __FILE__)
require 'lib/jira/version'

Gem::Specification.new do |s|
  s.name          = 'ticketmaster-jira5'
  s.version       = TicketMaster::Jira::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = ["Charles Lowell", "Rafael George", "Thomas Dohmke"]
  s.email         = ["cowboyd@thefrontside.net", "rafael@hybridgroup.com", "thomas@dohmke.de"]
  s.homepage      = 'http://github.com/codenauts/ticketmaster-jira5'
  s.summary       = %q{TicketMaster binding for JIRA 5 REST API}
  s.description   = %q{Interact with Atlassian JIRA ticketing system from Ruby}
  s.add_dependency  'ticketmaster'
  s.add_dependency  'jira-ruby'
  s.add_development_dependency  'rspec', '>=2.0.0'
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]
end
