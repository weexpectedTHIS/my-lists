class MakeListsShareable < ActiveRecord::Migration
  def up
    create_table :list_owners do |t|
      t.integer :list_id
      t.string :owner
    end

    List.all.each do |l|
      ListOwner.create!(:list_id => l.id, :owner => l.owner)
    end

    remove_column :lists, :owner
  end

  def down
    raise 'Can not go back'
  end
end
