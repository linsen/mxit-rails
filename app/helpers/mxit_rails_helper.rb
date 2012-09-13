module MxitRailsHelper

  def mxit_path route
    MxitRails::Router.url route
  end

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

end