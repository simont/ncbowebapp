class CreateAnnotations < ActiveRecord::Migration
  def self.up
    create_table :annotations do |t|
      t.references :ontology, :analysis
      t.string  :term_key, :name, :source, :gene_symbol
      t.integer :count
      t.timestamps
    end
  end

  def self.down
    drop_table :annotations
  end
end
