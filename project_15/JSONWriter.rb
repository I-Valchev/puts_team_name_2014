require 'json'

class JSONWriter
	def write data, time_taken
		write_to_json_hash = Hash.new
		write_to_json_hash["homework_evaluation"] = Hash.new
		student_hash = write_to_json_hash["homework_evaluation"]
		student_hash["time_taken"] = time_taken
		student_hash["student"] = Array.new
		data.each do |name, values|
			cur_hash = Hash.new
			cur_hash["name"] = name
			0.upto(TOTAL_HOMEWORKS){|homework|
				cur_hash[HOMEWORK_NAMES[homework]] = values[homework]
			}
			
			student_hash["student"] << cur_hash
		end

		pretty_json = JSON.pretty_generate(write_to_json_hash)
		File.open("results_Dimitar_Terziev_A_6.json", "w") do |result|
			result.puts pretty_json
		end
	end
end
