module TicketMaster::Provider
  module Jira5
    class Ticket < TicketMaster::Provider::Base::Ticket
      def initialize(*object)
        if object.first
          object = object.first
          @system_data = object.attrs
          @fields = @system_data["fields"] || @system_data
          hash = {
            :id => @system_data["id"].to_i, 
            :key => @system_data["key"],
            :title => @fields["summary"],
            #:status => @system_data["fields"]["status"]
            #:priority => @system_data["fields"]["priority"],
            #:resolution => @system_data["fields"]["resolution"],
            :created_at => @fields["created"],
            :updated_at => @fields["updated"],
            :description => @fields["description"],
            #:assignee => @system_data["fields"]["assignee"],
            #:requestor => @system_data["fields"]["reporter"]
          }
          
          super(hash)
        end
      end

      def id
        self[:id].to_i
      end

      def key
        self[:key].to_s
      end

      def title
        self[:summary].to_s
      end

      def description
        self[:description].to_s
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

        fields = {}
        fields["summary"] = attributes[:title]
        fields["description"] = attributes[:description] if attributes[:description].present?
        fields["project"] = { :id => attributes[:project_id] }
        fields["priority"] = { :id => attributes[:priority] } if attributes[:priority].present?
        fields["components"] = [ { :name => attributes[:component] } ] if attributes[:component].present?
        fields["versions"] = [ { :name => attributes[:version] } ] if attributes[:version].present?

        if attributes[:issue_type_id].present?
          fields["issuetype"] = { :id => attributes[:issue_type_id] }
        else
          begin
            issuetypes = $jira.Issuetype.all
            issuetype = issuetypes.select { |it| it.name == "Bug"}.last
            fields["issuetype"] = { :id => issuetype.id } if issuetype.present?
          rescue
          ensure
            fields["issuetype"] ||= { :id => "1" }
          end
        end

        project = $jira.Project.find(attributes[:project_id])
        issue = $jira.Issue.build
        result = issue.save({ :fields => fields })
        
        if result && issue.attrs["errors"].blank?
          return self.new issue 
        elsif issue.attrs["errors"].present?
          message = ""
          issue.attrs["errors"].each do |k, v|
            message << "Field: #{k.to_s}\n"
            message << "Message: #{v.to_s}\n\n"
          end
          raise Exception.new(message)
        else
          return nil
        end
      end

      def add_remote_link(url, title, icon_url, icon_title, attrs = {})
        link = JIRA::Resource::Remotelink.new($jira, :issue_id => self.id.to_s)
        link.save({ 
          :object => {
            :url => url, 
            :title => title, 
            :icon => {
              "url16x16" => icon_url, 
              "title" => icon_title
            }
          }
        }.merge(attrs))
      end
      
      private

      def normalize_datetime(datetime)
        Time.mktime(datetime.year, datetime.month, datetime.day, datetime.hour, datetime.min, datetime.sec)
      end

   end

  end
end
