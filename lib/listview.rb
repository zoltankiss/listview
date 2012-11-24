require 'date'

class DateTime
  def to_i
    seconds_since_unix_epoch.to_i
  end

  private
    def seconds_since_unix_epoch
      seconds_per_day = 86_400
      (self - ::DateTime.civil(1970)) * seconds_per_day
    end
end

class ListView

  class << self
    #example use:
    #
    #class ObjectThatRespondsToDate
    #  attr_accessor :date
    #end
    #
    #obj1 = ObjectThatRespondsToDate.new
    #obj1.date = DateTime.now
    #
    #
    #get_events(events: [obj1], events_per_page: 5, page: 0)
    def get_events vars
      get_events_that_havent_happened_yet(vars[:events], vars[:events_per_page], (vars[:page].to_i)*vars[:events_per_page])[:events_that_havent_happened_yet]
    end

    #example use:
    #
    #get_events(events: [obj1], events_per_page: 5, page: 0, date_format: "%B, %d")
    #date_format help: http://ruby-doc.org/stdlib-1.9.3/libdoc/date/rdoc/DateTime.html#method-i-to_date
    def organization_events_by_day vars
      vars[:date_format] ||= "%B, %d"
      events_dict = get_events_that_havent_happened_yet(vars[:events], vars[:events_per_page], (vars[:page].to_i)*vars[:events_per_page])

      organized_events = events_dict[:events_that_havent_happened_yet]
      rightmost_page = events_dict[:rightmost_page]
      leftmost_page = events_dict[:leftmost_page]

      events_organized_by_day = []
      current_day = DateTime.now
      def event_date date, date_format
        if only_date(date) == only_date(DateTime.now)
          "Today"
        else
          date.strftime(date_format)
        end
      end
      organized_events.each_with_index do |event, index|
        if only_date(event.date) != only_date(current_day)
          current_day = event.date
          events_organized_by_day += [date: event_date(event.date, vars[:date_format]), events: [event]]
        elsif index == 0
          events_organized_by_day += [date: event_date(event.date, vars[:date_format]), events: [event]]
        else
          events_organized_by_day[-1][:events] += [event]
        end
      end
      return {
        events: events_organized_by_day,
        rightmost_page: rightmost_page,
        leftmost_page: leftmost_page,
      }
    end

    private

      def only_date date_time
        date_time.strftime("%d/%m/%Y")
      end

      def get_events_that_havent_happened_yet events, number_of_events_per_page, offset=0
        events_that_havent_happened_yet = events
        events_that_havent_happened_yet.sort_by! {|event| event.date}
        closest_to_today = get_event_closed_to_today(events_that_havent_happened_yet)

        return_var = {}
        return_var[:events_that_havent_happened_yet] = []
        event_index = closest_to_today + offset
        return_var[:leftmost_page] = -((event_index / number_of_events_per_page).to_i)
        return_var[:rightmost_page] = (((events_that_havent_happened_yet.length - 1) - (event_index)) / number_of_events_per_page).to_i

        return return_var if closest_to_today.nil?

        start_event_index = [closest_to_today + offset, 0].max
        return_var[:events_that_havent_happened_yet] = events_that_havent_happened_yet[start_event_index, number_of_events_per_page]
        return return_var
      end

      def get_event_closed_to_today events
        today = DateTime.now
        closest_to_today = nil
        events.each_with_index do |event, index|
          if event.date.to_i > today.to_i
            if closest_to_today == nil
              closest_to_today = index
            else
              if event.date.to_i - today.to_i < events[closest_to_today].date.to_i - today.to_i
                closest_to_today = index
              end
            end
          end
        end
        return closest_to_today
      end
  end

end
