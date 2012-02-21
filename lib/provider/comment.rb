module TicketMaster::Provider
  module Jira
    # The comment class for ticketmaster-jira
    #
    # Do any mapping between Ticketmaster and your system's comment model here
    # versions of the ticket.
    #
    class Comment < TicketMaster::Provider::Base::Comment
      #API = Jira::Comment # The class to access the api's comments
      # declare needed overloaded methods here
      
      def initialize(*object)
        if object.first
          object = object.first
          unless object.is_a? Hash
            @system_data = {:client => object}
            hash = {:id => object.id, 
              :author => object.author,
              :body => object.body,
              :created_at => object.created,
              :updated_at => object.updated,
              :ticket_id => object.ticket_id,
              :project_id => object.project_id}
          else
            hash = object
          end
          super(hash)
        end
      end

      def self.find(ticket_id, *options)
        if options.first.empty?
          self.find_all(ticket_id)
        end
      end

      def self.find_all(ticket_id)
        begin 
          $jira.getComments("#{ticket_id}").map { |comment| self.new comment }
        rescue
          []
        end
      end
    end
  end
end
