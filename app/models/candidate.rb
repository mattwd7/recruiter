class Candidate < ApplicationRecord
	scope :verified, -> { where(verified: true) }
	scope :unverified, -> { where(verified: false) }

	validates_presence_of :email
	validates_uniqueness_of :email, case_sensitive: false
end