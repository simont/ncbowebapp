class Ontology < ActiveRecord::Base
  
  has_many :annotations
  
  # New v1.1 REST URL
  # http://ncbolabs-dev2.stanford.edu:8080/OBS_v1/obs/ontologies
  NCBO_URL = 'http://ncbolabs-dev2.stanford.edu:8080/Ontrez_v1_API/'
  NCBO_REST_URL = 'http://ncbolabs-dev2.stanford.edu:8080/OBA_v1_rest/'
  
  # TISSUE_LIST = ['Mouse adult gross anatomy','Basic Vertebrate Anatomy','Human developmental anatomy, timed version','Cell type']
  # DISEASE_LIST = ['MSH','NCI','Human disease']
  
  FILTER_LIST = {
    'TISSUE_LIST' => ['Mouse adult gross anatomy','Basic Vertebrate Anatomy','Human developmental anatomy, timed version','Cell type'],
    'DISEASE_LIST' => ['MSH','NCI','Human disease']
    }
  
  def self.get_filter_list_ontologies(filter)
      return FILTER_LIST[filter.upcase + "_LIST"]
  end
  
  def self.is_tissue?(ontology_key)
    if FILTER_LIST['TISSUE_LIST'].include?(ontology_key)
      true
    else
      false
    end
  end
  
  def self.is_disease?(ontology_key)
    if FILTER_LIST['DISEASE_LIST'].include?(ontology_key)
      true
    else
      false
    end
  end
  
  def self.get_ncbo_xml(arg_map=[].freeze)

    args = arg_map.join('/')
    # $LOG.warn("Args: #{args}")
    doc = create_rexml_from_ws(NCBO_URL,args)
    return doc
  end
  
  def self.create_rexml_from_ws(url,args)
    the_url = url + args
    begin
      doc = REXML::Document.new(open(the_url).read)
    rescue
      # return nil if things go wrong.
      return nil
    end
    return doc
  end
  
  # Alternative version that uses a newer REST URL
  # http://ncbolabs-dev2.stanford.edu:8080/OBA_v1_rest/
  
  def self.get_ncbo_xml_rest(arg_map=[].freeze)
    args = arg_map.join('/')
    doc = create_rexml_from_ws(NCBO_REST_URL,args)
    return doc
  end
  
  def self.update_from_ncbo
    # TODO Write method to parse Ontology XML format into sensible data
    # and then return new ontology objects that can be saved if new
  end
  
end
