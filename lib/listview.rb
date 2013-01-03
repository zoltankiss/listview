require 'date'

#this is included in rails, but unfortunately not in the general ruby date library
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

    #parameters: vars[:events], vars[:date], vars[:page], vars[:events_per_page], vars[:date_format]
    def get_events_and_page_info vars
      vars[:date] ||= DateTime.now
      event_closed_to_today = get_event_closed_to_today(vars[:events], vars[:date])
      next_event = event_closed_to_today + (vars[:page].to_i * vars[:events_per_page].to_i)
      events = get_events(events: vars[:events],
                          date: vars[:date],
                          page: vars[:page],
                          events_per_page: vars[:events_per_page])
      rightmost_page = rightmost_page(events: vars[:events].length, next_event: next_event, events_per_page: vars[:events_per_page])
      leftmost_page = leftmost_page(next_event: next_event, events_per_page: vars[:events_per_page])
      return {
        events: events,
        rightmost_page: rightmost_page,
        leftmost_page: leftmost_page,
      }
    end

    #parameters: vars[:events], vars[:date], vars[:page], vars[:events_per_page]
    def get_events vars 
      vars[:date] ||= DateTime.now
      events_closed_to_today = get_event_closed_to_today(vars[:events], vars[:date])
      sorted_events = vars[:events].sort{ |x,y| x.date <=> y.date }
      left_most_index = events_closed_to_today + (vars[:page].to_i * vars[:events_per_page].to_i)
      if left_most_index < 0
        return sorted_events[0, vars[:events_per_page].to_i + left_most_index] || []
      end
      sorted_events[left_most_index, vars[:events_per_page].to_i] || []
    end

    def get_event_closed_to_today events, the_date=nil
      the_date ||= DateTime.now
      closest_to_today = nil
      sorted_events = events.sort{ |x,y| x.date <=> y.date }
      sorted_events.each_with_index do |event, index|
        if event.date.to_i > the_date.to_i
          if closest_to_today == nil
            closest_to_today = index
          else
            if event.date.to_i - the_date.to_i < sorted_events[closest_to_today].date.to_i - the_date.to_i
              closest_to_today = index
            end
          end
        end
      end
      return closest_to_today
    end

    #parameters: vars[:events_per_page], vars[:next_event]
    def leftmost_page vars
      if vars[:events_per_page] > vars[:next_event]
        return -1
      elsif vars[:events_per_page] == 0
        return 0
      end
      -(((vars[:next_event].to_i) / vars[:events_per_page].to_f).ceil)
    end

    #parameters:
    #vars[:events],
    #vars[:next_event]
    #vars[:events_per_page]
    def rightmost_page vars
      events_after_today_minus_page_zero = (vars[:events] - (vars[:next_event] + vars[:events_per_page]))
      (events_after_today_minus_page_zero / vars[:events_per_page].to_f).ceil
    end

  end
end
