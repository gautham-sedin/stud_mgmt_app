class StudentReportPdfService
  def initialize(student)
    @student = student
  end

  def generate
    pdf = Prawn::Document.new

    pdf.text "Student Report", size: 22, style: :bold
    pdf.move_down 20

    pdf.text "Name: #{@student.name}", size: 16
    pdf.text "Email: #{@student.email}", size: 16
    pdf.text "Age: #{@student.age}", size: 16
    pdf.text "Course: #{@student.course}", size: 16
    pdf.text "City: #{@student.city}", size: 16
    pdf.text "Marks: #{@student.marks}", size: 16
    pdf.text "Result: #{@student.result}", size: 16
    pdf.text "Teacher: #{@student.user&.name || 'N/A'}", size: 16
    pdf.move_down 20

    pdf.render
  end
end
