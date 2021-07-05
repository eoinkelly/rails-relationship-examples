class CreateCharlies < ActiveRecord::Migration[6.1]
  def change
    create_table :charlies, &:timestamps
  end
end
