module TicketMaster::Provider
  module Jira5
    include TicketMaster::Provider::Base
    def self.new(auth = {})
      TicketMaster.new(:jira5, auth)
    end
    
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


