class CreateAlfas < ActiveRecord::Migration[6.1]
  def change
    create_table :alfas, &:timestamps
  end
end
