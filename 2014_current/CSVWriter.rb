require 'csv'

class CSVWriter
	def initialize checker
		@checker = checker
	end

	def write data, time_taken
		CSV.open('results_Dimitar_Terziev_A_6.csv', 'w') do |csv|
			puts "wot"
			csv << [time_taken, '', @checker.HOMEWORK_NAMES, 
				@checker.HOMEWORK_NUMBERS_FLOG_FLAY.map { |num| "g#{num}" }, 
				@checker.HOMEWORK_NUMBERS_FLOG_FLAY.map { |num| "y#{num}" }].flatten
			data.each do |key, value|
				csv << [key.split('_'), value].flatten
			end
		end
	end
end
