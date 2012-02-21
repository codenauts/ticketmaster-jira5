require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "TicketMaster::Provider::Jira::Comment" do
  before(:each) do
    @url = "some_url"
    @fj = FakeJiraTool.new
    @project_jira = Struct.new(:id, :name, :description).new(1, 'project', 'project description')
    @ticket = Struct.new(:id, 
                         :status, 
                         :priority, 
                         :summary, 
                         :resolution, 
                         :created, 
                         :updated, 
                         :description, :assignee, :reporter).new(1,'open','high', 'ticket 1', 'none', Time.now, Time.now, 'description', 'myself', 'yourself')
    @comment = Struct.new(:id, :author, :body, :created, :updated, :ticket_id, :project_id).new(1,
                                                                                                      'myself',
                                                                                                      'body',
                                                                                                      Time.now,
                                                                                                      Time.now,
                                                                                                      1,
                                                                                                      1)
    Jira4R::JiraTool.stub!(:new).with(2, @url).and_return(@fj)
    @fj.stub!(:getProjectsNoSchemes).and_return([@project_jira, @project_jira])
    @fj.stub!(:getProjectById).and_return(@project_jira)
    @fj.stub!(:getIssuesFromJqlSearch).and_return([@ticket])
    @fj.stub!(:getComments).and_return([@comment])
    @tm = TicketMaster.new(:jira, :username => 'testuser', :password => 'testuser', :url => @url)
    @ticket = @tm.projects.first.tickets.first
    @klass = TicketMaster::Provider::Jira::Comment
  end

  it "should be able to load all comments" do 
    @ticket.comments.should be_an_instance_of(Array)
    @ticket.comments.first.should be_an_instance_of(@klass)
  end

  it "should be able to create a comment"
end
