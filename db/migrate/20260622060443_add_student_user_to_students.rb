class AddStudentUserToStudents < ActiveRecord::Migration[8.0]
  def change
    add_reference :students, :student_user, foreign_key: { to_table: :users }, null: true
  end
end
