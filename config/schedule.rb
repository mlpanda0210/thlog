set :enviroment, :development
set :output, 'log/cron.log'

every 1.minute do # 1.minute 1.day 1.week 1.month 1.year is also supported
  runner "Schedule.allusers_update_schedule"
end
