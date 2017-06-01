require "rails_helper"

describe PersonalPageCrawler do
	let(:domain) { "www.farts.com" }
	let(:page_email) { "page@page.com" }
	let(:page_content) { "something resume #{page_email} something github #{resume_link}" }
	let(:resume_email) { "resume@resume.com" }
	let(:resume_content) { "resume #{tags[1]} something#{tags[2]} #{resume_email} linkedin #{tags[0]}" }
	let(:tags) { %w(ruby c++ .net) }

	subject { described_class.call(domain) }

	before do
		tags.each { |tag| Tag.create(name: tag) }

		allow_any_instance_of(described_class).to receive(:open)
		allow_any_instance_of(Mechanize)
			.to receive(:get)
			.and_return(
				double(
					body: page_content,
					links: [double(href: resume_link)]
				)
			)
		allow_any_instance_of(described_class)
			.to receive(:pdf_link)
			.and_return(resume_link)

		allow(PDF::Reader)
			.to receive(:new)
			.and_return(
				double(
					pages: [ double(text: resume_content) ]
				)
			)
	end

	context "with a resume" do
		let(:resume_link) { "/mattdick.pdf" }

		it "matches resume keywords against existing tags" do
			expect { subject }.to change { Candidate.count }.by(1)
			puts Tag.pluck(:name)
			expect(Tag.count).to eq(tags.count)
			expect(Candidate.first.tags.count).to eq(tags.count)
		end

		context "with an email on the page AND in the resume" do
			it "assigns the resume email to the candidate" do
				expect { subject }.to change { Candidate.count }.by(1)
				expect(Candidate.first.email).to eq(resume_email)
				expect(Candidate.first.resume_url).to eq(domain + resume_link)
			end
		end

		context "with an email on the page only" do
			let(:resume_email) { nil }

			it "assigns the page email to the candidate" do
				expect { subject }.to change { Candidate.count }.by(1)
				expect(Candidate.first.email).to eq(page_email)
				expect(Candidate.first.resume_url).to eq(domain + resume_link)
			end
		end
	end
end