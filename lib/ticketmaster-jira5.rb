require 'ticketmaster'
require 'jira'

%w{ jira ticket project }.each do |f|
  require File.dirname(__FILE__) + '/provider/' + f + '.rb';
end
