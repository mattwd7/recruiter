class EmailCrawler
	include CrawlerCommon

	def self.test
		# url = "http://nyuwinc.org/"
		url = "http://hackny.org/2015/06/announcing-the-class-of-2015-hackny-fellows/"
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
		@visited_pages = []
		@pages_to_visit = [url]
		@browser = Watir::Browser.new
	end

	def crawl_for_emails(limit: nil)
		page_count = 0

		while url = remaining_pages.first do
			puts "Crawling: #{url}"
			crawl_page(url)
			page_count += 1
			break if (!@full_sitemap || (limit && page_count >= limit.to_i))
			sleep rand(1..3)
		end

		end_process
	# rescue => e
	# 	puts e
	# 	end_process
	end

	def continue(limit: nil)
		crawl_for_emails(limit: limit.to_i)
	end

	def show_emails
		@emails.each { |e| puts e }
	end

	def remaining_pages
		@pages_to_visit - @visited_pages
	end

	private

	def domain
		@domain ||= (url.match /^(?:https?:\/\/)?(?:[^@\n]+@)?(?:www\.)?([^:\/\n]+)/im)[0]
	end

	def crawl_page(url)
		@browser.goto url
		parse_emails_from(@browser.html).each do |email|
			Candidate.find_or_create_by(email: email)
		end
		try_external_links
		@visited_pages << url
		build_sitemap

	# rescue
	# 	@visited_pages << url
	end

	def try_external_links
		puts "External count: #{external_links.count}"
		external_links.each { |url| PersonalPageCrawler.call(url) }
	end

	def external_links
		@browser.links.map(&:href).select do |href|
			(href&.length || 0) > 2 && !href.match(domain)
		end
	end

	def build_sitemap
		relative_paths = @browser.links.map(&:href).compact.map do |href|
			leading_slash = (domain[-1] == '/' ? '/' : '')
			href.gsub(domain, leading_slash)
		end

		relative_paths.each do |relative_path|
			full_path = full_path(relative_path)

			if is_valid_unvisited_path(relative_path)
				@pages_to_visit << full_path
			end
		end
	end

	def is_valid_unvisited_path(relative_path)
		relative_path.length > 1 &&
			relative_path[0] == "/" &&
			!@visited_pages.include?(full_path(relative_path)) &&
			!@pages_to_visit.include?(full_path(relative_path))
	end

	def full_path(relative_path)
		"#{domain}#{relative_path[1..-1]}"
	end

	def end_process
		@emails.uniq!
		@browser.close
		self
	end
end