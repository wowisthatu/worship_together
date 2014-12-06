class UserRide < ActiveRecord::Base
  belongs_to :user
  belongs_to :ride
  
  validates :user_id, presence: true
  validates :ride_id, presence: true
end
