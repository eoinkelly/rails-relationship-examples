class CreateDelta < ActiveRecord::Migration[6.1]
  def change
    create_table :delta, &:timestamps
  end
end
