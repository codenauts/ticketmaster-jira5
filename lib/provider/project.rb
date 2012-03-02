module TicketMaster::Provider
  module Jira5
    class Project < TicketMaster::Provider::Base::Project
      def initialize(*object)
        if object.first and object.first.attrs.present?
          object = object.first
          @system_data = object.attrs
          hash = {
            :id => @system_data["id"].to_i, 
            :key => @system_data["key"],
            :name => @system_data["name"]
          }

          super(hash)
        end
      end

      def id
        self[:id].to_i
      end

      def copy(project)
        project.tickets.each do |ticket|
          copy_ticket = self.ticket!(:title => ticket.title, :description => ticket.description)
          ticket.comments.each do |comment|
            copy_ticket.comment!(:body => comment.body)
            sleep 1
          end
        end
      end
      
      def ticket!(*options)
        options[0].merge!(:project_id => id, :project_key => key) if options.first.is_a?(Hash)
        provider_parent(self.class)::Ticket.create(*options)
      end
      
      def components()
        [] #$jira.getComponents(key)
      end

      def self.find(*options)
        if options[0].first.is_a? Array
          self.find_all.select do |project| 
            project if options.first.any? { |id| project.id == id }
          end
        elsif options[0].first.is_a? Hash
          find_by_attributes(options[0].first)
        else
          self.find_all
        end
      end

      def self.find_by_attributes(attributes = {})
        search_by_attribute(self.find_all, attributes)
      end

      def self.find_all
        $jira.Project.all.map do |project| 
          Project.new project 
        end
      end

      def self.find_by_id(id)
        self.find_all.select { |project| project.id == id }.first
      end

    end
  end
end
