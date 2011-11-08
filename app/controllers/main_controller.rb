class MainController < ApplicationController
  
  def home
  end
  
  def static_image
    @image_name = params[:image_name]
    render :layout => false
  end
  
end