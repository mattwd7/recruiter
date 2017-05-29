class Crawler
	DOMAIN = ""
	ROOT_URL = ""

	def self.call
		new.call
	end

	def initialize
		@root = agent.get(self.class::ROOT_URL)
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

			break if !next_page || listing_links.empty?
			@search_results = @agent.get(next_page)
		end
	end

	private

	def agent
		@agent ||= Mechanize.new.tap do |a|
			a.user_agent_alias = 'Mac Safari'
		end
	end

	def submit_search
		raise NotImplementedError
	end

	def next_page
		raise NotImplementedError
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
		raise NotImplementedError
	end

	def company_name
		raise NotImplementedError
	end

	def title
		raise NotImplementedError
	end

	def tag_names
		raise NotImplementedError
	end

	def location
		raise NotImplementedError
	end

	def job_description
		raise NotImplementedError
	end

	def skills
		raise NotImplementedError
	end

	def about_company
		raise NotImplementedError
	end

	def clean_text(text)
		return unless text.is_a?(String)

		text.strip.gsub(/\r|\n/, "").gsub(/\s{2,}/, " ")
	end
end