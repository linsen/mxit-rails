module MxitRailsHelper

  def mxit_validation_message
    @_mxit_validation_messages.first
  end

  def mxit_table_row *styles
    str = ''
    if @_mxit.has_table
      # Close the previous row if there is one
      str += "<br /></td></tr>"
    else
      # Start a new table
      str += '<table title="mxit:table:full" style="width:100%" name="main_table" cellspacing="0" cellpadding="0">'
      str += '<colgroup span="1" width="100%"></colgroup>'
    end
    @_mxit.has_table = true

    # Start the new row
    style = styles.empty? ? mxit_style(:body) : mxit_style(*styles)
    str += "<tr><td style=\"#{ style }\">"
    str.html_safe
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

  def mxit_nav_link target, label
    "#{ mxit_link target, label }<br /><br />".html_safe
  end

  def mxit_proceed content
    "<br /><b style=\"#{ mxit_style :link }\"> &raquo; #{content}</b><br />".html_safe
  end

end