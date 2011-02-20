class <%= class_name %>Widget < Apotomo::Widget

<% for action in actions -%>
  def <%= action %>
    render
  end

<% end -%>
end
