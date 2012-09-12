module MxitRailsHelper

  def mxit_path route
    MxitRails::Router.url route
  end

  def mxit_link route, label
    path = mxit_path route
    output = "<a href=\"#{path}\">#{label}</a>".html_safe
  end

  def mxit_style *names
    content = []
    names.each do |name|
      content << MxitRails::Styles.get(name) || ''
    end
    "style=\"#{ content.join(' ') }\"".html_safe
  end

end