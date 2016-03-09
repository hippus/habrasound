require 'csv'
file_data = []
file_name = ""
CSV.foreach("c:/Projects/habrasound/data/data.csv") do |row|
  current_month = row[0].to_s[0..6]
  if file_name != "" && file_name != current_month
    # write csv
    puts "writing " + file_name
    CSV.open("c:/Projects/habrasound/data/" + file_name + ".csv", "wb") do |csv|
      file_data.each do |saved_row|
        csv << saved_row
      end
    end
    file_name = current_month
    file_data = []
  else
	file_name = current_month
    file_data.push(row)
  end
end