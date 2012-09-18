module MxitRailsHelper

  def mxit_link route, label, variables=nil
    unless variables.nil?
      var_strings = []
      #TODO: Use default Rails get encoding
      variables.each do |key, value|
        var_strings << "#{key}=#{value}"
      end
      route += "?#{var_strings.join('&')}"
    end
    output = "<a href=\"#{route}\">#{label}</a>".html_safe
  end

  def mxit_style *names
    content = []
    names.each do |name|
      content << MxitRails::Styles.get(name) || ''
    end
    content.join(' ').html_safe
  end

  def mxit_nav_link target, label
    "<p style=\"#{ mxit_style :right }\">#{ mxit_link target, label }</p>".html_safe
  end

  def mxit_proceed content
    "<p><b style=\"#{ mxit_style :link }\">&gt; #{content}</b></p>".html_safe
  end

end