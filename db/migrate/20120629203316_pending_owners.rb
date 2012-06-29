class PendingOwners < ActiveRecord::Migration
  def up
    create_table :pending_owners do |t|
      t.string :owner
      t.string :requester
      t.integer :list_id
    end
  end

  def down
    drop_table :pending_owners
  end
end
