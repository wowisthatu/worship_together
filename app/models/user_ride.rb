class UserRide < ActiveRecord::Base
  belongs_to :user
  belongs_to :ride
end
