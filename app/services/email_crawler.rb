class EmailCrawler
	include CrawlerCommon

	def self.test
		url = "http://nyuwinc.org/"
		# url = "http://hackny.org/2015/06/announcing-the-class-of-2015-hackny-fellows/"
		self.for_domain(url, limit: 5)
	end

	def self.for_url(url)
		new(url)
			.crawl_for_emails
	end

	def self.for_domain(domain, limit: nil)
		new(domain, full_sitemap: true)
			.crawl_for_emails(limit: limit)
	end

	attr_reader :url, :domain, :emails

	def initialize(url, full_sitemap: false)
		@url = url
		@full_sitemap = full_sitemap
		@emails = []
		@visited_internal_urls = []
		@visited_external_urls = []
		@urls_to_visit = [url]
		@agent = Mechanize.new
	end

	def crawl_for_emails(limit: nil)
		page_count = 0

		while url = remaining_urls.first do
			puts "Crawling: #{url}"
			crawl_page(url)
			page_count += 1
			break if (!@full_sitemap || (limit && page_count >= limit.to_i))
			sleep rand(2..4)
		end

		end_process
	rescue => e
		puts e
		end_process
	end

	def remaining_urls
		@urls_to_visit - @visited_internal_urls
	end

	def continue(limit: nil)
		crawl_for_emails(limit: limit.to_i)
	end

	def show_emails
		@emails.each { |e| puts e }
	end

	def common_externals
		@visited_external_urls.sort
	end

	private

	def domain
		@domain ||= parse_domain(url)
	end

	def crawl_page(url)
		@page = @agent.get(url)
		parse_emails_from_html(@page.body, url).each do |email|
			candidate = Candidate.find_or_initialize_by(email: email)
			candidate.assign_attributes(origin_url: url)
			candidate.save
		end
		visit_external_links
		@visited_internal_urls << url
		build_sitemap

	rescue Mechanize::ResponseCodeError
		parse_emails_with_browser(url)
		@visited_internal_urls << url
	rescue => e
		puts "ERROR 1: #{e}"
		@visited_internal_urls << url
	end

	def visit_external_links
		(external_links - @visited_external_urls).each do |url|
			PersonalPageCrawler.call(url)
			@visited_external_urls << url
		end
	rescue => e
		puts "ERROR 2: #{e}"
	end

	def external_links
		@page.links.map(&:href).select do |href|
			href.match(/^http/) &&
				!href.match(domain) &&
				!parse_domain(href).match(EXTERNAL_BLACKLIST.join("|"))
		end.uniq
	end

	def build_sitemap
		relative_paths = @page.links.map(&:href).compact.map do |href|
			leading_slash = (domain[-1] == '/' ? '/' : '')
			href.gsub(domain, leading_slash)
		end

		relative_paths.each do |relative_path|
			full_path = full_path(relative_path)

			if is_valid_unvisited_path(relative_path)
				@urls_to_visit << full_path
			end
		end
	end

	def is_valid_unvisited_path(relative_path)
		relative_path.length > 1 &&
			relative_path[0] == "/" &&
			!@visited_internal_urls.include?(full_path(relative_path)) &&
			!@urls_to_visit.include?(full_path(relative_path))
	end

	def full_path(relative_path)
		"#{domain}#{relative_path}"
	end

	def end_process
		@emails.uniq!
		self
	end
end