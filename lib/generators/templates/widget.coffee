# Define your coffeescript code for the <%= class_name %> widget
namespace "Widget.<%= ns_name %>"
  <%= simple_name %>:
    class <%= simple_name %>
      constructor : (@widget_id = widget_id) ->

      # add custom widget function here
      toggleActive: (options) ->
