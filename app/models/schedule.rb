class Schedule < ActiveRecord::Base
  attr_accessible :student_id, :start_date, :end_date
  
  
  validates :student_id, :presence => true
  validates :start_date, :presence => true
  validates :end_date, :presence => true
  validates_date :start_date
  validates_date :end_date, :after => :start_date
end
