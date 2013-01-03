require 'spec_helper'
require 'date'

class EventStub
  attr_accessor :date
  def initialize date, name
    @date = date
    @name = name
  end
  def == other_event
    @date == other_event.date
  end
end

describe ListView do

  let(:right_now) { DateTime.now }

  let(:first_event) { EventStub.new(right_now - 8, 'first_event') }
  let(:second_event) { EventStub.new(right_now - 7, 'second_event') }
  let(:third_event) { EventStub.new(right_now - 1, 'third_event') }
  let(:fourth_and_current_event) { EventStub.new(right_now + (1.0/60), 'fourth_and_current_event') }
  let(:fifth_event) { EventStub.new(right_now + 1, 'fifth_event') }
  let(:sixth_event) { EventStub.new(right_now + 3, 'sixth_event') }
  let(:seventh_event) { EventStub.new(right_now + 4, 'seventh_event') }

  let(:events) do
    [
      fifth_event,
      seventh_event,
      first_event,
      third_event,
      fourth_and_current_event,
      sixth_event,
      second_event,
    ]
  end

  describe 'get_event_closed_to_today method' do
    it { ListView.get_event_closed_to_today(events).should == 3 }
  end

  describe 'get_events method' do
    describe '2 events per page' do
      it 'first page' do
        ListView.get_events(events: events, today: right_now, page: 0, events_per_page: 2).should == [
          fourth_and_current_event,
          fifth_event,
        ]
      end
  
      it 'second page' do
        ListView.get_events(events: events, today: right_now, page: 1, events_per_page: 2).should == [
          sixth_event,
          seventh_event,
        ]
      end
  
      it "third page (shouldn't exist)" do
        ListView.get_events(events: events, today: right_now, page: 2, events_per_page: 2).should == []
      end
  
      it 'negative first page' do
        ListView.get_events(events: events, today: right_now, page: -1, events_per_page: 2).should == [
          second_event,
          third_event,
        ]
      end
  
      it 'negative second page' do
        ListView.get_events(events: events, today: right_now, page: -2, events_per_page: 2).should == [
          first_event,
        ]
      end
  
      it "negative third page (shouldn't exist)" do
        ListView.get_events(events: events, today: right_now, page: -3, events_per_page: 2).should == []
      end
    end
  end


  describe 'leftmost_page method' do
    it { ListView.leftmost_page(next_event: 5, events_per_page: 3).should == -2 }
    it { ListView.leftmost_page(next_event: 7, events_per_page: 5).should == -2 }
    it { ListView.leftmost_page(next_event: 2, events_per_page: 4).should == -1 }
    it { ListView.leftmost_page(next_event: 5, events_per_page: 0).should == 0 }
  end
  
  describe 'rightmost_page method' do
    it { ListView.rightmost_page(next_event: 4, events: 0, events_per_page: 2).should == -3 }
    it { ListView.rightmost_page(next_event: 4, events: 2, events_per_page: 2).should == -2 }
    it { ListView.rightmost_page(next_event: 4, events: 3, events_per_page: 2).should == -1 }
    it { ListView.rightmost_page(next_event: 4, events: 4, events_per_page: 2).should == -1 }
    it { ListView.rightmost_page(next_event: 4, events: 5, events_per_page: 2).should == 0 }
    it { ListView.rightmost_page(next_event: 4, events: 6, events_per_page: 2).should == 0 }
    it { ListView.rightmost_page(next_event: 4, events: 8, events_per_page: 2).should == 1 }
    it { ListView.rightmost_page(next_event: 4, events: 9, events_per_page: 2).should == 2 }
    it { ListView.rightmost_page(next_event: 4, events: 10, events_per_page: 2).should == 2 }
  end

  describe 'get_events_and_page_info method' do
    it do
      ListView.get_events_and_page_info(events: events,
                                        page: 0,
                                        events_per_page: 2).should == {
        events: [fourth_and_current_event, fifth_event],
        leftmost_page: -2,
        rightmost_page: 1,
      }
    end
    it { ListView.leftmost_page(next_event: 3, events_per_page: 2).should == -2 }
    it { ListView.rightmost_page(next_event: 3, events: 7, events_per_page: 2).should == 1 }



    it do
      ListView.get_events_and_page_info(events: events,
                                        page: 1,
                                        events_per_page: 2).should == {
        events: [sixth_event, seventh_event],
        leftmost_page: -3,
        rightmost_page: 0,
      }
    end
    it { ListView.leftmost_page(next_event: 5, events_per_page: 2).should == -3 }
    it { ListView.rightmost_page(next_event: 5, events: 7, events_per_page: 2).should == 0 }



    it do
      ListView.get_events_and_page_info(events: events,
                                        page: -1,
                                        events_per_page: 2).should == {
        events: [second_event, third_event],
        leftmost_page: -1,
        rightmost_page: 2,
      }
    end
    it { ListView.leftmost_page(next_event: 1, events_per_page: 2).should == -1 }
    it { ListView.rightmost_page(next_event: 1, events: 7, events_per_page: 2).should == 2 }
  end
end
