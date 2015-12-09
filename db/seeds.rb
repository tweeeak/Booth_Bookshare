Interest.create!([
  {status_id: "3", prop_price: "30.0", user_id: 3, listing_id: 101},
  {status_id: "3", prop_price: "5.0", user_id: 3, listing_id: 104},
  {status_id: "3", prop_price: "10.0", user_id: 3, listing_id: 103},
  {status_id: "6", prop_price: "100.0", user_id: 3, listing_id: 110},
  {status_id: "4", prop_price: "2.0", user_id: 3, listing_id: 111},
  {status_id: "5", prop_price: "23.0", user_id: 1, listing_id: 112},
  {status_id: "3", prop_price: "33.0", user_id: 4, listing_id: 112}
])
Listing.create!([
  {status_id: "1", price: "100.0", sale_rent: "Sale", user_id: 6, book_id: 39},
  {status_id: "1", price: "10.0", sale_rent: "Rent", user_id: 6, book_id: 39},
  {status_id: "1", price: "100.0", sale_rent: "Sale", user_id: 6, book_id: 41},
  {status_id: "1", price: "15.0", sale_rent: "Rent", user_id: 6, book_id: 41},
  {status_id: "1", price: "200.0", sale_rent: "Sale", user_id: 6, book_id: 38},
  {status_id: "1", price: "25.0", sale_rent: "Rent", user_id: 6, book_id: 38},
  {status_id: "1", price: "30.0", sale_rent: "Sale", user_id: 6, book_id: 36},
  {status_id: "1", price: "15.0", sale_rent: "Rent", user_id: 6, book_id: 36},
  {status_id: "1", price: "40.0", sale_rent: "Sale", user_id: 1, book_id: 39},
  {status_id: "1", price: "9.0", sale_rent: "Rent", user_id: 1, book_id: 39},
  {status_id: "1", price: "30.0", sale_rent: "Sale", user_id: 1, book_id: 41},
  {status_id: "1", price: "5.0", sale_rent: "Rent", user_id: 1, book_id: 41},
  {status_id: "2", price: "250.0", sale_rent: "Sale", user_id: 3, book_id: 48},
  {status_id: "1", price: "35.0", sale_rent: "Rent", user_id: 3, book_id: 48},
  {status_id: "1", price: "200.0", sale_rent: "Sale", user_id: 3, book_id: 48},
  {status_id: "1", price: "14.0", sale_rent: "Sale", user_id: 3, book_id: 12},
  {status_id: "1", price: "150.0", sale_rent: "Sale", user_id: 5, book_id: 48},
  {status_id: "1", price: "123.0", sale_rent: "Sale", user_id: 1, book_id: 43},
  {status_id: "1", price: "12.0", sale_rent: "Rent", user_id: 1, book_id: 37},
  {status_id: "1", price: "43.0", sale_rent: "Sale", user_id: 3, book_id: 47}
])
Wishlist.create!([
  {status_id: "1", price: "100.0", sale_rent: "Sale", user_id: 6, book_id: 48},
  {status_id: "1", price: "10.0", sale_rent: "Rent", user_id: 6, book_id: 48},
  {status_id: "1", price: "11.0", sale_rent: "Rent", user_id: 1, book_id: 48},
  {status_id: "1", price: "50.0", sale_rent: "Sale", user_id: 4, book_id: 48},
  {status_id: "1", price: "20.0", sale_rent: "Sale", user_id: 3, book_id: 37},
  {status_id: "1", price: "10.0", sale_rent: "Rent", user_id: 4, book_id: 37}
])
