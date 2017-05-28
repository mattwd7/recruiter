class CreateCandidates < ActiveRecord::Migration[5.1]
  def change
    create_table :candidates do |t|
    	t.string :email
    	t.string :first_name
    	t.string :last_name
    	t.boolean :verified, default: false

    	t.timestamps
    end
  end
end
