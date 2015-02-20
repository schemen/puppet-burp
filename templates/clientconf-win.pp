password = <%= @password %> 

# More configuration files can be read, using syntax like the following
# (without the leading '# ').

# includes
<% [@includes].flatten.each do |include| -%>
include=<%= include %>
<% end -%>

# excludes
<% if !@excludes.nil? -%>
<% [@excludes].flatten.each do |exclude| -%>
exclude=<%= exclude %>
<% end -%>
<% end -%>

# extra options
<% [@options].flatten.each do |option| -%>
<%= option %>
<% end -%> 

# This argument is used by the script in /etc/burp/server_script_post
server_script_post=<%= scope['burp::server_script_post'] %>
server_script_post_arg=<%= @title %>

# include common config
. incexc/common
