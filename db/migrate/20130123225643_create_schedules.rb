class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.string :student_id
      t.datetime :start_date
      t.datetime :end_date
      t.timestamps
    end
  end
end
