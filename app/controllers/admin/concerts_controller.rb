class Admin::ConcertsController < ApplicationController

  def index
    @concerts = Concert.all
  end
  
  def edit
    @concert = Concert.find(params[:id])
  end

  def update
    @concert = Concert.find(params[:id])
    @concert.update_attributes(params[:concert])
    render :show
  end
  
end
