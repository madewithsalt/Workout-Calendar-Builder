require 'json'
require 'date'
require 'time'

class Parser
	def initialize(start_date, time, type, difficulty)
    @file = File.read("#{type}-data.json")
		@data = JSON.parse(@file)
    @file_name = "#{type}_#{difficulty}.csv"

    parse_file_data(start_date, time, difficulty)
  end
  def parse_file_data(date, time, difficulty)
    get_date = Date.parse(date)
    get_time = DateTime.parse("#{get_date} #{time}")
    workouts = @data['workouts']
    duration = @data['duration']
    events = @data[difficulty]

    #start with the top of the csv = google calendar style
    parsed_data = "Subject,Start Date,Start Time,End Date,End Time,All Day Event,Reminder On/Off,\
                  Reminder Date,Reminder Time,Meeting Organizer,Description,Location,Private \r\n"

    # now for each of the days we'll create calendar events based on the start date
    (events).each_index { |n|
      agenda = ''

      start_date = (get_date + n).strftime('%m/%d/%y')

      if events[n].is_a? Array
        event_names = []

        for idx in events[n]
          event_names.push(workouts[idx])
        end

        subject = event_names.join(" & ")

      else
        subject = workouts[events[n]]
      end

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

# EXAMPLE USE: 
#parser = Parser.new("April 18, 2012", "7:30 AM", "t25", "classic")
parser = Parser.new(ARGV[0], ARGV[1], ARGV[2], ARGV[3])