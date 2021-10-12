class CreateBbbs < ActiveRecord::Migration[6.1]
  def change
    create_table :bbbs, &:timestamps
  end
end
