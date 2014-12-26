require 'yaml'
require 'csv'
require_relative 'entry_level_checker'
require_relative 'presentations_checker'

class HomeworkChecker

	attr_reader :data, :HOMEWORK_NUMBERS_FLOG_FLAY, :HOMEWORK_NAMES

	def num_columns_in_table
		@HOMEWORK_NAMES.size + 2*@HOMEWORK_NUMBERS_FLOG_FLAY.size
	end

	def initialize repo_folder, how_many_to_check
		@repo_folder = repo_folder
		@how_many_to_check = how_many_to_check

		@HOMEWORK_FOLDERS = YAML.load_file('homework_folders.yml')
		@HOMEWORK_NUMBERS_FLOG_FLAY = YAML.load_file('homework_numbers_flog_flay.yml') 
		@HOMEWORK_NUMBERS_FLOG_FLAY.each { |a| puts a.class }
		@HOMEWORK_NAMES = YAML.load_file('homework_names.yml') 
		@DEADLINES = YAML.load_file('deadlines.yml')
		@REGEXES = YAML.load_file('regexes.yml')
		@REGEXES.map! {|el| el = /#{el}/ }

		@data = Hash.new do |hash, student_name| 
			hash[student_name] = Array.new num_columns_in_table 
		end

		@entry_level_checker = EntryLevelChecker.new(@data, how_many_to_check)
		@presentations_checker = PresentationsChecker.new(@data, "#{repo_folder}", "class009_homework/project_to_names.csv")

		@current_path = Dir.pwd
		Dir.chdir repo_folder

		@@flog_flay_index = 0
		@helper_for_n_option = Hash.new do |hash, student_name| 
			hash[student_name] = Array.new
		end
	end

	def check_homeworks
		fill_value 1
		fill_value 2
		fill_minus_ones
		fill_zeroes
		cleanup
	end

	def checkout_repo_to_date date
		system "git checkout `git rev-list -1 --before=\"#{date}\" master` -q"
	end

	def fill_value value
		@HOMEWORK_FOLDERS.each_with_index do |homework, cur_index|
			checkout_repo_to_date @DEADLINES[cur_index] if value == 2
			case homework
			when 'vhodno_nivo/'
				@entry_level_checker.check value
			when 'class002_homework/'
				check_folder homework, cur_index, @REGEXES[cur_index], value
			when 'class003_homework/'
				check_folder homework, cur_index, @REGEXES[cur_index], value
			when 'class004/'
				check_folder homework, cur_index, @REGEXES[cur_index], value
			when 'class009_homework/'
				@presentations_checker.check value, @how_many_to_check
			when 'class012_homework/', 'class014_homework/'
				check_folder homework, cur_index, @REGEXES[cur_index], value
			when 'class017_homework/homework1/'
				check_folder homework, cur_index, @REGEXES[cur_index], value
			when 'class017_homework/homework2/'
				check_folder homework, cur_index, @REGEXES[cur_index], value
			end
		end
	end

	def fill_minus_ones
		(@HOMEWORK_FOLDERS.size).upto(num_columns_in_table - 1) do |index|
			@data.each_value { |v| v[index] ||= -1 }
		end
	end

	def fill_zeroes
		@data.each_value do |results|
			results.map! { |curr_hw| curr_hw ||= 0 }
		end
	end

	def check_folder folder_path, index_in_database, filename_format, value_to_write
  	@@flog_flay_index += 1
    checked_programs = 0
    puts index_in_database
    Dir.glob("#{folder_path}**/*.*") do |file_path|
      filename = file_path.split('/').last

      if filename =~ filename_format
      	puts filename
        first_name, last_name = filename.split('_')
        full_name = first_name + '_' + last_name
        if value_to_write == 2
          next unless @helper_for_n_option[folder_path].include? full_name
        end
        @data[full_name][index_in_database] = value_to_write
        checked_programs += 1 
        @helper_for_n_option[folder_path] << full_name
        if value_to_write == 1 # Run flay and flog on the latest versions
          flog_output = `flog #{file_path} 2> /dev/null` # Ignore the standard error
          flog_value_index_in_results = @HOMEWORK_FOLDERS.size + @@flog_flay_index - 1

          if $?.to_i == 0
            flog_value = flog_output.split("\n").first.split(':').first.gsub(' ', '')
            puts "flog for #{full_name} -> #{flog_value}"
            @data[full_name][flog_value_index_in_results] = flog_value
          else
            @data[full_name][flog_value_index_in_results] = "error"
          end

          flay_output = `flay #{file_path}`

          flay_value_index_in_results = @HOMEWORK_FOLDERS.size + @HOMEWORK_NUMBERS_FLOG_FLAY.size + @@flog_flay_index - 1

          flay_value = flay_output.split("\n").first.match(/\d+/)

          puts "flay for #{full_name} -> #{flay_value}"

          @data[full_name][flay_value_index_in_results] = flay_value
          # BUG: FLAY ENCOUNTERING AN ERROR -> the error code flay returns is 0 regardless of whether an error
          #     occurred or not, therefore I cannot do what I did with flog 
          #     Momchil's homework 12 does not compile and "error" gets written in the g12 column (flog), as expected
          #     this is not the case with flay, though - in the y12 column there is a 0
        end
        break if checked_programs.to_i == @how_many_to_check.to_i
      end
    end
  end

  def cleanup
  	system("git checkout master -q")
	Dir.chdir @current_path
  end
end
