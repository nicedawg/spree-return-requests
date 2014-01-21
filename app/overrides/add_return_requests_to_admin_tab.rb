Deface::Override.new(
  virtual_path: 'spree/layouts/admin',
  name: 'add_return_requests_to_admin_tab',
  insert_top: '[data-hook="admin_tabs"]',
  text: '
  <li class="tab-with-icon <%= params[:controller] == "spree/admin/return_requests" ? "selected" : "" %>">
    <%= link_to admin_return_requests_path, class: "icon_link with-tip icon-ambulance return_requests" do %>
      <span class="text">Return Requests</span>
    <% end %>
  </li>',
)
