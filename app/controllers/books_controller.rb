class BooksController < ApplicationController
  def index
    @books = Book.all.order("subject_id ASC")
  end

  def show
    #Find Book
    @book = Book.find(params[:id])
    #Find Active Listings
    @listings = @book.listings.where.not({ :status_id => "2" }).order("sale_rent ASC , price ASC")
    @wishlists = @book.wishlists.where.not({ :status_id => "2" }).order("sale_rent ASC , price DESC")
    #Find Active Wishlists
  end

  def setup_new
    #Page before calling new and create books. Populate fields based on isbn
    render("setup_new.html.erb")
  end

  def new
   #Check google API to see if book exists
   if get_book_details(params[:isbn13].gsub(/[^0-9]/, '')) == true then
    if not Book.find_by({ :isbn13 => params[:isbn13].gsub(/[^0-9]/, '') }).present? then
      @book = Book.new
      @book.isbn13 = params[:isbn13].gsub(/[^0-9]/, '')
      get_book_details(@book.isbn13)
      @book.description = @description
      @book.publisher   = @publisher
      @book.artwork     = @artwork
      @book.year        = @published_date
      @book.title       = @title
      @book.isbn10      = @isbn10
      #Let's add missing authors
      insert_authors(@authors)
    else
      redirect_to "/books/"+Book.find_by({ :isbn13 => params[:isbn13].gsub(/[^0-9]/, '') }).id.to_s, :alert => "Book already exists."
    end
   else
     redirect_to :back, :alert => "ISBN not found. Please try again."
   end
  end

  def create
    @book = Book.new
    @book.description = params[:description]
    @book.publisher = params[:publisher]
    @book.isbn13 = params[:isbn13]
    @book.artwork = params[:artwork]
    @book.subject_id = params[:subject_id]
    @book.year = params[:year]
    @book.title = params[:title]
    @book.isbn10 = params[:isbn10]

    if @book.save
      #only after book is added can we add links to authorbook
      a = insert_author_book(@book.isbn13)
      redirect_to "/books", :notice => "Book created successfully."
    else
      render 'new'
    end
  end

  def edit
    @book = Book.find(params[:id])
  end

  def update
    @book = Book.find(params[:id])

    @book.description = params[:description]
    @book.publisher = params[:publisher]
    @book.isbn13 = params[:isbn13]
    @book.artwork = params[:artwork]
    @book.subject_id = params[:subject_id]
    @book.year = params[:year]
    @book.title = params[:title]
    @book.isbn10 = params[:isbn10]

    if @book.save
      redirect_to "/books", :notice => "Book updated successfully."
    else
      render 'edit'
    end
  end

  def destroy
    @book = Book.find(params[:id])

    @book.destroy

    redirect_to "/books", :notice => "Book deleted."
  end
end
