require 'yaml'
require 'csv'
require_relative 'presentations'

class HomeworkChecker

	attr_reader :data, :HOMEWORK_NUMBERS_FLOG_FLAY, :HOMEWORK_NAMES

	def initialize repo_folder, how_many_to_check
		@repo_folder = repo_folder
		@how_many_to_check = how_many_to_check

		homeworks_configuration = YAML.load_file('configuration.yml')
		@HOMEWORK_NUMBERS = homeworks_configuration['HOMEWORK_NUMBERS']
		# @TOTAL_HOMEWORKS = HOMEWORK_NUMBERS.size
		@HOMEWORK_NUMBERS_FLOG_FLAY = homeworks_configuration['HOMEWORK_NUMBERS_FLOG_FLAY']
		@HOMEWORK_NAMES = homeworks_configuration['HOMEWORK_NAMES']
		@DEADLINES = homeworks_configuration['DEADLINES']

		@data = Hash.new do |hash, student_name| 
			hash[student_name] = Array.new(@HOMEWORK_NAMES.size + 2*@HOMEWORK_NUMBERS_FLOG_FLAY.size) 
		end

		@HOMEWORK_FOLDERS = YAML.load_file('homework_folders.yml')

		@current_path = Dir.pwd
		Dir.chdir repo_folder

		@@flog_flay_index = 0
		@helper_for_n_option = Hash.new { |hash, key| hash[key] = Array.new }
	end

	def check_homeworks
		student_to_team = Hash.new
		Presentations::csv_reading(student_to_team)
		fill_value 1
		fill_value 2
		fill_minus_ones
		fill_zeroes
		cleanup
	end

	def fill_value value
		@HOMEWORK_FOLDERS.each_with_index do |homework, cur_index|
			system "git checkout `git rev-list -1 --before=\"#{@DEADLINES[cur_index]}\" master` -q" if value == 2
			# puts "index of #{homework} is #{cur_index}"
			case homework
			when 'vhodno_nivo/'
				check_entry_level value
			when 'class002_homework/'
				check_folder homework, cur_index, /^[a-zA-Z0-9]+_[a-zA-Z0-9]+_Class2_[12].rb$/, value
			when 'class003_homework/'
				check_folder homework, cur_index, /^[a-zA-Z0-9]+_[a-zA-Z0-9]+_Class3_[12].rb$/, value
			when 'class004/'
				check_folder homework, cur_index, /^[a-zA-Z0-9]+_[a-zA-Z0-9]+_Class4_[12].rb$/, value
			when 'class009_homework/'
				# Presentations::presentation_names data, student_to_team, i, programs_to_check
			when 'class012_homework/', 'class014_homework/'
				check_folder homework, cur_index, /^[a-zA-Z0-9]+_[a-zA-Z0-9]+_[AB]_\d+.rb$/, value
			when 'class017_homework/homework1/'
				check_folder homework, cur_index, /^[a-zA-Z0-9]+_[a-zA-Z0-9]+_[AB]_\d+.rb$/, value
			when 'class017_homework/homework2/'
				check_folder homework, cur_index, /^[a-zA-Z0-9]+_[a-zA-Z0-9]+_[AB]_\d+.rb$/, value
			end
		end
	end

	def fill_minus_ones
		(@HOMEWORK_FOLDERS.size+1).upto(@data.first.last.size - 1) do |index|
			@data.each_value { |v| v[index] ||= -1 }
		end
	end

	def fill_zeroes
		@data.each_value do |results|
			results.map! { |curr_hw| curr_hw ||= 0 }
		end
	end

	def check_entry_level value_to_write
		acceptable_extensions = [ '.c', '.cpp', '.cc', '.rb', '.py', '.java', '.html', '.js', '.pas' ]
      	hash = Hash.new { |hash, student_name| hash[student_name] = Array.new }
      	checked_programs = 0

		Dir.glob("vhodno_nivo/**/*.*") do |file|
	        first_name, last_name, problem_num = file.gsub(/.*\/|\..*/, '').split('_')

	        if acceptable_extensions.include?(File.extname(file)) && (Integer(problem_num) rescue false)
	          problem_num = problem_num.to_i
	          unless first_name.empty? || last_name.empty? || !problem_num.between?(2,18)
	            full_name = first_name.capitalize + '_' + last_name.capitalize
	            # puts full_name

	            if value_to_write == 2

	              # next unless @helper_for_n_option["vhodno_nivo/"].first.key? full_name
	              unless @helper_for_n_option["vhodno_nivo/"].first.key? full_name
	              	puts "next for #{full_name}"
	              	next
	              end
	            end

	            if hash.size >= @how_many_to_check.to_i && !(hash.key? full_name)
	            	puts "next for #{full_name}"
	              next
	            end

	            hash[full_name] << problem_num unless hash[full_name].include? problem_num
	          end
	        end
	    end

	    case value_to_write
	      when 1
	        hash.each { |name, problems| problems.size >= 3 ? @data[name][0] = 1 : @data[name][0] = 0 }
	      when 2
	        hash.each { |name, problems| @data[name][0] = 2 if problems.size >= 3 }
	    end

	    @helper_for_n_option["vhodno_nivo/"] << hash
	end

	def check_folder folder_path, index_in_database, filename_format, value_to_write
  	@@flog_flay_index += 1
    checked_programs = 0
    Dir.glob("#{folder_path}**/*.*") do |file_path|
      filename = file_path.split('/').last

      if filename =~ filename_format
        first_name, last_name = filename.split('_')
        full_name = first_name + '_' + last_name
        if value_to_write == 2
          next unless @helper_for_n_option[folder_path].include? full_name
        end
        # puts "working on #{full_name}"
        @data[full_name][index_in_database] = value_to_write
        checked_programs += 1 if value_to_write == 1 # only the first time around
        @helper_for_n_option[folder_path] << full_name if value_to_write == 1
        if value_to_write == 1 # Run flay and flog on the latest versions
          flog_output = `flog #{file_path} 2> /dev/null` # Ignore the standard error
          flog_value_index_in_results = @HOMEWORK_FOLDERS.size + @@flog_flay_index - 1#+ HOMEWORK_NUMBERS_FLOG_FLAY.index(cur_hw_number)

          if $?.to_i == 0
            flog_value = flog_output.split("\n").first.split(':').first.gsub(' ', '')
            @data[full_name][flog_value_index_in_results] = flog_value
          else
            @data[full_name][flog_value_index_in_results] = "error"
          end

          flay_output = `flay #{file_path}`

          flay_value_index_in_results = @HOMEWORK_FOLDERS.size + @HOMEWORK_NUMBERS_FLOG_FLAY.size + @@flog_flay_index - 1

          flay_value = flay_output.split("\n").first.match(/\d+/)

          @data[full_name][flay_value_index_in_results] = flay_value
          # BUG: FLAY ENCOUNTERING AN ERROR -> the error code flay returns is 0 regardless of whether an error
          #     occurred or not, therefore I cannot do what I did with flog 
          #     Momchil's homework 12 does not compile and "error" gets written in the g12 column (flog), as expected
          #     this is not the case with flay, though - in the y12 column there is a 0
        end
        break if checked_programs.to_i == @how_many_to_check.to_i
        @helper_for_n_option[folder_path].delete full_name if value_to_write == 2
      end
    end
    @helper_for_n_option[folder_path].clear if value_to_write == 2  
  end

  def cleanup
  	system("git checkout master -q")
	Dir.chdir @current_path
  end
end