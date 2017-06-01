module CrawlerCommon
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
			.reject { |emails| emails.match /\.(jpe?g|png|gif|bmp)$/i }
	end
end