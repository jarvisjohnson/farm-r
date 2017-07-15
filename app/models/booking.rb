# == Schema Information
#
# Table name: bookings
#
#  id             :integer          not null, primary key
#  transaction_id :integer
#  start_on       :date
#  end_on         :date
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_bookings_on_transaction_id  (transaction_id)
#

class Booking < ApplicationRecord
  belongs_to :tx, class_name: "Transaction", foreign_key: "transaction_id"

  def self.columns
    super.reject { |c| c.name == "end_on_exclusive" }
  end

  def self.bookings(listing_id,startDate,endDate)
    bookings = 
      Booking
      .joins("LEFT JOIN transactions ON `transactions`.`id` = `bookings`.`transaction_id`")
      .where("((`bookings`.`start_on` >= :startdate OR `bookings`.`start_on` <= :enddate) 
               AND ((`bookings`.`end_on` >= :startdate OR `bookings`.`end_on` <= :enddate))) 
               AND (`transactions`.`listing_id` = :lid)
               AND (transactions.current_state != :rej AND transactions.current_state != :canceled)
               ", startdate: startDate, enddate: endDate, lid:listing_id, rej: 'rejected', canceled:'canceled')
    bookingdate ||= []
    bookings.each do |booking|
      avilstart = booking.start_on
      avilend   = booking.end_on
      if booking.start_on < startDate 
        avilstart = startDate
      end
      if booking.end_on > endDate 
        avilend = endDate
      end
      bookingdate << (avilstart..avilend).map {|d| d.strftime("%-d-%-m-%Y")}  
      bookingdate.flatten!
    end
    bookingdate
  end
end
