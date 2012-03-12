module ApplicationHelper

  def app_text_field_tag(field_name, label=nil, span=6, value=nil)
    render '/helpers/text_field_tag', :field_name => field_name,
                                      :label => (label ? label : field_name.to_s.humanize),
                                      :span => span,
                                      :value => value
  end
  
  def app_text_field(form_object, field_name, label=nil, span=6)
    render '/helpers/text_field', :form_object => form_object,
                                  :field_name => field_name,
                                  :label => (label ? label : field_name.to_s.humanize),
                                  :span => span
  end
  
  def configurator(key)
    Clearing::Application.config.application[key]
  end

  def logo_image_for_header
    image_tag 'logo-dark-reduced-horizontal.gif', :style => 'float:left'
  end
  
  def pretty_date_time(dt)
    "#{pretty_date(dt)}, #{pretty_time(dt)}"
  end
  
  def pretty_date(dt)
    day = dt.day.to_s
    dt.strftime("%B #{day}, %Y").lstrip
  end
  
  def pretty_time(dt)
    dt.strftime('%l:%M%P').lstrip
  end
  
  def display_flash
    # flash_types = [:error, :warning, :info, :success]

    messages = (flash.keys.collect do |key|
      content_tag(:div, flash[key].html_safe, :class => "alert-message #{key}")
    end.join("\n"))
    if messages.size > 0
      content_tag(:div, messages.html_safe, :id => "flash")
    else
      ""
    end
  end
  
  def options_for_card_expiration_month(selected=nil)
    option_list = []
    months = Date::MONTHNAMES.dup
    months.delete(nil)
    months.each_with_index {|name, index| option_list << [('0' + (index + 1).to_s)[-2,2] + ' - ' + name, index + 1]}
    option_list.delete(nil)
    option_list.insert(0, ['', nil])
    options_for_select(option_list, selected)
  end

  def options_for_card_expiration_year(selected=nil)
    option_array = ((Date.today.year.to_s)..((Date.today.year + 10).to_s)).to_a
    option_array.insert(0, '')
    option_list = options_for_select(option_array, selected)
  end
  
  def dollar_amount(amt)
    sprintf('$%0.2f', amt)
  end
  
  def todays_date(args)
    Date.today >= Date.parse(args[:is_between]) && Date.today <= Date.parse(args[:and])
  end

end
