class Candidate < ApplicationRecord
	scope :unverified, -> { where(verified: false) }
end