module CrawlerCommon
	def parse_emails_from_html(html, url)
		text = if html.match /mailto\:/
				browser = Watir::Browser.new
				browser.goto url
				browser.html
			else
				html
			end
		
		browser&.close
		parse_emails(text)
	end

	def parse_emails(text)
		text.scan(/[-0-9a-zA-Z.+_]+@[-0-9a-zA-Z.+_]+\.[a-zA-Z]{2,4}/)
			.reject { |emails| emails.match /\.(jpe?g|png|gif|bmp)$/i }
	end
end