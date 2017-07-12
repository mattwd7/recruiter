class Listing < ActiveRecord::Base
	has_many :listing_tags, dependent: :destroy
	has_many :tags, through: :listing_tags

	belongs_to :company

	def create_tags(tag_names)
		tag_names.each do |name|
			self.tags << Tag.find_or_create_by(name: name)
		end
	end
end