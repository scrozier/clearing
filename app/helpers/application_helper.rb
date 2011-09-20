module ApplicationHelper

  def app_text_field_tag(field_name, label=nil)
    render '/helpers/text_field_tag', :field_name => field_name, :label => (label ? label : field_name.to_s.humanize)
  end
  
  def configurator(key)
    Clearing::Application.config.application[key]
  end

  def logo_image_for_header
    image_tag 'logo-dark-reduced-horizontal.gif', :style => 'float:left'
  end
  
  def pretty_date_time(dt)
    dt.strftime('%l:%M%P, %B %d, %Y').lstrip
  end
  
  def pretty_date(dt)
    dt.strftime('%B %d, %Y').lstrip
  end
  
  def pretty_time(dt)
    dt.strftime('%l:%M%P').lstrip
  end
  
end
