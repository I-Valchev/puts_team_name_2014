class EntryLevelChecker

	def initialize data, how_many_to_check
		@data = data
		@how_many_to_check = how_many_to_check
		@acceptable_extensions = YAML.load_file('acceptable_extensions_entry_level.yml')
		@checked_students = Array.new
	end

	def get_full_name filename
		first_name, last_name = filename.gsub(/.*\/|\..*/, '').split('_')
		first_name.capitalize + '_' + last_name.capitalize
	end

	def get_problem_num filename
		filename.gsub(/.*\/|\..*/, '').split('_')[2]
	end

	def valid_filename? filename
		first_name, last_name, problem_num = filename.gsub(/.*\/|\..*/, '').split('_')

		@acceptable_extensions.include?(File.extname(filename)) && 
		(Integer(problem_num) rescue false) && 
		!(first_name.empty?) &&
		!(last_name.empty?) &&
		problem_num.to_i.between?(2,18)
	end

	def check value_to_write
		entry_level_data = Hash.new { |hash, student_name| hash[student_name] = Array.new }

		Dir.glob("vhodno_nivo/**/*.*") do |filename|
			if valid_filename? filename
				full_name = get_full_name filename
				problem_num = get_problem_num filename

				if value_to_write == 2
					next unless @checked_students.include? full_name
				end

				if @how_many_to_check != -1
					next if entry_level_data.size >= @how_many_to_check.to_i && !(entry_level_data.key? full_name)
	            end

				entry_level_data[full_name] << problem_num unless entry_level_data[full_name].include? problem_num
				@checked_students << full_name
			end
	    end

	    case value_to_write
	      when 1
	        entry_level_data.each do |student, problems| 
	        	@data[student][0] = (problems.size >= 3) ? 1 : 0
	        end
	      when 2
	        entry_level_data.each do |student, problems| 
	        	@data[student][0] = 2 if problems.size >= 3
	        end
	    end
	end
end