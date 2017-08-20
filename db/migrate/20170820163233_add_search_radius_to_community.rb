class AddSearchRadiusToCommunity < ActiveRecord::Migration[5.1]
  def change
    add_column :marketplace_configurations, :search_radius, :integer
  end
end
