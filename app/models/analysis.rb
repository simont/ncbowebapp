class Analysis < ActiveRecord::Base
  has_many :annotations

  def filter_and_group_annotations(filter)

    filtered_list = Hash.new

    self.annotations.each do |annot|
      if filter == "tissue"
        if annot.ontology && Ontology.is_tissue?(annot.ontology.key)
          if filtered_list.has_key?(annot.name.downcase)
            filtered_list[annot.name.downcase][:ontology_list] << annot.ontology.key
          else
            filtered_list[annot.name.downcase] = {:count => annot.count,:ontology_list => [annot.ontology.key]}
          end
        end
      elsif filter == "disease"
         if annot.ontology && Ontology.is_disease?(annot.ontology.key)
            if filtered_list.has_key?(annot.name.downcase)
              filtered_list[annot.name.downcase][:ontology_list] << annot.ontology.key
            else
              filtered_list[annot.name.downcase] = {:count => annot.count,:ontology_list => [annot.ontology.key]}
            end
          end
      end
    end
    return filtered_list
  end

end
