class CreateOntologies < ActiveRecord::Migration
  def self.up
    create_table :ontologies do |t|
      t.string :key, :name, :null => false
      t.text :description
      t.timestamps
    end
  end

  def self.down
    drop_table :ontologies
  end
end
