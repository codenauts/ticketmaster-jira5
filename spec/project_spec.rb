require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "TicketMaster::Provider::Jira::Project" do 
  before(:each) do
    @url = "some_url"
    @fj = FakeJiraTool.new
    @project = Struct.new(:id, :name, :description).new(1, 
                                                        'project', 
                                                        'project description')
    Jira4R::JiraTool.stub!(:new).with(2, @url).and_return(@fj)
    @fj.stub!(:getProjectsNoSchemes).and_return([@project, @project])
    @fj.stub!(:getProjectByKey).and_return(@project)
    @tm = TicketMaster.new(:jira, :username => 'testuser', :password => 'testuser', :url => @url)
    @klass = TicketMaster::Provider::Jira::Project
  end

  it "should be able to load all projects" do
    @tm.projects.should be_an_instance_of(Array)
    @tm.projects.first.should be_an_instance_of(@klass)
  end

  it "should be able to load all projects based on an array of id's" do 
    @tm.projects([1]).should be_an_instance_of(Array)
    @tm.projects.first.should be_an_instance_of(@klass)
    @tm.projects.first.id.should == 1
  end

  it "should be load all projects based on attributes" do 
    projects = @tm.projects(:id => 1)
    projects.should be_an_instance_of(Array)
    projects.first.should be_an_instance_of(@klass)
    projects.first.id.should == 1
  end

  it "should be able to load a single project based on id" do
    project = @tm.project(1)
    project.should be_an_instance_of(@klass)
    project.name.should == 'project'
  end

  it "should be able to load a single project by attributes" do
    project = @tm.project(:id => 1)
    project.should be_an_instance_of(@klass)
    project.name.should == 'project'
  end
end
