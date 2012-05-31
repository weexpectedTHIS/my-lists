class AddSorting < ActiveRecord::Migration
  def up
    add_column :lists, :ordering, :integer

    List.select(:owner).group(:owner).map(&:owner).each do |owner|
      lists = List.where(:owner => owner).order('id ASC')
      lists.each_with_index do |list, index|
        List.where(:id => list.id).update_all(:ordering => index)
        list.update_attributes!(:ordering => index)
      end
    end

    add_column :items, :ordering, :integer

    List.all.each do |list|
      items = list.items.order('id ASC')
      items.each_with_index do |item, index|
        Item.where(:id => item.id).update_all(:ordering => index)
      end
    end
  end

  def down
    remove_column :items, :ordering
    remove_column :lists, :ordering
  end
end
