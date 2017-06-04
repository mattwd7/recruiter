class IndeedCrawler < Crawler
	DOMAIN = "https://indeed.com"
	ROOT_URL = "https://indeed.com"

	def initialize
		@page_count = 0
		super
	end

	private

	def submit_search
		@search_results = @root.form_with(id: "jobsearch") do |search|
			search.q = "Software Engineer"
			search.l = "New York, NY"
		end.submit
	end

	def next_page
		if next_element = @search_results.css(".np").first
			#need to return the parent's parent element href attr here...
		end
	end

	def listing_links
		@search_results
			.css(".row.result") #issue  here
			.map { |link| self.class::DOMAIN + link.attributes["href"].value}
	end

	def company_name
		@listing_page.css(".company").first&.text
	end

	def title
		@listing_page.css(".jobtitle").first&.text
	end

	def tag_names
		""
	end

	def location
		@listing_page.css(".location").first&.text
	end

	def job_description
		@listing_page.css(".summary").first&.text
	end

	def skills
		""
	end

	def about_company
		""
	end
end