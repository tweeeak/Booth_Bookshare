class InterestsController < ApplicationController
  def index
    @interests = Interest.all
  end

  def show
    @interest = Interest.find(params[:id])
  end

  def setup_new
    @interest = Interest.new
    @listing  = Listing.find(params[:listing_id])
  end

  def new
    @interest = Interest.new
  end

  def myinterests
    @submitted_interests = Interest.where({:user_id => current_user.id.to_s, :status_id => "3"}).joins(:book).order("books.title ASC, listings.sale_rent ASC, interests.prop_price DESC")

    #Awaiting Delivery are those bids on status 4 (Accepted) with listing 2 (Active)
    @accepted_interests  = Interest.where({:user_id => current_user.id.to_s, :status_id => "4"}).joins(:book).order("books.title ASC, interests.prop_price DESC")
    #Declined Bids are those bids on status 5 with listing 2
    @declined_interests  = Interest.where({:user_id => current_user.id.to_s, :status_id => "5"}).joins(:book).order("books.title ASC, listings.sale_rent ASC, interests.prop_price DESC")
    #Expired Bids have status 10, regardless of listing status (we want to be able to see unless you ignore)
    #Also selecting status 9 (listing deleted) (we want to be able to see unless you ignore)
    @expired_interests  = Interest.where({:user_id => current_user.id.to_s, :status_id => ["9","10"]}).joins(:book).order("books.title ASC, listings.sale_rent ASC, interests.prop_price DESC")
    #Rented Books have status 6
    @rented_interests  = Interest.where({:user_id => current_user.id.to_s, :status_id => "6"}).joins(:book).order("books.title ASC, listings.sale_rent ASC, interests.prop_price DESC")

  end

  def interest_done
    #Checks before:
    #user is list owner
    #interest is accepted (4)
    @interest = Interest.find(params[:interest_id])
    if @interest.present? && @interest.user_id == current_user.id && @interest.status_id == 4 then
      #Purpose: change status to "finalized" & inactivate list
      @interest.status_id = 7
      if @interest.save then
        @interest.listing.status_id = 2
        if not(@interest.save) then
          redirect_to :back, :alert => "Error updating listing. Contact admin."
        else
          redirect_to :back, :notice => "Listing cancelled successfuly."
        end
      else
        redirect_to :back, :alert => "Error updating interest. Contact admin."
      end
    else
      redirect_to :back, :alert => "One of 3 errors: Not list owner; interest not found, interest not accepted."
    end
  end

  def giveup
    #Checks before:
    #user is list owner
    #interest is accepted (4)
    @interest = Interest.find(params[:interest_id])
    if @interest.present? && @interest.listing.user_id == current_user.id && @interest.status_id.to_s == 4.to_s then
      #Purpose: change status to "gave up" & inactivate list
      @interest.status_id = 8
      if @interest.save then
        @interest.listing.status_id = 2
        if not(@interest.listing.save) then
          redirect_to :back, :alert => "Error updating listing. Contact admin."
        else
          redirect_to :back, :notice => "Listing cancelled successfuly."
        end
      else
        redirect_to :back, :alert => "Error updating interest. Contact admin."
      end
    else
      redirect_to :back, :alert => "One of 3 errors: Not list owner; interest not found, interest not accepted. "
    end
  end

  def contact
    @interest = Interest.find(params[:interest_id])
    @listing  = @interest.listing
  end

  def can_have_int_created?(listing,userid)
    if listing.interests.find_by(:user_id => userid).present? then return false end
    if not(open_for_bid?(listing))then return false end
    return true
  end

  def wishlist_new
    @listing = Listing.find(params[:listing_id])
    @wl = Wishlist.find(params[:wishlist_id])
    #Update interest to 4(cant use'pure can_bid)
    if @listing.interests.present? then
      redirect_to "/mylistings", :notice => "Listing created successfully"
    else
      if can_have_int_created?(@listing,@wl.user_id) && (@listing.user_id.to_s == current_user.id.to_s || @wl.user_id.to_s == current_user.id.to_s) then
        @interest = Interest.new
        @interest.status_id = 3
        @interest.prop_price = @wl.price
        @interest.user_id = @wl.user_id
        @interest.listing_id = @listing.id
        @interest.save

        render("wishlist_new.html.erb")
      else
        redirect_to :back, :alert => "Couldn't Create Interest. Contact Admin."
      end
    end
  end

  def create

    listing = Listing.find(params[:listing_id])

    if can_bid?(listing) && (listing.user_id.to_s == current_user.id.to_s || params[:user_id] == current_user.id.to_s) then

      #Need to treat for duplicade bids. Each listing can only have 1 bid from each user.
      #can't bid on own listing
      @interest = Interest.new
      @interest.status_id = params[:status_id]
      @interest.prop_price = params[:prop_price].scan(/[.0-9]/).join().to_f
      @interest.user_id = params[:user_id]
      @interest.listing_id = params[:listing_id]

      if @interest.save
        if request.referer.include? "/interests/new/" then
          redirect_to "/myinterests", :notice => "Interest created successfully."
        else
          redirect_to :back, :notice => "Interest created successfully."
        end
      else
        render 'new'
      end

    else
      redirect_to :back, :notice => "You cannot bid on this listing again. Error"
    end
  end

  def edit
    @interest = Interest.find(params[:id])
  end

  def mass_update_to_expired(userid,bookid,listid)
    rt = 0
    bk = Book.find(bookid)
    # Set all interestee's interests for book to "expired"
    bk.listings.where({:status_id => 1.to_s}).where.not({:id => listid}).each do |blist|
      blist.interests.where({:user_id => userid}).each do |interest|
        interest.status_id = 10.to_s
        if not(interest.save) then rt -= 100 end
      end
      #Set other lists for book for the user to inactive
    end
    bk.listings.where({:status_id => 1.to_s, :user_id => current_user.id.to_s}).where.not({:id => listid}).each do |blist|
      blist.status_id = 2
      blist.save
    end



    # Set all other interests for the list to expired
    lt = Listing.find(listid)
    lt.interests.where.not({:user_id => userid}).each do |interest|
      interest.status_id = 10.to_s
      if not(interest.save) then rt -= 10 end
    end
    # Set wishlists for user/book to inactive
    if Wishlist.where({:user_id => userid, :book_id => bookid, :status_id => 1.to_s}).present? then
      wl = Wishlist.where({:user_id => userid, :book_id => bookid, :status_id => 1.to_s})
      wl.each do |wishlist|
        wishlist.status_id = 2.to_s
        if not(wishlist.save) then rt -= 1000 end
      end
    end

    return rt
  end

  #def returned
  #  #Flips book from rented to returned (finalized)
  #  #Checks: user must be list owner. interest must be rented (6)
  #  @interest = Interest.find(params[:interest_id])
  #  if @interest.present? && @interest.listing.user_id.to_s == current_user.id.to_s then
  #    if @interest.status_id.to_s == 6.to_s then
  #      render("returned.html.erb")
  #    else
  #      redirect_to "/mylistings", :notice => "Book return confirmed"
  #    end
  #  else
  #    redirect_to :back, :alert => "Interest not found or user unauthorized."
  #  end
  #end

  def returned
    #Flips book from rented to returned (finalized)
    #Checks: user must be list owner. interest must be rented (6)
    @interest = Interest.find(params[:interest_id])
    if @interest.present? && @interest.listing.user_id.to_s == current_user.id.to_s then
      if @interest.status_id.to_s == 6.to_s then
        render("returned.html.erb")
      else
        #Now we have right status, but need to inactivate list
        @interest.listing.status_id = 2
        @interest.listing.save
        redirect_to "/mylistings", :notice => "Book return confirmed"
      end
    else
      redirect_to :back, :alert => "Interest not found or user unauthorized."
    end
  end

  def update
    @interest = Interest.find(params[:id])
    errs = 0 #will track errors
    # Have to be careful with the sequence of events.
    # If status_id is 4 (set to accept), I must validate and do a bunch of stuff.
    if params[:status_id].present? && params[:status_id]== 4.to_s then
      # Previous status MUST be 3
      # Only list owner can perform the change
      if @interest.status_id == 3.to_s && @interest.listing.user.id == current_user.id then
        # Safety check: make sure there are no other 4s for interest user / book for active lists
        @interest.listing.book.listings.where({:status_id => 1.to_s}).each do |blist|
          if blist.interests.find_by({:status_id => 4.to_s, :user_id => @interest.user_id}) then
            errs -= 33
          end
        end
        # Set all interestee's interests for book to "expired"
        # Set all other submitted interests for list to declined
        # Need to deactivate wishlists for the book for that user too.
        errs += mass_update_to_expired(@interest.user_id,@interest.listing.book.id,@interest.listing_id)
      else
        errs = -1
      end
    end
    if errs == 0 then
      @interest.status_id = params[:status_id]
      @interest.prop_price = params[:prop_price].scan(/[.0-9]/).join().to_f
      @interest.user_id = params[:user_id]
      @interest.listing_id = params[:listing_id]

      if @interest.save
        if request.referer.end_with? "edit" then
          redirect_to "/myinterests", :notice => "Listing updated successfully."
        else
          redirect_to :back, :notice => "Interest updated successfully."
        end
      else
        render 'edit'
      end
    else
      redirect_to :back, :alert => "Interest can't be updated. Contact Admin. Return code: "+errs.to_s
    end
  end

  def destroy
    @interest = Interest.find(params[:id])

    @interest.destroy

    redirect_to :back, :notice => "Interest deleted."
  end
end
