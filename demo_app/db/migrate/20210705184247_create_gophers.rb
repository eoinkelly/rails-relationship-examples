class CreateGophers < ActiveRecord::Migration[6.1]
  def change
    create_table :gophers, &:timestamps
  end
end
