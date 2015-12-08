class StatusesController < ApplicationController
  def index
    @statuses = Status.all
  end

  def show
    @status = Status.find(params[:id])
  end

  def new
    @status = Status.new
  end

  def create
    @status = Status.new
    @status.status = params[:status]

    if @status.save
      redirect_to "/statuses", :notice => "Status created successfully."
    else
      render 'new'
    end
  end

  def edit
    @status = Status.find(params[:id])
  end

  def update
    @status = Status.find(params[:id])

    @status.status = params[:status]

    if @status.save
      redirect_to "/statuses", :notice => "Status updated successfully."
    else
      render 'edit'
    end
  end

  def destroy
    @status = Status.find(params[:id])

    @status.destroy

    redirect_to "/statuses", :notice => "Status deleted."
  end
end
