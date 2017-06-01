class CandidateTag < ActiveRecord::Base
	belongs_to :candidate
	belongs_to :tag
end