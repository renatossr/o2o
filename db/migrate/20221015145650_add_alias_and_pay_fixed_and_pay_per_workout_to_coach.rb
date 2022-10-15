class AddAliasAndPayFixedAndPayPerWorkoutToCoach < ActiveRecord::Migration[7.0]
  def change
    add_column :coaches, :alias, :string
    add_column :coaches, :pay_fixed, :integer
    add_column :coaches, :pay_per_workout, :integer
    add_column :coaches, :to, :string
    add_column :coaches, :coach, :string
  end
end
