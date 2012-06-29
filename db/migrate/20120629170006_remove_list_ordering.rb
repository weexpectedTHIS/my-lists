class RemoveListOrdering < ActiveRecord::Migration
  def up
    remove_column :lists, :ordering
  end

  def down
    raise 'Can not go back'
  end
end
