class Candidate < ApplicationRecord
	scope :verified, -> { where(verified: true) }
	scope :unverified, -> { where(verified: false) }

	validates_presence_of :email
	validates_uniqueness_of :email, case_sensitive: false

  has_many :candidate_tags, dependent: :destroy
  has_many :tags, through: :candidate_tags

	def create_tags(tag_names)
		tag_names.each do |name|
			self.tags << Tag.find_by_name(name)
		end
	end
end