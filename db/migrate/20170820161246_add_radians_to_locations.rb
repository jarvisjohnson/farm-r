class AddRadiansToLocations < ActiveRecord::Migration[5.1]
  def change
    add_column :locations, :latitude_radians, :float
    add_column :locations, :longitude_radians, :float
  end
end
