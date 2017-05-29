class CreateListings < ActiveRecord::Migration[5.1]
  def change
    create_table :listings do |t|
    	t.integer :company_id
    	t.string :title
    	t.string :location
    	t.text :description
    	t.text :skills

    	t.timestamps
    end
  end
end
