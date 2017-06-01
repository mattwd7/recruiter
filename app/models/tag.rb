class Tag < ActiveRecord::Base
	has_many :listing_tags
	has_many :listings, through: :listing_tags
	
	has_many :candidate_tags
	has_many :candidates, through: :candidate_tags
end