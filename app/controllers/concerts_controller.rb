class ConcertsController < ApplicationController
  
  def intro
  end
  
  def show
    @concert = Concert.where(:ident_string => params[:ident_string]).first
  end
  
  def print
    @concert = Concert.where(:ident_string => params[:ident_string]).first
    render :layout => 'printed_form'
  end
  
end
