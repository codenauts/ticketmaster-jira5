module TicketMaster::Provider
  module Jira
    # Ticket class for ticketmaster-jira
    #
    
    class Ticket < TicketMaster::Provider::Base::Ticket
      #API = Jira::Ticket # The class to access the api's tickets
      # declare needed overloaded methods here
      def initialize(*object)
        if object.first
          object = object.first
          @system_data = object.attrs
          hash = {
            :id => @system_data["id"].to_i, 
            :key => @system_data["key"],
            :title => @system_data["fields"]["summary"],
            #:status => @system_data["fields"]["status"]
            #:priority => @system_data["fields"]["priority"],
            #:resolution => @system_data["fields"]["resolution"],
            :created_at => @system_data["fields"]["created"],
            :updated_at => @system_data["fields"]["updated"],
            :description => @system_data["fields"]["description"],
            #:assignee => @system_data["fields"]["assignee"],
            #:requestor => @system_data["fields"]["reporter"]
          }
          
          super(hash)
        end
      end

      def id
        self[:id].to_i
      end

      def updated_at
        normalize_datetime(self[:updated_at])
      end

      def created_at
        normalize_datetime(self[:created_at])
      end

      def self.find_by_id(project_id, id)
        issue = $jira.Issue.find(id)
        if issue.attrs["key"].present?
          Ticket.new(issue)
        else
          nil
        end
      end

      def self.find_all_with_query(project_id, query)
        [] # TODO
      end

      def self.find_all(project_id)
        project = $jira.Project.find(project_id)
        project.issues.map do |ticket|
          self.new ticket
        end
      end

      def comments(*options)
        Comment.find(self.id, options)
      end

      def comment(*options)
        nil
      end
      
      def self.create(*options)
        attributes = options.first
        
        issue = Jira4R::V2::RemoteIssue.new
        issue.summary = attributes[:title]
        issue.description = attributes[:description]
        issue.project = attributes[:project_key]
        issue.priority = attributes[:priority] if attributes[:priority].present?
        
        if attributes[:components].present?
          components = Jira4R::V2::ArrayOf_tns1_RemoteComponent.new 
          attributes[:components].each do |id|
            component = Jira4R::V2::RemoteComponent.new(id)
            components.push(component)
          end
          issue.components = components
        end
        
        issue.type = "1"
        result = $jira.createIssue(issue)
        
        return nil if result.nil? or result.id.nil?
        return result
      end
      
      private
      def normalize_datetime(datetime)
        Time.mktime(datetime.year, datetime.month, datetime.day, datetime.hour, datetime.min, datetime.sec)
      end

   end

  end
end
