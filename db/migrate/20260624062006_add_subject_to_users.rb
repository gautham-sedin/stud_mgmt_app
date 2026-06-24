class AddSubjectToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :subject, :string
  end
end
