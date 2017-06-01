namespace :database do
	namespace :destroy do
	  desc "remove company data while testing crawlers"
	  task listings: :environment do
	  	Company.destroy_all
	  	Listing.destroy_all
	  	ListingTag.destroy_all
	  end
	end
end
