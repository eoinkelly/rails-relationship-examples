class CreateGolves < ActiveRecord::Migration[6.1]
  def change
    create_table :golves, &:timestamps
  end
end
