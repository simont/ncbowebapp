class Annotation < ActiveRecord::Base
  
  belongs_to :ontology
  belongs_to :analysis
end
