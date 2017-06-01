require "rails_helper"

describe PersonalPageCrawler do
	let(:domain) { "www.farts.com" }
	let(:resume_link) { "/mattdick.pdf" }
	let(:page_email) { "page@page.com" }
	let(:resume_email) { "resume@resume.com" }
	let(:page_content) { "something resume #{page_email} something github #{resume_link}" }
	let(:resume_content) { "resume something #{resume_email} linkedin" }
	let(:browser) do
		double(
			html: page_content,
			goto: nil,
			close: nil,
		)
	end

	subject { described_class.call(domain) }

	before do
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