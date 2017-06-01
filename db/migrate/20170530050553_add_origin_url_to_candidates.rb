class AddOriginUrlToCandidates < ActiveRecord::Migration[5.1]
  def change
  	add_column :candidates, :origin_url, :string
  end
end
