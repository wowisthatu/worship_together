class ServicesController < ApplicationController
  
  def index
    order_param = (params[:order] || :Day).to_sym
    ordering = case order_param
    when :Time
      :start_time
    when :Day
      :day_of_week
    end
    days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", nil]
    if ordering == :start_time
      @services = Service.order(ordering)
    else
      @services = Service.all.sort_by {|s| days.index(s.day_of_week)}
    end
  end

end
