class AddFinishedFlag < ActiveRecord::Migration
  def up
    add_column :items, :finished, :boolean, :default => false
  end

  def down
    remove_column :items, :finished
  end
end
