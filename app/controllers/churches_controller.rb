class ChurchesController < ApplicationController
  def index
    @churches = Church.all
  end

  def new
    @church = Church.new
  end

  def show
    @church = Church.find(params[:id])
  rescue
    flash[:danger] = "Unable to find church"
    redirect_to churches_path
  end
 end
