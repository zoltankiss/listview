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
    def get_events vars
      get_events_that_havent_happened_yet(vars[:events], vars[:events_per_page], (vars[:page].to_i)*vars[:events_per_page])
    end
    private
      def get_events_that_havent_happened_yet events, number_of_events_per_page, offset=0
        events_that_havent_happened_yet = events
        events_that_havent_happened_yet.sort_by! {|event| event.date}
        closest_to_today = get_event_closed_to_today(events_that_havent_happened_yet)
        return [] if closest_to_today.nil?
  
        start_event_index = [closest_to_today + offset, 0].max
        return events_that_havent_happened_yet[start_event_index, number_of_events_per_page]
      end

      def get_event_closed_to_today events
        today = DateTime.now
        closest_to_today = nil
        events.each_with_index do |event, index|
          if event.date.to_i - today.to_i > 0
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