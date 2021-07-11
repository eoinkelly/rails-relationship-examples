class CreateAaas < ActiveRecord::Migration[6.1]
  def change
    create_table :aaas do |t|

      t.timestamps
    end
  end
end
