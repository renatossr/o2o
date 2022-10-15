class CreateInvoices < ActiveRecord::Migration[7.0]
  def change
    create_table :invoices do |t|
      t.string :external_id
      t.string :external_url
      t.string :status
      t.date :reference_date
      t.integer :member_id
      t.integer :total_value_cents

      t.timestamps
    end
  end
end
