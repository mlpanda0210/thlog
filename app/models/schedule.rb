class Schedule < ActiveRecord::Base
  belongs_to :user
  belongs_to :tag
  belongs_to :day

  def self.update_events(user,schedule)
    client = Google::APIClient.new
    client.authorization.access_token = user.token
    client.authorization.client_id = ENV['GOOGLE_CLIENT_ID']
    client.authorization.client_secret = ENV['GOOGLE_CLIENT_SECRET']
    client.authorization.refresh_token = user.refresh_token
    service = client.discovered_api('calendar', 'v3')
    params = {'calendarId' => 'primary','eventId' => schedule[:event_id]}

    event = {'summary' => schedule[:summary],'description' => schedule[:description],'start' => {'dateTime' => schedule[:starttime].to_datetime},'end' => {'dateTime' => schedule[:endtime].to_datetime}}
    result = client.execute(:api_method => service.events.update,:parameters => params,:body_object => event)
    schedule_db = self.find_by(event_id: schedule[:event_id])
    schedule_db.update(summary: schedule[:summary],description: schedule[:description])
  end

  def self.update_schedule(user)
    self.where(user_id: user.id).delete_all
    client = Google::APIClient.new
    client.authorization.access_token = user.token
    client.authorization.client_id = ENV['GOOGLE_CLIENT_ID']
    client.authorization.client_secret = ENV['GOOGLE_CLIENT_SECRET']
    client.authorization.refresh_token = user.refresh_token
    service = client.discovered_api('calendar', 'v3')
    @responses = client.execute(
    :api_method => service.events.list,
    :parameters => {'calendarId' => 'primary',
      'timeMin'=> (Time.now - 6.months).iso8601,
      'timeMax'=> (Time.now + 1.months).iso8601,
      'maxResults' => 2500},
      :headers => {'Content-Type' => 'application/json'})
      events = []
      @responses.data.items.each do |item|
        events << item
      end
      events.each do |event|
        if event.summary.nil? || event["start"]["dateTime"].nil? then
          next
        end
        if event.summary.include?("プライベート")||event.summary.include?("業務外")||event.summary.include?("private")then
          next
        end
        if event["attendees"].present?  then
          if event["attendees"].select{|a,b,c,d|a["email"] == user.email}[0]["responseStatus"] != "accepted"  then
            next
          end
        end
        @schedule_year_month = Schedule.new
        @schedule_year_month.event_id = event["id"]
        @schedule_year_month.user_id = user.id
        @schedule_year_month.summary = event["summary"]
        @schedule_year_month.description = event["description"]
        @schedule_year_month.starttime = event["start"]["dateTime"]
        @schedule_year_month.endtime = event["end"]["dateTime"]
        @schedule_year_month.year = event["start"]["dateTime"].year.to_i
        @schedule_year_month.month = event["start"]["dateTime"].month.to_i
        @schedule_year_month.day_month = event["start"]["dateTime"].day.to_i
        @schedule_year_month.spendtime = (@schedule_year_month.endtime-@schedule_year_month.starttime)/3600
        @schedule_year_month.save
      end
    end



  def self.add_tag_id(user_id)
    self.where(user_id: user_id).update_all(tag_id: nil)
    tags = Tag.where.not(name:["other"]).where(user_id: user_id)
    tags.each do |tag|
      tag_array = []
      if tag.name.include?("　")
        tag.name = tag.name.gsub("　"," ")
      end
      tag_array = tag.name.strip.split
      schedules = self.ransack(summary_cont_any: tag_array).result
      schedules.update_all(tag_id: tag.id)
   end
   schedules = self.all.where(user_id: user_id)
   schedules.each do |s|
     if s.tag_id == nil
       s.tag_id = Tag.where(user_id: user_id).find_by(name:"other").id
       s.save
     end
   end
 end

   def self.month_sum_work_time(user_id)
     tags = Tag.all.where(user_id: user_id).order(created_at: :desc)
     tags.each do |tag|
      sum = 0
      schedules = Schedule.where(tag_id: tag.id).where(user_id: user_id)
       schedules.each do |schedule|
        work_hours = (schedule.endtime-schedule.starttime)/3600
        sum += work_hours.to_i
      end
     tag.sum_time = sum
     end
   end



   def self.add_day_id(user_id)
     schedules = Schedule.all.where(user_id: user_id)
     days = Day.all
     days.each do |day|
       schedules = Schedule.where(year: day.year, month: day.month, day_month: day.day_month).where(user_id: user_id)
       schedules.update_all(day_id: day.id)
     end
   end

   def self.copy_user_schedules
      AdminSchedule.delete_all
     self.all.find_each do |s|
       AdminSchedule.create(
       user_id: s.user_id,
       day_id: s.day_id,
       summary: s.summary,
       description: s.description,
       starttime: s.starttime,
       endtime: s.endtime,
       spendtime: s.spendtime,
       year: s.year,
       month: s.month,
       day_month: s.day_month
       )
     end
   end
end
