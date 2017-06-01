class PersonalPageCrawler
	include CrawlerCommon

	CLUE_WORDS = %w(resume linkedin github)

	def self.call(url)
		new(url).crawl
	end

	attr_reader :url

	def initialize(url)
		@url = url
		@page = Mechanize.new.get(url)
	rescue => e
		"ERROR 1.5: #{e}"
	end

	def crawl
		puts "crawling external: #{url}"
		if looks_like_personal_page?
			puts "!!! PERSONAL PAGE !!!"

			candidate = Candidate.find_or_create_by(email: candidate_email) if candidate_email
			find_and_parse_resume(candidate)
		end
	end

	private

	def looks_like_personal_page?
		@page.body.scan(/#{CLUE_WORDS.join('|')}/i)
			.map(&:downcase).uniq.count > 1
	end

	def candidate_email
		emails = parsed_emails.uniq
		emails.count > 1 ? nil : emails.first
	end

	def parsed_emails
		@emails ||= parse_emails_from_html(@page.body, url)
	end

	def find_and_parse_resume(candidate)
		if pdf_link
			file = open(pdf_path)

			pdf_first_page = PDF::Reader.new(file).pages.first
			email = parse_emails(pdf_first_page.text).first || candidate&.email
			candidate ||= Candidate.find_or_create_by(email: email)
			if candidate.update_attributes(email: email, resume_url: pdf_path, origin_url: url)
				# TODO: tags!!!
			end
		end
	rescue => e
		puts "ERROR 3: #{e}"
	end

	def pdf_link
		@pdf_link ||= @page.links.map(&:href).select do |s|
			s&.match /(docs\.google)|(\.pdf)/
		end[0]
	end

	def pdf_path
		return pdf_link if pdf_link.match /^http/

		slash = (pdf_link[0] == "/") ? "" : "/"
		url + slash + pdf_link
	end
end