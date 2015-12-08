Rails.application.routes.draw do


  root "books#index"
  get "/mylistings", :controller => "listings", :action => "mylistings"
  get "/myinterests", :controller => "interests", :action => "myinterests"

  get "/books/new", :controller => "books", :action => "setup_new"
  get "/books/new_2", :controller => "books", :action => "new"

  get "/interests/new/:listing_id", :controller => "interests", :action => "setup_new"
  get "/interests/makeawishcometrue/:listing_id/:wishlist_id" , :controller => "interests", :action => "wishlist_new"
  get "/interests/contact/:interest_id", :controller => "interests", :action => "contact"
  get "/interests/giveup/:interest_id", :controller => "interests", :action => "giveup"
  get "/interests/returned/:interest_id", :controller => "interests", :action => "returned"

  get "/mywishlists", :controller => "wishlists", :action => "mywishlists"

  get "/interests/done/:interest_id", :controller => "interests", :action => "interest_done"

  # Routes for the Author resource:
  # CREATE
  post "/create_author", :controller => "authors", :action => "create"
  #------------------------------

  # Routes for the Interest resource:
  # CREATE
  post "/create_interest", :controller => "interests", :action => "create"

  # UPDATE
  get "/interests/:id/edit", :controller => "interests", :action => "edit"
  post "/update_interest/:id", :controller => "interests", :action => "update"

  # DELETE
  get "/delete_interest/:id", :controller => "interests", :action => "destroy"
  #------------------------------

  # Routes for the Wishlist resource:
  # CREATE
  get "/wishlists/new", :controller => "wishlists", :action => "new"
  post "/create_wishlist", :controller => "wishlists", :action => "create"

  # UPDATE
  get "/wishlists/:id/edit", :controller => "wishlists", :action => "edit"
  post "/update_wishlist/:id", :controller => "wishlists", :action => "update"

  # DELETE
  get "/delete_wishlist/:id", :controller => "wishlists", :action => "destroy"
  #------------------------------

  # Routes for the Listing resource:
  # CREATE
  get "/listings/new", :controller => "listings", :action => "new"
  post "/create_listing", :controller => "listings", :action => "create"

  # READ
  get "/listings", :controller => "listings", :action => "index"

  # UPDATE
  get "/listings/:id/edit", :controller => "listings", :action => "edit"
  post "/update_listing/:id", :controller => "listings", :action => "update"

  # DELETE
  get "/delete_listing/:id", :controller => "listings", :action => "destroy"
  #------------------------------

  # Routes for the Book resource:
  # CREATE
  post "/create_book", :controller => "books", :action => "create"

  # READ
  get "/books", :controller => "books", :action => "index"
  get "/books/:id", :controller => "books", :action => "show"
  #------------------------------

  devise_for :users

end
