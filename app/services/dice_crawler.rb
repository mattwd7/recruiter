class DiceCrawler < Crawler
	DOMAIN = "https://dice.com"
	ROOT_URL = "https://dice.com"

	def initialize
		@page_count = 0
		super
	end

	private

	def agent
		@agent ||= Mechanize.new.tap do |a|
			a.user_agent_alias = 'Mac Safari'
		end
	end

	def submit_search
		@search_results = @root.form_with(id: "search-form") do |search|
			search.q = "Software Engineer"
			search.l = "New York, NY"
		end.submit
	end

	def next_page
		"https://www.dice.com/jobs/q-software_engineer-l-New_York%2C_NY-radius-30-startPage-#{@page_count += 1}-jobs"
	end

	def listing_links
		@search_results
			.css(".complete-serp-result-div .dice-btn-link.loggedInVisited")
			.map { |link| link.attributes["href"].value}
	end

	def company_name
		@listing_page.css(".employer .dice-btn-link").first&.text
	end

	def title
		@listing_page.css(".jobTitle").first&.text
	end

	def tag_names
		tags = @listing_page.css(".iconsiblings").first&.text
		clean_text(tags).split(", ")
	end

	def location
		@listing_page.css(".location").first&.text
	end

	def job_description
		@listing_page.css("#jobdescSec").first&.text
	end

	def skills
		""
	end

	def about_company
		""
	end
end