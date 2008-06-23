class CreateAnalyses < ActiveRecord::Migration
  def self.up
    create_table :analyses do |t|
      t.string :search_string
      t.datetime :start_time, :end_time
      t.timestamps
    end
  end

  def self.down
    drop_table :analyses
  end
end
