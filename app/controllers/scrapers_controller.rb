class ScrapersController < ApplicationController

	def index
		@candidates = Candidate.unverified
	end

	def candidate_emails
		crawler = EmailCrawler.for_domain(params[:domain], limit: params[:limit])
		crawler.emails.each { |email| Candidate.find_or_create_by(email: email)}
		redirect_to '/scrapers'
	end

	def verify_emails
		Candidate.where(id: params[:ids]).update_all(verified: true)
		redirect_to '/scrapers'
	end

end