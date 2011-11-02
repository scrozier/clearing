class Admin::ReportsController < ApplicationController

  def reservations
    @concert = Concert.find(params[:id])
  end

end