require "rails_helper"

describe PersonalPageCrawler do
	let(:resume_link) { "mattdick.pdf" }
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

	subject { described_class.call("www.farts.com") }

	before do
		allow_any_instance_of(described_class).to receive(:open)
		allow(Watir::Browser).to receive(:new).and_return(browser)

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
			expect(Candidate.first.resume_url).to eq(resume_link)
		end
	end

	context "with an email on the page only" do
		let(:resume_email) { nil }

		it "assigns the page email to the candidate" do
			expect { subject }.to change { Candidate.count }.by(1)
			expect(Candidate.first.email).to eq(page_email)
			expect(Candidate.first.resume_url).to eq(resume_link)
		end
	end

	context "without a .pdf on the page" do
		let(:resume_link) { nil }

		it "creates a candidate without a resume_url" do
			expect { subject }.to change { Candidate.count }.by(1)
			expect(Candidate.first.email).to eq(page_email)
			expect(Candidate.first.resume_url).to eq(nil)
		end
	end
end