class CreateFoxtrots < ActiveRecord::Migration[6.1]
  def change
    create_table :foxtrots, &:timestamps
  end
end
