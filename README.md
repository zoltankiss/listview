listview
========

Note: The best way to see what ListView does is view the app it was designed for, http://freefoodumn.com/view_by_list


ListView allows paginating events on your web app (or any app) so that http://yoururl.com/page=0 shows events starting from today's date.

Installation:

``` ruby
## Gemfile for Rails 3, Sinatra, and Merb
gem 'listview'
```


## Basic Usage in Rails


### example_controller.rb

```
class ExampleController

  def example
    @events = ListView.organization_events_by_day(events: Event.all, today: DateTime.now, page: 0, events_per_page: 5)
  end

end
```

### app/views/example/example.html.erb

```
<% @events.each do |event| %>
  <h1><% event[:date] %></h1>
  <p><% event[:events] %></p>
<% end %>
```


And you'll have something like: http://freefoodumn.com/view_by_list