class CreateBbbs < ActiveRecord::Migration[6.1]
  def change
    create_table :bbbs do |t|

      t.timestamps
    end
  end
end
