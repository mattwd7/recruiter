require "rails_helper"

describe StackOverflowCrawler do
	let(:company_name) { "E Corp" }
	let(:tag_names) { %w(ruby html scss javascript) }
	let(:title) { "Junior Software Engineer" }
	let(:location) { "New York, NY" }
	let(:job_description) { "The job description" }
	let(:skills) { "All the skills" }
	let(:about_company) { "About the company" }
	let(:stub_options) do
		{
			company_name: company_name,
			title: title,
			location: location,
			listing_links: ["www.so.com/job-1"],
			tag_names: tag_names,
			job_description: job_description,
			skills: skills,
			about_company: about_company
		}
	end

	def scrape
		described_class.call(title, location)
	end

	def stub_described_class(**additional_options)
		allow_any_instance_of(described_class)
			.to receive_messages(
				stub_options.merge(**additional_options)
			)
	end

	before do
		allow_any_instance_of(Mechanize)
			.to receive(:get)

		stub_described_class
	end

	it "creates a new listing with tags for the new company" do
		scrape

		expect(Tag.count).to eq(tag_names.count)
		expect(Listing.count).to eq(1)
		expect(Listing.first.tags.count).to eq(tag_names.count)
		expect(Company.count).to eq(1)
	end

	context "without a company name" do
		let(:company_name) { nil }
		
		it "does not create a company or listings" do
			scrape

			expect(Company.count).to eq(0)
			expect(Listing.count).to eq(0)
		end
	end

	context "with existing records" do
		let(:different_title) { "Mid-level Software Engineer" }
		let(:different_tag_names) { %w(ruby html java c#) }

		before do
			scrape

			stub_described_class(
				title: different_title,
				tag_names: different_tag_names
			)
		end

		it "does not duplicate the company with existing company name" do
			scrape

			expect(Company.count).to eq(1)
			expect(Company.first.listings.count).to eq(2)
		end

		it "does not duplicate existing tags with existing tag name" do
			scrape

			expect(Tag.count).to eq(6)
			expect(Listing.count).to eq(2)
			expect(Listing.last.tags.count).to eq(4)
		end

		context "with the same listing title for a company" do
			before do
				stub_described_class(
					title: title,
					tag_names: different_tag_names
				)
			end

			it "does not duplicate company listings with the same title" do
				scrape

				expect(Listing.count).to eq(1)
			end
		end
	end
end