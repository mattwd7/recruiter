class Company < ActiveRecord::Base
	has_many :listings

	def self.find_or_create_with(attrs)
		company = Company.find_or_initialize_by(
			name: attrs[:name]
		)

		unless company.id
			company.assign_attributes(**attrs)
			company.save
		end

		company
	end

	def create_listing_if_new(attrs, tag_names)
		unless listings.where(title: attrs[:title]).exists?
			self.listings
				.create(attrs)
				.create_tags(tag_names)
		end
	end
end