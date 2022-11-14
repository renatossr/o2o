class CreatePayables < ActiveRecord::Migration[7.0]
  def change
    create_table :payables do |t|
      t.integer :coach_id
      t.date :reference_date
      t.integer :total_value_cents

      t.timestamps
    end
  end
end
