class CreateItems < ActiveRecord::Migration[7.0]
  def change
    create_table :items do |t|
      t.integer :member_id
      t.string :description
      t.date :reference_date
      t.integer :invoice_id
      t.integer :status
      t.integer :payable_by

      t.timestamps
    end
  end
end
