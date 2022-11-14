class CreatePayableItems < ActiveRecord::Migration[7.0]
  def change
    create_table :payable_items do |t|
      t.integer :coach_id
      t.string :description
      t.integer :price_cents
      t.integer :quantity
      t.integer :value_cents
      t.integer :payable_id

      t.timestamps
    end
  end
end
