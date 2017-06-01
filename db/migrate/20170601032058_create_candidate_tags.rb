class CreateCandidateTags < ActiveRecord::Migration[5.1]
  def change
    create_table :candidate_tags do |t|
    	t.integer :candidate_id
    	t.integer :tag_id

    	t.timestamps
    end
  end
end
