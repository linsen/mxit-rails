class ApplicationController < ActionController::Base

  # The body style is automatically applied to all pages
  mxit_style :body, 'background-color:#F8F3EA; color:#000000'

  # The title style is automatically applied to the page title
  mxit_style :title, 'padding:4px 6px; background-color:#e17116; color:#ffffff;'

  mxit_style :link_hover, 'background-color: #359325; color: #ffffff;'
  mxit_style :link, 'color: #359325;'

end
