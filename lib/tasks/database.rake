namespace :database do
  desc "remove bad data from testing"
  task destroy_listing_data: :environment do
  	Company.destroy_all
  	Listing.destroy_all
  	Tag.destroy_all
  	ListingTag.destroy_all
  end
end
