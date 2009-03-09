class ServicesController < ApplicationController

  def intro

    @resources = Ontology.get_ncbo_xml(['resources'])
    @ontologies = Ontology.get_ncbo_xml(['ontologies'])
    @NCBO_URL = Ontology::NCBO_URL
  end

  def geo_term_search
    if request.post?
      @term = params[:term]
      
      @output = "Searching GEO for datasets matching #{@term}</br>"
      @analysis = Analysis.new(:start_time => Time.now(),:search_string => @term, :geo_filter_option => 'term_search_at_ncbo')
      @analysis.save

      annotation_id_hash = Hash.new
      
      # http://ncbolabs-dev2.stanford.edu:8080/Ontrez_v1_API/result/cui/C0020538/from/0/number/1000/resource/GEO
      datasets = Ontology.get_ncbo_xml(['result','cui',@term,'from','0','number','1000','resource','GEO'])
      gds_list = Array.new
      
      datasets.elements.each('//elementLocalID') do |gds|
        @output << "Found #{gds.text}<br>"
        gds_list << gds.text
      end
      $LOG.warn("Term search GDS array: #{gds_list.join(', ')}")
      # asdfa
      
      # record the number of matching datasets at GEO
      Analysis.update(@analysis.id, {:matching_dataset_count => gds_list.size})
      
      gds_list.each do |gds_id|
        @output << "Getting NCBO annotations for GEO GDS#{gds_id}<br>"
        annotations = Ontology.get_ncbo_xml(['resource','GEO','element',gds_id])
        # Currently gets all annotations, could limit to those in summary and title
        # and ignore the closure annotations to get things that were more specific
        # TODO Put a filter in for non-closure annotations to see if that helps specificity
        annotations.elements.each("//ontrez.annotation.Annotation[itemKey!='closure']/termID") do |f|
          annot = Annotation.find_by_term_key_and_analysis_id(f.text, @analysis.id)
          if annot == nil
            annot = Annotation.new(:term_key => f.text, :count => 1, :gene_symbol => @gene_symbol)

            termInfo = Ontology.get_ncbo_xml(['dictionary','cui',f.text])
            puts "tedt: #{f.text}"
            unless termInfo.elements['//string'] == nil
              puts "FOUND ONE! Terminfo: #{termInfo}"
              annot.name = termInfo.elements['//string'][0].to_s
            end

            # Find ontology match
            ontologies = Ontology.get_ncbo_xml_rest(['rest','ontologies',f.text])
            if ontologies != nil
              ontology_key = ontologies.elements["//ontologyID"].to_a[0].to_s
              ontology = Ontology.find_by_key(ontology_key)
              if ontology != nil
                annot.ontology = ontology
              else
                ontology = Ontology.new(:key => ontology_key)
                ontology.save
                annot.ontology = ontology
              end
            else
              puts "no matching ontology term.."
            end

          else
            annot.count += 1
          end
          annot.analysis = @analysis
          annot.save
        end
      end
      Analysis.update(@analysis.id, {:end_time => Time.now()})
      # @analysis.end_time = Time.now()

    end
  end

  def get_geo_datasets_from_ncbi(gene_symbol, options)
    ncbi_search_url = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=geo&term=#{gene_symbol}[All%20Fields]%20AND%20%22value%20subset%20effect%22[Flag%20Type]&retmax=5000&usehistory=y"

    if options == "find_all"
      ncbi_search_url = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=geo&term=#{gene_symbol}[All%20Fields]&retmax=5000&usehistory=y"
    elsif options == "find_top_95"
      ncbi_search_url = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=geo&term=#{gene_symbol}[All%20Fields]%20AND%2096%3A100[Max%20Value%20Rank]&retmax=5000&usehistory=y"
    end
    
    ncbi_search_results = REXML::Document.new(open(ncbi_search_url).read)

    # Need the queryKey and WebEnv from these results
    queryKey = ncbi_search_results.elements['//QueryKey'][0]

    webEnv = ncbi_search_results.elements['//WebEnv'][0]

    # Now go back to NCBI to get the summary data for the IDs in the query
    ncbi_fetch_url = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=gds&mode=text&report=docsum&query_key=#{queryKey}&WebEnv=#{webEnv}"
    ncbi_fetch_results = open(ncbi_fetch_url).read

    # now have to run through the fetch results looking for all the GDS\d+

    gds_list = ncbi_fetch_results.scan(/GDS(\w+)/)
  end

  def geosearch

    if request.post?
      @gene_symbol = params[:symbol]
      @geo_filter_options = params[:geo_search_options] || 'find_significant'
      
      @output = "Searching GEO for #{@gene_symbol}</br>"
      @analysis = Analysis.new(:start_time => Time.now(),:search_string => @gene_symbol, :geo_filter_option => @geo_filter_options)
      @analysis.save

      annotation_id_hash = Hash.new
      gds_list = get_geo_datasets_from_ncbi(@gene_symbol, @geo_filter_options)
      
      # record the number of matching datasets at GEO
      Analysis.update(@analysis.id, {:matching_dataset_count => gds_list.size})
      
      gds_list.each do |gds_id|
        @output << "Getting NCBO annotations for GEO GDS#{gds_id}<br>"
        annotations = Ontology.get_ncbo_xml(['resource','GEO','element',gds_id])
        # Currently gets all annotations, could limit to those in summary and title
        # and ignore the closure annotations to get things that were more specific
        # TODO Put a filter in for non-closure annotations to see if that helps specificity
        annotations.elements.each("//ontrez.annotation.Annotation[itemKey!='closure']/termID") do |f|
          annot = Annotation.find_by_term_key_and_analysis_id(f.text, @analysis.id)
          if annot == nil
            annot = Annotation.new(:term_key => f.text, :count => 1, :gene_symbol => @gene_symbol)

            termInfo = Ontology.get_ncbo_xml(['dictionary','cui',f.text])
            # puts "terminfo: #{termInfo}"
            unless termInfo.elements['//string'] == nil
              # puts "FOUND ONE! Terminfo: #{termInfo}"
              annot.name = termInfo.elements['//string'][0].to_s
            end

            # Find ontology match
            ontologies = Ontology.get_ncbo_xml_rest(['rest','ontologies',f.text])
            ontology_key = ontologies.elements["//ontologyID"].to_a[0].to_s
            ontology = Ontology.find_by_key(ontology_key)
            if ontology != nil
              annot.ontology = ontology
            else
              ontology = Ontology.new(:key => ontology_key)
              ontology.save
              annot.ontology = ontology
            end

          else
            annot.count += 1
          end
          annot.analysis = @analysis
          annot.save
        end
      end
      Analysis.update(@analysis.id, {:end_time => Time.now()})
      # @analysis.end_time = Time.now()

    end

  end
end
