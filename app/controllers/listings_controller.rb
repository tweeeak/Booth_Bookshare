class ListingsController < ApplicationController


  def can_delete?(listing)
    # user must be owner
    if listing.user_id != current_user.id then return -1 end
    # List must be open for bid
    if not(open_for_bid?(listing))then return -2 end
    return 0
  end

  def index
    #Show only active listings
    @listings = Listing.all.where({:status_id => 1})
  end

  def show
    @listing = Listing.find(params[:id])
  end

  def mylistings
    @listings = Listing.where({:user_id => current_user.id, :status_id => 1})
    #@rlistings = Listing.where({:user_id => current_user.id, :status_id => 2})
  end

  def new
    @listing = Listing.new

    @listing.book_id = params[:book_id]

    if @listing.book.present? && Listing.where({:user_id => current_user.id, :book_id => @listing.book.id, :status_id => 1.to_s}).present? then
      @mylists = Listing.where({:user_id => current_user.id, :book_id => @listing.book.id, :status_id => 1.to_s})
    end

    if params[:isbn].present? then
      if Book.where({:isbn13 => params[:isbn]}).present? then
        @listing.book_id = Book.find_by({:isbn13 => params[:isbn]}).id
        @flag = true
      else
        redirect_to :back, :alert => "Book not found. Maybe you should add it."
      end
    else

      if params[:book_id].present? && Book.where({:id => @listing.book_id}).present? then
        @flag = true
      else
        @flag = false
      end
    end
  end

  def create
    @listing = Listing.new
    @listing.status_id = params[:status_id]
    @listing.price = params[:price].scan(/[.0-9]/).join().to_f
    @listing.sale_rent = params[:sale_rent]
    @listing.user_id = params[:user_id]
    @listing.book_id = params[:book_id]

    #Can user create listing?
    if not(can_create_listing?(@listing)) then redirect_to :back, :alert => "You are either not the owner of the list, or already have an active listing of that category, or have any list for the same book still in progress (accepted interested/rented), or have a wishlist for this book. Clear your current listings/wishlists for this book before creating new ones."
    else
      #before saving we should expire other listings
      if params[:wishlist_id].present? then
        Listing.where({:status_id =>"1",:user_id => params[:user_id], :book_id => params[:book_id]}).each do |list|
          retcode = 0
          # Safety Check: Can we delete?
          retcode = can_delete?(list)
          # Make interests "Listing Deleted"
          if not(mark_interests_as_ld(list)) then redirect_to :back, :alert => "Error marking interests. Contact Admin." end
          # Change listing status to inactive
          list.status_id = "2"
          if not(list.save) then redirect_to :back, :alert => "Couldn't mark listing as inactive. Contact Admin." end
          if retcode == -1 then redirect_to :back, :alert => "Only the list owner can delete listing." end
          if retcode == -2 then redirect_to :back, :alert => "Can't delete listings after interest was accepted." end

        end
      end

      if @listing.save
        #if it has a wishlist must do wishlist routine.
        if params[:wishlist_id].present? then
          # At this point I have a listing, a wishlist, but no interest.
          # Must create interest, update it to 4, fulfill wishlist and put listing on it
          redirect_to "/interests/makeawishcometrue/"+@listing.id.to_s+"/"+params[:wishlist_id].to_s
        else
          redirect_to "/mylistings", :notice => "Listing created successfully."
        end
      else
        render 'new'
      end
    end
  end

  def edit
    @listing = Listing.find(params[:id])
  end

  def update
    @listing = Listing.find(params[:id])

    @listing.status_id = params[:status_id]
    @listing.price = params[:price].scan(/[.0-9]/).join().to_f
    @listing.sale_rent = params[:sale_rent]
    @listing.user_id = params[:user_id]
    @listing.book_id = params[:book_id]

    if @listing.save
      if request.referer.end_with? "edit" then
        redirect_to "/mylistings", :notice => "Listing updated successfully."
      else
        redirect_to :back, :notice => "Listing updated successfully."
      end
    else
      render 'edit'
    end
  end

  def mark_interests_as_ld(listing)
    listing.interests.each do |interest|
      interest.status_id = 9
      if not(interest.save) then return false end
    end
    return true
  end

  def destroy
    retcode = 0
    # Not really deleting.
    listing = Listing.find(params[:id])
    # Safety Check: Can we delete?
    retcode = can_delete?(listing)
    # Make interests "Listing Deleted"
    if not(mark_interests_as_ld(listing)) then redirect_to :back, :alert => "Error marking interests. Contact Admin." end
    # Change listing status to inactive
    listing.status_id = "2"
    if not(listing.save) then redirect_to :back, :alert => "Couldn't mark listing as inactive. Contact Admin." end
    if retcode == -1 then redirect_to :back, :alert => "Only the list owner can delete listing." end
    if retcode == -2 then redirect_to :back, :alert => "Can't delete listings after interest was accepted." end

    redirect_to "/mylistings", :notice => "Listing deleted."
  end

  def can_create_listing?(listing)
    if listing.user_id != current_user.id then return false end
    #Can't have active wishlists for the same book.
    if listing.book.wishlists.where({:status_id => "1",:user_id => current_user.id}).present? then return false end
    # No list of same type active
    if listing.book.listings.where({:user_id => current_user.id, :sale_rent => listing.sale_rent, :status_id => 1}).present? then
      return false
    else
      #No list of different type active with accepted/rented bid
      if listing.book.listings.find_by({:user_id => current_user.id,:status_id => 1}).present? && listing.book.listings.find_by({:user_id => current_user.id,:status_id => 1}).interests.present? &&listing.book.listings.find_by({:user_id => current_user.id,:status_id => 1}).interests.find_by(:status_id => [4,6]).present? then
        return false
      end
    end
    return true
  end



  #Additional Listing methods were posted in application_controller.rb because they are
  #required outside of listings.

end
