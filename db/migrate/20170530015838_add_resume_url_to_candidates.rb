class AddResumeUrlToCandidates < ActiveRecord::Migration[5.1]
  def change
  	add_column :candidates, :resume_url, :string
  end
end
