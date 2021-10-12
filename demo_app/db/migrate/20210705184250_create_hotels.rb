class CreateHotels < ActiveRecord::Migration[6.1]
  def change
    create_table :hotels, &:timestamps
  end
end
