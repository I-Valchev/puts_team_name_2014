require 'csv'

class CSVWriter
	def write data, time_taken
		CSV.open("results_Dimitar_Terziev_A_6.csv","w") do |csv|
			csv << [time_taken, "", HOMEWORK_NAMES].flatten
			data.each do |key, value|
				csv << [key.split("_").first, key.split("_").last, value].flatten
			end
		end
	end
end
