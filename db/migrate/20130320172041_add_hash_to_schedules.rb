class AddHashToSchedules < ActiveRecord::Migration
  def change
    add_column :schedules, :hash_string, :string
  end
end
