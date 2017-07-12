module CrawlerCommon
	EXTERNAL_BLACKLIST = [
		"google.com",
		"facebook.com",
		"instagram.com",
		"youtube.com",
		"twitter.com",
		"linkedin.com",
	]

	def parse_emails_from_html(html, url)
		if html.match /mailto\:/
			parse_emails_with_browser(url)
		else
			parse_emails(html)
		end
	end

	def parse_emails_with_browser(url)
		browser = Watir::Browser.new
		browser.goto url
		emails = parse_emails(browser.html)
		browser.close
		emails
	end

	def parse_emails(text)
		text.scan(/[-0-9a-zA-Z.+_]+@[-0-9a-zA-Z.+_]+\.[a-zA-Z]{2,4}/)
			.reject { |emails| emails.match /info/ }
			.reject { |emails| emails.match /\.(jpe?g|png|gif|bmp)$/i }
	end

	def parse_domain(url)
		(url.match /^(?:https?:\/\/)?(?:[^@\n]+@)?(?:www\.)?([^:\/\n]+)/im)[0]
	end

	def parse_links(page)
		links = if page.links.count > 1
				page.links
			else
				browser = Watir::Browser.new
				browser.goto page.uri.to_s
				links = browser.links.map(&:href)
				browser.close
				puts "LINKS: #{links}"
				links
			end
			
		links.map { |link| link.gsub("https", "http") }
	end
end