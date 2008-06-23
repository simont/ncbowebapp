require File.dirname(__FILE__) + '/../spec_helper'

describe ServicesController do

  #Delete this example and add some real ones
  it "should use ServicesController" do
    controller.should be_an_instance_of(ServicesController)
  end
  
  it "should render intro"do
    get 'intro'
  end

  it "should assign resources and ontologies" do
    get 'intro'
    assigns[:resources]
    assigns[:ontologies]
  end
  
  it "should assign NCBO_URL" do
    get 'intro'
    assigns[:NCBO_URL]
  end

  it "should render the intro page" do
    get 'intro'
    response.should render_template(:intro)
  end


  it "should render geosearch" do
    get 'geosearch'
  end
  
  it "should render the geosearch page" do
     get 'geosearch'
     response.should render_template(:geosearch)
   end
  
  it "should respond to get_geo_datasets_from_ncbi" do
    
  end
  
end

