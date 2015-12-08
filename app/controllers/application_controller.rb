class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protect_from_forgery with: :exception
  before_action :authenticate_user!

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :username
    devise_parameter_sanitizer.for(:sign_up) << :email
  end

  helper_method :can_bid?, :can_rebid?, :can_edit?, :open_for_bid?, :can_create_wishlist?

  def found_book(details)
    if details[:totalItems] == 0 then
      return false
    else
      return true
    end
  end

  def get_book_details(isbn)
    #Get raw data and clean it
    api_address = 'https://www.googleapis.com/books/v1/volumes?q=isbn:'
    parsed_address = URI.parse(URI.encode(api_address + isbn.to_s))
    require 'open-uri'
    raw_details = open(parsed_address).read
    require 'json'
    @details = JSON.parse(raw_details, symbolize_names: true )
    if found_book(@details) ==true then
    #Get information fields
    @title     = @details[:items][0][:volumeInfo][:title]
    @publisher = @details[:items][0][:volumeInfo][:publisher]
    @published_date = @details[:items][0][:volumeInfo][:publishedDate]
    @description = @details[:items][0][:volumeInfo][:description]
    #need a check to see if they exist. Would be nice to not depend on it. Actually I dont think we do. We can just save wichever isbn and display what we have.
    if @details[:items][0][:volumeInfo][:industryIdentifiers][0][:type] == "ISBN_10" then
      @isbn10  = @details[:items][0][:volumeInfo][:industryIdentifiers][0][:identifier]
      @isbn13  = @details[:items][0][:volumeInfo][:industryIdentifiers][1][:identifier]
    else
      @isbn13  = @details[:items][0][:volumeInfo][:industryIdentifiers][0][:identifier]
      @isbn10  = @details[:items][0][:volumeInfo][:industryIdentifiers][1][:identifier]
    end
    @artwork = @details[:items][0][:volumeInfo][:imageLinks][:thumbnail]
    @authors = @details[:items][0][:volumeInfo][:authors]
      return true
    else
      return false
    end
  end

  def insert_authors(authors)
    # ASSUMES EXISTENCE WAS VALIDATED BEFOREHAND. THIS SHOULD BE CALLED
    # FROM NEW BOOKS FUNCTION AFTER ALL CHECKS WERE MADE.
    authors.each do |author|
      if not Author.find_by({ :author_name => author }).present? then
        #Let's create author
        a = Author.new
        a.author_name = author
        if not a.save
          redirect_to :back, :alert => "Error creating author for this book."
        end
      end
    end
  end

  def insert_author_book(isbn)
     # Must get author link again
     get_book_details(isbn)
     # Now let's get the book
     bk = Book.find_by({:isbn13 => @isbn13})
     @authors.each do |author|
      #find actual author in db
      a = Author.find_by({ :author_name => author })
      if not a.bookauthors.where({ :book_id => bk.id }).present? then
        bka = Bookauthor.new
        bka.book_id = bk.id
        bka.author_id = a.id
        bka.save
      end
     end
  end

 def open_for_bid?(listing)
    # listing must be open for bid (no interests from 4 or above)
    if listing.interests.find_by(:status_id => [4,6,7,8,9]).present? then return false end
    # Failsafe: listing must be active
    if listing.status_id == 2 then return false end
    return true
  end

  def can_edit?(listing)
    if not(open_for_bid?(listing)) then return false end
    # User has to be owner
    if current_user.id != listing.user_id then return false end
    return true
  end

  def can_bid?(listing)
    # current user must be different than listing user
    if current_user.id == listing.user_id then return false end
    # must not have another interest in listing
    if listing.interests.find_by(:user_id => current_user.id).present? then return false end
    # Listing must be open for bid
    if not(open_for_bid?(listing))then return false end
    return true
  end

  def can_rebid?(listing)
    # current user must be different than listing user
    if current_user.id == listing.user_id then return false end
    # must have another interest in listing
    if not(listing.interests.find_by(:user_id => current_user.id).present?) then return false end
    # Listing must be open for bid
    if not(open_for_bid?(listing))then return false end
    return true
  end

  def can_create_wishlist?(book_id, sale_rent)
    #Must not own book (no active lists)
    #Must not already have an active wishlist of same type
    if Listing.where({:status_id => "1", :user_id => current_user.id, :book_id => book_id}).present? || Wishlist.where({:status_id => "1", :user_id => current_user.id, :book_id => book_id, :sale_rent => sale_rent}).present? then
      return false
    else
      return true
    end
  end

end
