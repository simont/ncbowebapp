class OntologiesController < ApplicationController
  
  def list
    @ontologies = Ontology.find(:all)
    
  end
  
  def index
    @ontologies = Ontology.find(:all)
    redirect_to :action => 'list'
    
  end
  
  def reload_from_ncbo
    @ontologies = Ontology.update_from_ncbo
    redirect_to :action => 'list'
  end
  
end
