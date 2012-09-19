module MxitRailsHelper

  def mxit_validation_message
    @_mxit_validation_messages.first
  end

  def mxit_table_row *styles
    str = ''
    if @_mxit.has_table
      # Close the previous row if there is one
      str += "</td></tr>"
    else
      # Start a new table
      str += '<table title="mxit:table:full" style="width:100%" name="main_table" cellspacing="0" cellpadding="0">'
      str += '<colgroup span="1" width="100%"></colgroup>'
    end
    @_mxit.has_table = true

    # Start the new row
    style = mxit_style *styles
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
    "<p style=\"#{ mxit_style :right }\">#{ mxit_link target, label }</p>".html_safe
  end

  def mxit_proceed content
    "<p><b style=\"#{ mxit_style :link }\">&gt; #{content}</b></p>".html_safe
  end

end