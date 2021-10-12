class CreateEchos < ActiveRecord::Migration[6.1]
  def change
    create_table :echos, &:timestamps
  end
end
