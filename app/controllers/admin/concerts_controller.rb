class Admin::ConcertsController < ApplicationController

  def index
    @concerts = Concert.all
  end
  
  def edit
    @concert = Concert.find(params[:id])
  end
  
end
