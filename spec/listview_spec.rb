require 'spec_helper'
require 'date'

class EventStub
  attr_accessor :date
  def initialize date
    @date = date
  end
  def == other_event
    @date == other_event.date
  end
end

describe ListView do
  let(:right_now) { DateTime.now }
  let(:starting_date) { right_now + (1.0/60) }

  describe "a few events" do
    let(:events) do
      [
        EventStub.new(right_now + (1.0/60)),
        EventStub.new(right_now + 1),
        EventStub.new(right_now - 1),
        EventStub.new(right_now + 2),
        EventStub.new(right_now - 2),
        EventStub.new(right_now + 5),
        EventStub.new(right_now - 5),
        EventStub.new(right_now + 7),
        EventStub.new(right_now - 7),
        EventStub.new(right_now + 10),
      ]
    end

    it do
      ListView.get_events(events: events, today: right_now, page: 0, events_per_page: 2).should == [
        EventStub.new(right_now + (1.0/60)),
        EventStub.new(right_now + 1),
      ]
    end

    it do
      ListView.get_events(events: events, today: right_now, page: -1, events_per_page: 2).should == [
        EventStub.new(right_now - 2),
        EventStub.new(right_now - 1),
      ]
    end

    it do
      ListView.get_events(events: events, today: right_now, page: -1, events_per_page: 3).should == [
        EventStub.new(right_now - 5),
        EventStub.new(right_now - 2),
        EventStub.new(right_now - 1),
      ]
    end

    it do
      ListView.get_events(events: events, today: right_now, page: 2, events_per_page: 2).should == [
        EventStub.new(right_now + 7),
        EventStub.new(right_now + 10),
      ]
    end
  end


  describe "many events" do
    let(:events) do
      starting_date = right_now + (1.0/60) - 50
      ([0]*100).each_with_index.map do |item, k|
        EventStub.new(starting_date + k)
      end
    end

    it do
      list_view_events = ListView.get_events(events: events, today: right_now, page: -2, events_per_page: 20)

      list_view_events.should == ([0]*20).each_with_index.map do |item, k|
        EventStub.new(starting_date - 40 + k)
      end
    end

    it do
      list_view_events = ListView.get_events(events: events, today: right_now, page: -1, events_per_page: 20)

      list_view_events.should == ([0]*20).each_with_index.map do |item, k|
        EventStub.new(starting_date - 20 + k)
      end
    end

    it do
      list_view_events = ListView.get_events(events: events, today: right_now, page: 0, events_per_page: 20)

      list_view_events.should == ([0]*20).each_with_index.map do |item, k|
        EventStub.new(starting_date + k)
      end
    end

    it do
      list_view_events = ListView.get_events(events: events, today: right_now, page: 1, events_per_page: 20)

      list_view_events.should == ([0]*20).each_with_index.map do |item, k|
        EventStub.new(starting_date + 20 + k)
      end
    end

    it do
      list_view_events = ListView.get_events(events: events, today: right_now, page: 2, events_per_page: 20)

      list_view_events.should == ([0]*10).each_with_index.map do |item, k|
        EventStub.new(starting_date + 40 + k)
      end
    end
  end

  describe "organization events by days" do
    let(:events) do
      [
        EventStub.new(right_now + (1.0/60)),
        EventStub.new(right_now + 1),
        EventStub.new(right_now - 1),
        EventStub.new(right_now + 2),
        EventStub.new(right_now - 2),
        EventStub.new(right_now + 5),
        EventStub.new(right_now - 5),
        EventStub.new(right_now + 7),
        EventStub.new(right_now - 7),
        EventStub.new(right_now + 10),
      ]
    end

    it do
      ListView.organization_events_by_day(
        events: events,
        today: right_now,
        page: 0,
        events_per_page: 2,
        date_format: "%B, %d").should == [
        {
          date: "Today",
          events: [EventStub.new(right_now + (1.0/60))]
        },
        {
          date: (right_now + 1).strftime("%B, %d"),
          events: [EventStub.new(right_now + 1)]
        },
      ]
    end

    it do
      ListView.organization_events_by_day(
        events: events,
        today: right_now,
        page: -1,
        events_per_page: 2,
        date_format: "%B, %d").should == [
        {
          date: (right_now - 2).strftime("%B, %d"),
          events: [EventStub.new(right_now - 2)]
        },
        {
          date: (right_now - 1).strftime("%B, %d"),
          events: [EventStub.new(right_now - 1)]
        },
      ]
    end
  end
end
