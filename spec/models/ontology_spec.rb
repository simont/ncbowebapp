require File.dirname(__FILE__) + '/../spec_helper'
require 'rexml/document'

describe Ontology do
  
  fixtures :ontologies

  it "should have a non empty collection of ontologies" do
   Ontology.find(:all).should_not be_empty
  end
  
  it "should contain two ontology records" do
    Ontology.should have(2).record
  end
  
  it "should contain the ontology with the MMX key" do
    ont = Ontology.find_by_key('MMX')
    ont.should eql(ontologies(:mmx))
  end
  
  
  describe Ontology do
    before(:each) do
      @ontology = Ontology.new(:name => "test ontology",:key => "TEST",:description => "Test description")
    end
    it "should be valid" do
      @ontology.should be_valid
    end
    
    it "should have no errors after save" do
      @ontology.save.should be_true
      @ontology.errors.should be_empty
    end
  end

  describe Ontology do
    before(:each) do
      @ontology = Ontology.new

      @ontology_xml = <<eoxml
<list>
<ontrez.ontology.Ontology>
<ontologyKey>SNOMEDCT</ontologyKey>
<ontologyName>SNOMED Clinical Terms, 2007_01_31</ontologyName>
<ontologyDescription>NoDescription</ontologyDescription>
</ontrez.ontology.Ontology>
<ontrez.ontology.Ontology>
<ontologyKey>NCI</ontologyKey>
<ontologyName>National Cancer Institute Thesaurus, 2006_03D</ontologyName>
<ontologyDescription>NoDescription</ontologyDescription>
</ontrez.ontology.Ontology>
</list>
eoxml
    @ontology_xml_doc = REXML::Document.new(@ontology_xml)
    @test_ontology_array = ['SNOMEDCT','NCI']
    Ontology.stub!(:get_ontology_xml_from_ncbo).and_return(@ontology_xml_doc)
    end
    
    # TODO Check to make sure these methods are in sync with model - seems to be diverging
    
    it "should call the NCBO web service to get ontology XML" do
      xml = Ontology.get_ontology_xml_from_ncbo
      xml.should equal(@ontology_xml_doc)
    end
    
    it "should have a method to parse ontology XML and return new Ontology objects" do
      # new_ontologies = Ontology.parse_ncbo_xml(Ontology.get_ontology_xml_from_ncbo)
    end
    
    it "should create two ontology records from the XML" do
      xml = Ontology.get_ontology_xml_from_ncbo
      test_array = Array.new
      xml.elements.each('//ontrez.ontology.Ontology') do |f|
        test_array << f.elements[1][0]
        o = Ontology.new(
          :key => f.elements[1][0],
          :name => f.elements[2][0],
          :description => f.elements[3][0]
        )
        o.save
      end
      test_array.size.should equal(2)
      Ontology.should have(4).records
      
    end
    
    it "should fail gracefully if the ncbo connection fails " do
      
    end
    
  end
  
  describe Ontology do
    it "should get nil if NCBO web service doesnt work" do
      xml = Ontology.create_rexml_from_ws("http://test.testing.ord",'/garbage')
      xml.should be_nil
    end
    
    it "should get something more sensible if its valid" do
      xml = Ontology.create_rexml_from_ws("http://ncbolabs-dev2.stanford.edu:8080/Ontrez_v1_API/","ontologies")
      xml.should_not be_nil
    end
    
    it "should also work if we call the higher method" do
      xml = Ontology.get_ncbo_xml(['ontologies'])
      xml.should_not be_nil
    end
    
    it "should be able to update from the NCBO" do
      ontologies = Ontology.update_from_ncbo
    end
  end
  
end
