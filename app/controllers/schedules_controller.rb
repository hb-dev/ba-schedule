# encoding: UTF-8
$KCODE = 'u'
class SchedulesController < ApplicationController

  layout :set_layout

  require "net/http"
  require "net/https"
  require "uri"
  require "date"
  include Icalendar

  def index
    @schedule = Schedule.new   
  end
  
  def create        
    @schedule = Schedule.new(params[:schedule])
   
    if @schedule.save
      start_date = (@schedule.start_date.beginning_of_day - 1.hour).to_i
      end_date = (@schedule.end_date.end_of_day - 1.hour + 1.second).to_i
      hash_string = params[:hash_string]
      
      uri = URI.parse("https://selfservice.campus-dual.de/room/json")
      @params = {'userid' => @schedule.student_id, 'start' => start_date, 'end' => end_date, '_' => Time.now.to_i, 'hash' => hash_string}
      http = Net::HTTP.new(uri.host, uri.port) 
      http.use_ssl = (uri.scheme == 'https')
      request = Net::HTTP::Get.new(uri.path) 
      request.set_form_data(@params)
  
      request = Net::HTTP::Get.new(uri.path+ '?' + request.body) 
      @response = http.request(request)
      
      @lessons = JSON.parse(@response.body).reject! { |lesson| lesson["start"] < start_date || lesson["start"] > end_date } unless @response.header["content-length"]
      puts @lessons
      if @lessons 
        @calendar = Calendar.new
        @calendar.custom_property("X-WR-CALNAME;VALUE=TEXT", "BA Vorlesungsplan")
        @calendar.custom_property("X-WR-TIMEZONE;VALUE=TEXT", "Europe/London")
        # @calendar.timezone do
          # timezone_id             "W. Europe Standard Time"
#         
          # daylight do
            # timezone_offset_from  "+0100"
            # timezone_offset_to    "+0200"
            # timezone_name         "CEST"
            # dtstart               "16010325T020000"
            # add_recurrence_rule   "FREQ=YEARLY;BYDAY=-1SU;BYMONTH=3"
          # end
#         
          # standard do
            # timezone_offset_from  "+0200"
            # timezone_offset_to    "+0100"
            # timezone_name         "CET"
            # dtstart               "16011028T030000"
            # add_recurrence_rule   "FREQ=YEARLY;BYDAY=-1SU;BYMONTH=10"
          # end
        # end        
        @lessons.each do |lesson|
          @calendar.event do
              description lesson["title"]
              dtstart     I18n.l(Time.at(lesson["start"]), :format => :ical)
              dtend       I18n.l(Time.at(lesson["end"]), :format => :ical)
              location    lesson["room"]
              summary     "#{lesson['title']} #{lesson['instructor']} #{lesson['room']}"       
          end
        end 
        @calendar_string = @calendar.to_ical
        #render :text => @calendar_string
        send_data(@calendar_string, :type => 'text/calendar; charset=UTF-8', :disposition => 'inline; filename=stundenplan.ics', :filename=>'stundenplan.ics')      
      else 
        redirect_to schedules_path, :notice => "Es wurden keine Einträge gefunden!"     
      end         
    else
      redirect_to schedules_path, :alert => "Es ist ein Fehler aufgetreten. Bitte Eingaben überprüfen!"
    end
  end    
  
  def imprint
    
  end
  
  def subscribe
    respond_to do |format|
      format.js {  }
    end
  end
  
  def subscription
    if params[:student_id]
      student_id = params[:student_id]
      hash_string = params[:hash_string]
      start_date = params[:start]#Time.now.beginning_of_day.to_i
      end_date = params[:end]#(start_date + 6.months).to_i
      now = params[:_]
      
      uri = URI.parse("https://selfservice.campus-dual.de/room/json")
      params = {'userid' => student_id, 'start' => start_date, 'end' => end_date, '_' => now, 'hash' => hash_string}
      http = Net::HTTP.new(uri.host, uri.port) 
      http.use_ssl = (uri.scheme == 'https')
      request = Net::HTTP::Get.new(uri.path) 
      request.set_form_data(params)
  
      request = Net::HTTP::Get.new(uri.path+ '?' + request.body) 
      @response = http.request(request)
      
      @lessons = JSON.parse(@response.body).reject! { |lesson| lesson["start"] < start_date || lesson["start"] > end_date } unless @response.header["content-length"]
      
      if @lessons 
        @calendar = Calendar.new        
        @calendar.custom_property("X-WR-CALNAME;VALUE=TEXT", "BA Vorlesungsplan")  
        @calendar.custom_property("X-WR-TIMEZONE;VALUE=TEXT", "Europe/London")
        # @calendar.timezone do
          # timezone_id             "W. Europe Standard Time"
#         
          # daylight do
            # timezone_offset_from  "+0100"
            # timezone_offset_to    "+0200"
            # timezone_name         "CEST"
            # dtstart               "16010325T020000"
            # add_recurrence_rule   "FREQ=YEARLY;BYDAY=-1SU;BYMONTH=3"
          # end
#         
          # standard do
            # timezone_offset_from  "+0200"
            # timezone_offset_to    "+0100"
            # timezone_name         "CET"
            # dtstart               "16011028T030000"
            # add_recurrence_rule   "FREQ=YEARLY;BYDAY=-1SU;BYMONTH=10"
          # end
        # end        
        @lessons.each do |lesson|
          @calendar.event do
              description lesson["title"]
              dtstart     I18n.l(Time.at(lesson["start"]), :format => :ical)
              dtend       I18n.l(Time.at(lesson["end"]), :format => :ical)
              location    lesson["room"]
              summary     "#{lesson['title']} #{lesson['instructor']} #{lesson['room']}"       
          end
        end 
        @calendar_string = @calendar.to_ical
        #render :text => @calendar_string
        send_data(@calendar_string, :type => 'text/calendar; charset=UTF-8', :disposition => 'inline; filename=stundenplan.ics', :filename=>'stundenplan.ics')      
      else 
        redirect_to schedules_path, :notice => "Es wurden keine Einträge gefunden!"     
      end             
      
    end
  end
  
  private
  
  def set_layout
    action_name == "imprint" ? "imprint" : "application"
  end
  
end