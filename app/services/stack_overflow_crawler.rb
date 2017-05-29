class StackOverflowCrawler
	DOMAIN = "https://stackoverflow.com"
	ROOT_URL = "https://stackoverflow.com/jobs"

	def self.call
		new.call
	end

	def initialize
		@root = agent.get(ROOT_URL)
	end

	def call
		submit_search
		page_count = 0

		loop do
			page_count += 1
			listing_links.each do |listing|
				@listing_page = agent.get(listing)

				company = Company.find_or_create_with(company_attributes)		
				company.create_listing_if_new(listing_attributes, tag_names) if company.id

				puts "Created listing: '#{clean_text(title)}'"
				puts "PAGE COUNT: #{page_count}"
				sleep rand(1..3)
			end

			break unless next_page
			@search_results = @agent.get(DOMAIN + next_page)
		end
	end

	private

	def agent
		@agent ||= Mechanize.new.tap do |a|
			a.user_agent_alias = 'Mac Safari'
		end
	end

	def submit_search
		@search_results = @root.form_with(id: "job-search-form") do |search|
			search.q = "Software Engineer"
			search.l = "New York, NY"
		end.submit
	end

	def next_page
		if next_element = @search_results.css(".prev-next.job-link.test-pagination-next").first
			next_element.attributes["href"].value
		end
	end

	def company_attributes
		{
			name: company_name,
			about: about_company,
		}.transform_values { |v| clean_text(v) }
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
		@search_results
			.css(".-item.-job.-job-item")
			.css(".job-link")
			.map { |link| DOMAIN + link.attributes["href"].value}
			.reject { |link| link.match /developer-jobs-using/ }
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

	def clean_text(text)
		return unless text.is_a?(String)

		text.strip.gsub(/\r|\n/, "").gsub(/\s{2,}/, " ")
	end
end