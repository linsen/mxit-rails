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

  def mxit_style *names
    content = []
    names.each do |name|
      content << MxitRails::Styles.get(name) || ''
    end
    content.join(' ').html_safe
  end

  def mxit_proceed content
    "<br /><b style=\"#{ mxit_style :link }\"> &gt; #{content}</b><br />".html_safe
  end

  def mxit_select_row label, value, selected
    @_mxit_select_index ||= 0
    @_mxit_select_index += 1

    target = "#{request.path}?"
    if @_mxit.multi_select
      # Which input to modify, and which key to toggle for that input
      target += "_mxit_rails_multi_select=#{@_mxit.select}&_mxit_rails_multi_select_value=#{value}"
    else
      target += "_mxit_rails_submit=true&#{@_mxit.select}=#{value}"
    end

    content = selected ? "<b>#{label}</b>" : label

    output = "<a href=\"#{target}\">"
    if @_mxit.numbered_list
      output += "#{@_mxit_select_index})</a> #{content}"
    else
      output += "#{label}</a>"
      output = (selected ? '+ ' : '- ') + output
    end
    output += "<br />"

    output.html_safe
  end

end