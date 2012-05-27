class InitialMigration < ActiveRecord::Migration
  def self.up
    create_table :lists do |t|
      t.string :owner
      t.string :name
      t.string :slug
    end

    create_table :items do |t|
      t.integer :list_id
      t.string :slug
      t.text :note
    end
  end

  def self.down
    drop_table :items
    drop_table :lists
  end
end
