module CrawlerCommon
	def parse_emails_from(text)
		text.scan(/[-0-9a-zA-Z.+_]+@[-0-9a-zA-Z.+_]+\.[a-zA-Z]{2,4}/)
	end
end