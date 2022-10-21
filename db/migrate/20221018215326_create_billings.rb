class CreateBillings < ActiveRecord::Migration[7.0]
  def change
    create_table :billings do |t|

      t.timestamps
    end
  end
end
