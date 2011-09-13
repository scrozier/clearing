class ConcertsController < ApplicationController
  
  def intro
  end
  
  def show
    @concert = Concert.where(:ident_string => params[:ident_string]).first
  end
  
end
