module MxitHelper

  def mxit_link route, label
    output = "<a href=\"/#{route.to_s}\">#{label}</a>".html_safe
  end

  def mxit_style *names
    content = []
    names.each do |name|
      content << MxitRails::Styles.get(name) || ''
    end
    "style=\"#{ content.join(' ') }\"".html_safe
  end

end