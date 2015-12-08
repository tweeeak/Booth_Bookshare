class SubjectsController < ApplicationController
  def index
    @subjects = Subject.all
  end

  def show
    @subject = Subject.find(params[:id])
  end

  def new
    @subject = Subject.new
  end

  def create
    @subject = Subject.new
    @subject.subject_number = params[:subject_number]
    @subject.subject_name = params[:subject_name]

    if @subject.save
      redirect_to "/subjects", :notice => "Subject created successfully."
    else
      render 'new'
    end
  end

  def edit
    @subject = Subject.find(params[:id])
  end

  def update
    @subject = Subject.find(params[:id])

    @subject.subject_number = params[:subject_number]
    @subject.subject_name = params[:subject_name]

    if @subject.save
      redirect_to "/subjects", :notice => "Subject updated successfully."
    else
      render 'edit'
    end
  end

  def destroy
    @subject = Subject.find(params[:id])

    @subject.destroy

    redirect_to "/subjects", :notice => "Subject deleted."
  end
end
