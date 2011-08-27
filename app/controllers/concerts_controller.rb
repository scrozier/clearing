class ConcertsController < ApplicationController
  
  def intro
  end
  
  def show
    @concert_insert = params[:concert_name]
  end
  
end
