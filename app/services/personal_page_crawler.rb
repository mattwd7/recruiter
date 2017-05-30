class PersonalPageCrawler
	include CrawlerCommon

	CLUE_WORDS = %w(resume linkedin github)

	def self.call(url)
		new(url).crawl
	end

	attr_reader :url

	def initialize(url)
		@url = url
		@browser = Watir::Browser.new
	end

	def crawl
		@browser.goto url
		if looks_like_personal_page?
			puts "!!! PERSONAL PAGE: #{url}"
			candidate = Candidate.find_or_create_by(email: candidate_email) if candidate_email
			find_and_parse_resume(candidate)
		end

		@browser.close
	end

	private

	def looks_like_personal_page?
		@browser.html.scan(/#{CLUE_WORDS.join('|')}/i)
			.map(&:downcase).uniq.count > 1
	end

	def candidate_email
		emails = parse_emails_from(@browser.html).uniq
		emails.count > 1 ? nil : emails.first
	end

	def find_and_parse_resume(candidate)
		if pdf_link
			full_path = (pdf_link[0] == "/") ? url + pdf_link : pdf_link
			file = open(full_path)

			page = PDF::Reader.new(file).pages.first
			email = parse_emails_from(page.text).first || candidate&.email
			candidate ||= Candidate.find_or_create_by(email: email)
			if candidate.update_attributes(email: email, resume_url: full_path)
				# TODO: tags!!!
			end
		end
	end

	def pdf_link
		@pdf_link ||= @browser.links.map(&:href).select do |s|
			s&.match /(docs\.google)|(\.pdf)/
		end[0]
	end
end