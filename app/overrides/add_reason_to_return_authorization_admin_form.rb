Deface::Override.new(
  name: 'add_reason_to_return_authorization_admin_form_header',
  virtual_path: 'spree/admin/return_authorizations/_form',
  insert_bottom: '[data-hook="rma_header"]',
  text: <<-EOT
    <th><%= Spree.t(:return_reason) %></th>
    <th><%= Spree.t(:return_comments) %></th>
  EOT
)

Deface::Override.new(
  name: 'add_reason_to_return_authorization_admin_form_body',
  virtual_path: 'spree/admin/return_authorizations/_form',
  insert_bottom: '[data-hook="rma_row"]',
  text: <<-EOT
    <% return_info = @return_authorization.get_return_info_for_variant(variant) %>
    <td><%= return_info.reason %></td>
    <td><%= return_info.comments %></td>
  EOT
)
