require File.dirname(__FILE__) + '/../spec_helper'

describe OntologiesController do

  before(:each) do
    @ontology = mock("ontology")
    
    @ontology.stub!(:name).and_return('National Cancer Institute Thesaurus, 2006_03D')
    @ontology.stub!(:key).and_return('NCI')
    # Ontology.stub!(:new).and_return(@ontology)
    @ontologies = [@ontology]
    Ontology.stub!(:find).and_return(@ontologies)
    get 'index'
  end

  it "should render list" do
    response.should redirect_to(:action => 'list')
  end
  
  it "should render list and assign an array of ontology objects" do
    assigns[:ontologies].should equal(@ontologies)
  end
  
  
  describe OntologiesController do
    
    before(:each) do
      @ontologies = [@ontology]
      
      # Ontology.stub!(:get_all_from_ncbo).and_return(@ontologies)
      Ontology.stub!(:find).and_return(@ontologies)
      Ontology.stub!(:update_from_ncbo).and_return(@ontologies)
      get 'reload_from_ncbo'
    end
    
    it "should have a get_all_from_ncbo method" do
      response.should be_redirect
    end
    
    it "should render list" do
      response.should redirect_to(:action => 'list')
    end
    
    it "should render list and assign an array of ontology objects" do
      assigns[:ontologies].should equal(@ontologies)
    end

   
  end
  
end
