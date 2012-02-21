module TicketMaster::Provider
  # This is the Jira Provider for ticketmaster
  module Jira
    include TicketMaster::Provider::Base
    # This is for cases when you want to instantiate using TicketMaster::Provider::Jira.new(auth)
    def self.new(auth = {})
      TicketMaster.new(:jira, auth)
    end
    
    # Providers must define an authorize method. This is used to initialize and set authentication
    # parameters to access the API
    def authorize(auth = {})
      @authentication ||= TicketMaster::Authenticator.new(auth)
      $jira = JIRA::Client.new({ :site => @authentication.url, :username => @authentication.username, :password => @authentication.password })
    end

    def project(*options)
      if options.first.is_a? String
        options[0] = options[0].to_i
      end
      if options.first.is_a? Fixnum
        Project.find_by_id(options.first)
      elsif options.first.is_a? Hash
        Project.find_by_attributes(options.first).first
      end
    end

    def projects(*options)
      Project.find(options)
    end

    def jira
      $jira
    end

    def valid?
      true
    end
  end
end


