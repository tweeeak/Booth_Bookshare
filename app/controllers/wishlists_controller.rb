class WishlistsController < ApplicationController
  def index
    @wishlists = Wishlist.all
  end

  def show
    @wishlist = Wishlist.find(params[:id])
  end

  def new
    @wishlist = Wishlist.new

    @wishlist.book_id = params[:book_id]

    if@wishlist.book.present? && Wishlist.where({:user_id => current_user.id, :book_id =>@wishlist.book.id, :status_id => "1"}).present? then
      @mylists = Wishlist.where({:user_id => current_user.id, :book_id =>@wishlist.book.id, :status_id => "1"})
    end

    if params[:isbn].present? then
      if Book.where({:isbn13 => params[:isbn]}).present? then
        @wishlist.book_id = Book.find_by({:isbn13 => params[:isbn]}).id
        @flag = true
      else
        redirect_to :back, :alert => "Book not found. Maybe you should add it."
      end
    else

      if params[:book_id].present? && Book.where({:id =>@wishlist.book_id}).present? then
        @flag = true
      else
        @flag = false
      end
    end
  end

  def create
    @wishlist = Wishlist.new
    @wishlist.status_id = params[:status_id]
    @wishlist.price = params[:price].scan(/[.0-9]/).join().to_f
    @wishlist.sale_rent = params[:sale_rent]
    @wishlist.user_id = params[:user_id]
    @wishlist.book_id = params[:book_id]

    if can_create_wishlist?(params[:book_id], params[:sale_rent]) then

      if @wishlist.save
        redirect_to "/mywishlists", :notice => "Wishlist created successfully."
      else
        render 'new'
      end

    else
      redirect_to "/mywishlists", :alert => "Could not create Wishlist. You either already have the book, or have a current wishlist of the same time for this book."
    end
  end

  def edit
    @wishlist = Wishlist.find(params[:id])
  end

  def update
    @wishlist = Wishlist.find(params[:id])

    @wishlist.status_id = params[:status_id]
    @wishlist.price = params[:price].scan(/[.0-9]/).join().to_f
    @wishlist.sale_rent = params[:sale_rent]
    @wishlist.user_id = params[:user_id]
    @wishlist.book_id = params[:book_id]

    if @wishlist.save
      redirect_to "/mywishlists", :notice => "Wishlist updated successfully."
    else
      render 'edit'
    end
  end

  def destroy
    @wishlist = Wishlist.find(params[:id])

    @wishlist.destroy

    redirect_to "/mywishlists", :notice => "Wishlist deleted."
  end

  def mywishlists
    #Ready and Self Explanatory
    @expired_wishlists = User.find(current_user.id.to_s).wishlists.where({:status_id => "2"}).order("updated_at DESC")

    @active_wishlists = User.find(current_user.id.to_s).wishlists.where({:status_id => "1"}).joins(:book).order("books.title ASC")

    # Do we have wishlists with suitable listings?
    @listing_available  = []
    @available_listings = []
    @wl_w_lists         = []
    @active_wishlists.each do |wl|
      #if exists at least 1 active listing
      if wl.listings.where({:status_id => "1"}).present? then
        wl.listings.where({:status_id => "1"}).each do |list|
          #is it cheaper? Are they the same type?
          if wl.price - list.price >= 0 && wl.sale_rent == list.sale_rent then
            #Does it have accepted or rented interests?
            if not(list.interests.where(:status_id => [4,6,7,8]).present?)  then
              @listing_available.push(wl)
              @available_listings.push(list.id)
              @wl_w_lists.push(wl.id)
            end
          end
        end
      end
    end

    # Do we have wishlists with not a single suitable listing?
    # I know I could have reused the code above with elses, but the volume shouldn't be too high and this is simpler to think about.
    @nonlisting_available  = []
    @nonavailable_listings = []
    if @wl_w_lists.count == 0 then @wl_w_lists.push(-1) end
    @active_wishlists.where('wishlists.id  NOT IN (?)', @wl_w_lists).each do |wl|
      #if exists at least 1 active listing and is not on the wl_w_lists
      if wl.listings.where({:status_id => "1"}).present? then
        wl.listings.where({:status_id => "1"}).each do |list|
          #is it more expensive?? Are they the same type?
          if wl.price - list.price < 0 && wl.sale_rent == list.sale_rent then
            #Does it have accepted or rented interests?
            if not(list.interests.where(:status_id => [4,6,7,8]).present?)  then
              @nonlisting_available.push(wl)
              @nonavailable_listings.push(list.id)
            end
          end
        end
      end
    end

    # Do we have wishlists that have absolutely no listings?
    @nolist_wishlists = []
    @active_wishlists.each do |wl|
      if not(wl.listings.where({:status_id => "1",:sale_rent => wl.sale_rent}).present?) then
        @nolist_wishlists.push(wl)
      end
    end

  end


end
