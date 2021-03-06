class AddOsFamilyToPtable < ActiveRecord::Migration
  class FakePtableWithoutFamily < ActiveRecord::Base
    self.table_name = 'ptables'

    has_and_belongs_to_many :operatingsystems
  end

  def self.up
    add_column :ptables, :os_family, :string    unless column_exists? :ptables, :os_family
    remove_column :ptables, :operatingsystem_id if     column_exists? :ptables, :operatingsystem_id
    FakePtableWithoutFamily.reset_column_information
    FakePtableWithoutFamily.all.each do |p|
      family = p.operatingsystems.map(&:family).uniq.first rescue nil
      p.update_attribute(:os_family, family) if family
    end
  end

  def self.down
    remove_column :ptables, :os_family                 if     column_exists? :ptables, :os_family
    add_column :ptables, :operatingsystem_id, :integer unless column_exists? :ptables, :operatingsystem_id
  end
end
