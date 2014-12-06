class Ride < ActiveRecord::Base
  belongs_to :user
  belongs_to :service
  has_many :user_rides
  has_many :users, through: :user_rides
  
  validates :user_id, presence: true
  validates :service_id, presence: true
end
