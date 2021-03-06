class StackOverflowCrawler < Crawler
	DOMAIN = "https://stackoverflow.com"
	ROOT_URL = "https://stackoverflow.com/jobs"

	private

	def submit_search
		@search_results = @root.form_with(id: "job-search-form") do |search|
			search.q = @search_title
			search.l = @search_location
		end.submit
	end

	def next_page
		if next_element = @search_results.css(".prev-next.job-link.test-pagination-next").first
			self.class::DOMAIN + next_element.attributes["href"].value
		end
	end

	def listing_links
		@search_results
			.css(".-item.-job.-job-item .job-link")
			.map { |link| self.class::DOMAIN + link.attributes["href"].value}
			.reject { |link| link.match /developer-jobs-using/ }
			.compact
	end

	def company_name
		@listing_page.css(".employer").first&.text
	end

	def title
		@listing_page.css(".title.job-link").first&.text
	end

	def tag_names
		@listing_page.css(".post-tag.job-link.no-tag-menu").map(&:text)
	end

	def location
		@listing_page.css(".location").first&.text
	end

	def job_description
		@listing_page.css(".description")[0]&.text
	end

	def skills
		@listing_page.css(".description")[1]&.text
	end

	def about_company
		@listing_page.css(".description")[2]&.text
	end
end