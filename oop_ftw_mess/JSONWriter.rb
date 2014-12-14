require 'json'

class JSONWriter
	def initialize checker
		@checker = checker
	end

	def write data, time_taken
		write_to_json_hash = Hash.new
		write_to_json_hash["homework_evaluation"] = Hash.new
		student_hash = write_to_json_hash["homework_evaluation"]
		student_hash["time_taken"] = time_taken
		student_hash["student"] = Array.new
		
		data.each do |name, values|
			cur_hash = Hash.new
			cur_hash["name"] = name

			results = HOMEWORK_NAMES + @checker.HOMEWORK_NUMBERS_FLOG_FLAY.map { |num| "g#{num}" } + 
				@checker.HOMEWORK_NUMBERS_FLOG_FLAY.map { |num| "y#{num}" }
			results.each_with_index do |result, index|
				cur_hash[result] = values[index]
			end
			
			student_hash["student"] << cur_hash
		end

		pretty_json = JSON.pretty_generate(write_to_json_hash)
		File.open("results_Stanimir_Bogdanov_A_24.json", "w") do |result|
			result.puts pretty_json
		end
	end
end
