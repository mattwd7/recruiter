class StackOverflowCrawler
	DOMAIN = "https://stackoverflow.com"
	ROOT_URL = "https://stackoverflow.com/jobs"

	def self.call
		new.call
	end

	def initialize
		@page = agent.get(ROOT_URL)
	end

	def call
		submit_search
		listing_links.each do |listing|
			@page = agent.get(listing)

			company = Company.find_or_initialize_by(
				name: clean_text(company_name)
			)

			unless company.id
				company.about = about_company
				company.save
			end

			unless company.listings.where(title: clean_text(title)).exists?
				listing = Listing.create(
					listing_attributes.merge({
						company_id: company.id,
					})
				)
				listing.create_listing_tags(tag_names)
			end
			
			puts "Created listing: '#{clean_text(title)}'"
			sleep rand(1..3)
		end
	end

	private

	def agent
		@agent ||= Mechanize.new.tap do |a|
			a.user_agent_alias = 'Mac Safari'
		end
	end

	def submit_search
	end

	def listing_attributes
		{
			title: title,
			location: location,
			description: job_description,
			skills: skills,
		}.transform_values { |v| clean_text(v) }
	end

	def listing_links
		@page
			.css(".-item.-job.-job-item")
			.css(".job-link")
			.map { |link| DOMAIN + link.attributes["href"].value}
			.reject { |link| link.match /developer-jobs-using/ }
	end

	def company_name
		@page.css(".employer").first.text
	end

	def title
		@page.css(".title.job-link").first.text
	end

	def tag_names
		@page.css(".post-tag.job-link.no-tag-menu").map(&:text)
	end

	def location
		@page.css(".location").first.text
	end

	def job_description
		@page.css(".description")[0]&.text
	end

	def skills
		@page.css(".description")[1]&.text
	end

	def about_company
		@page.css(".description")[2]&.text
	end

	def clean_text(text)
		return unless text

		text.strip.gsub(/\r|\n/, "").gsub(/\s{2,}/, " ")
	end

end