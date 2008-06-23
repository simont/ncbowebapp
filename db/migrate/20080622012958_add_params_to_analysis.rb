class AddParamsToAnalysis < ActiveRecord::Migration
  def self.up
    add_column :analyses, :geo_filter_option, :string
    add_column :analyses, :matching_dataset_count, :integer
    
    Analysis.find(:all).each do |a|
      Analysis.update(a.id, :geo_filter_option => 'find_significant')
    end
  end

  def self.down
    remove_column :analyses, :geo_filter_option
    remove_column :analyses, :matching_dataset_count
  end
end
