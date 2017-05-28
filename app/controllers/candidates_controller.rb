class CandidatesController < SecureController
	def index
		@candidates = Candidate.verified
	end

end