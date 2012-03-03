class Admin::ReportsController < ApplicationController

  before_filter :find_concert

  def will_call_list
    render :layout => 'printed_ticket'
  end

  def find_concert
    @concert = Concert.find(params[:id])
  end
  
end