class Day < ActiveRecord::Base
  has_many :schedules
  def self.make_days_database(year,month,user_id)
    start_date = Date.new(year.to_i,month.to_i).beginning_of_month.day
    end_date = Date.new(year.to_i,month.to_i).end_of_month.day

    for num in start_date..end_date do
      day=Day.new
      day.year = year
      day.month = month
      day.day_month = num
      day.save
    end

  end

end
