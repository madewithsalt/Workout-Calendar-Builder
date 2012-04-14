require 'json'
require 'date'
require 'time'

class Parser
	def initialize(start_date, time, type)
    @file = File.read('p90x-data.json')
		@data = JSON.parse(@file)
    @file_name = "p90x_#{type}.csv"

    parse_file_data(start_date, time, type)
  end
  def parse_file_data(date, time, type)
    get_date = Date.parse(date)
    get_time = DateTime.parse("#{get_date} #{time}")
    workouts = @data['workouts']
    events = @data[type]

    #start with the top of the csv = google calendar style
    parsed_data = "Subject,Start Date,Start Time,End Date,End Time,All Day Event,Reminder On/Off,\
                  Reminder Date,Reminder Time,Meeting Organizer,Description,Location,Private \r\n"

    # now for each of the 90 days we'll create calendar events based on the start date
    (1..90).each { |n|
      agenda = ''

      start_date = n==1 ? (get_date).strftime('%m/%d/%y') : (get_date + (n-1)).strftime('%m/%d/%y')
      subject = workouts[events[n-1]]
      start_time = get_time.strftime('%T')   #2/14/2008,8:10:00
      end_time = ''
      end_date = start_date
      all_day = "FALSE"
      description = ''
      location = "Your Home Gym!"
      private = "TRUE"

      agenda += "\"#{subject}\",#{start_date},#{start_time},#{end_date},#{end_time},#{all_day},#{description},#{location},#{private} \r\n"
      parsed_data += agenda
    }

    puts parsed_data
    save_file_data(parsed_data)
  end
  def save_file_data(parsed_data)
    puts "Saving file data to #{@file_name}..."

    @new_file = File.open("#{@file_name}", "w")
    @new_file.write(parsed_data)
  end
end

# EXAMPLE USE: Takes 3 values, Start Date, Start Time, and mode. Only Classic is in now.
#parser = Parser.new("April 18, 2012", "7:30 AM", "classic")
parser = Parser.new(ARGV[0], ARGV[1], ARGV[2])