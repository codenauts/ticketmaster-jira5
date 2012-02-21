require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "TicketMaster::Provider::Jira::Ticket" do 
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
    Jira4R::JiraTool.stub!(:new).with(2, @url).and_return(@fj)
    @fj.stub!(:getProjectsNoSchemes).and_return([@project_jira, @project_jira])
    @fj.stub!(:getProjectById).and_return(@project_jira)
    @fj.stub!(:getIssuesFromJqlSearch).and_return([@ticket])
    @tm = TicketMaster.new(:jira, :username => 'testuser', :password => 'testuser', :url => @url)
    @project_tm = @tm.projects.first
    @klass = TicketMaster::Provider::Jira::Ticket
  end

  it "should be able to load all tickets"  do 
     @project_tm.tickets.should be_an_instance_of(Array)
     @project_tm.tickets.first.should be_an_instance_of(@klass)
  end

  it "should be able to load all tickets based on array of id's" do
    tickets = @project_tm.tickets([1])
    tickets.should be_an_instance_of(Array)
    tickets.first.should be_an_instance_of(@klass)
    tickets.first.id.should == 1
  end

  it "should be able to load a single ticket based on id" do 
    ticket = @project_tm.ticket(1)
    ticket.should be_an_instance_of(@klass)
    ticket.id.should == 1
  end

  it "should be able to load a single ticket based on attributes" do
    ticket = @project_tm.ticket(:id => 1)
    ticket.should be_an_instance_of(@klass)
    ticket.id.should == 1
  end

end
