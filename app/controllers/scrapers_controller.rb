class ScrapersController < ApplicationController

	def index
		@candidates = Candidate.unverified
	end

	def candidate_emails
		EmailCrawler.for_domain(params[:domain], limit: 10)
		puts params[:domain]
		redirect_to candidates_path
	end

end