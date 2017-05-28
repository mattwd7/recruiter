class Candidate < ApplicationRecord
	scope :verified, -> { where(verified: true) }
	scope :unverified, -> { where(verified: false) }
end