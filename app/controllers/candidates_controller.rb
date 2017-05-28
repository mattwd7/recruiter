class CandidatesController < ApplicationController

	def index
		@candidates = Candidate.verified
	end

end