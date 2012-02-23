require 'ticketmaster'
require 'jira-ruby'

%w{ jira ticket project }.each do |f|
  require File.dirname(__FILE__) + '/provider/' + f + '.rb';
end
