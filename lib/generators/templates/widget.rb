class <%= class_name %> < Apotomo::Widget

<% for action in actions -%>
  def <%= action %>
    render
  end

<% end -%>
end
