require 'CSV'

class Admin::MiscellaneousController < ApplicationController

  def enter_walkups
    @concert = Concert.find(params[:id])
  end
  
  def add_walkup
    p = Patron.find_or_create_by_email(params[:patron])
    unless p
      flash[:error] = 'Did not work.' + object_errors(p)
      redirect_to admin_enter_walkups_path(params[:concert_id]) and return
    end
    
    if p.reservations.where(:concert_id => params[:concert_id]).first
      flash[:info] = 'Already in system.'
      redirect_to admin_enter_walkups_path(params[:concert_id]) and return
    end
    
    r = Reservation.create(:concert_id => params[:concert_id],
                           :patron_id => p.id)
    p.reservations << r
    flash[:success] = 'Done.'
    redirect_to admin_enter_walkups_path(params[:concert_id]) and return
  end
  
  def create_patron_csv
    csv_string = %Q["First Name","Last Name","Email"<br />]
    for patron in Patron.all
      csv_string << %Q["#{patron.first_name}","#{patron.last_name}","#{patron.email}"<br />]
    end
    render :text => csv_string
  end

end