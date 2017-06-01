require "rails_helper"

describe EmailCrawler do
	let(:domain) { "www.farts.com" }
	let(:email_1) { "matt@test.com" }
	let(:email_2) { "john@test.com" }
	let(:email_3) { "turd@test.com" }
	let(:html) { "some garbage#{email_1} and more #{email_2}" }
	let(:internal_link) { "/about" }
	let(:external_link) { "http://personalPageMaybe.com" }

	before do
		allow_any_instance_of(described_class).to receive(:sleep)
		allow_any_instance_of(Mechanize)
			.to receive(:get)
			.and_return(
				double(
					body: html,
					links: [double(href: internal_link), double(href: external_link)]
				)
			)
	end

	describe "#crawl_for_emails" do
		subject do
			described_class
				.new(domain, full_sitemap: true)
				.crawl_for_emails
		end

		it "creates candidates from unique emails on the page" do
			expect { subject }
				.to change { Candidate.count }
				.by(2)
		end

		it "visits all relative paths found on each page" do
			expect_any_instance_of(described_class)
				.to receive(:crawl_page)
				.with(domain)
				.and_call_original
			expect_any_instance_of(described_class)
				.to receive(:crawl_page)
				.with(domain + internal_link)
				.and_call_original

			subject
		end

		it "visits all external links 1 level deep for personal websites" do
			expect(PersonalPageCrawler)
				.to receive(:call)
				.with(external_link)

			subject
		end
	end

	describe "continue" do

	end
end