require 'time'
require_relative 'CSVWriter'
require_relative 'HTMLWriter'
require_relative 'XMLWriter'
require_relative 'JSONWriter'
require_relative 'SVGWriter'

start_time = Time.now

TOTAL_HOMEWORKS = 6
HOMEWORK_NUMBERS = ['', 2, 3, 4, 9, 12, 14]
HOMEWORK_NUMBERS_FLOG_FLAY = [2, 3, 4, 12, 14].freeze
HOMEWORK_NAMES = ['vh_nivo', 'class002', 'class003', 'class004', 'class009', 'class012', 'class014'].freeze
DEADLINES = [
	'Sep 17 2014 20:00', 'Sep 22 2014 20:00', 'Sep 24 2014 20:00', 'Sep 29 2014 20:00', 
	'Oct 27 2014 20:00','Nov 10 2014 20:00','Nov 13 2014 06:00'
].freeze

repo_folder = ARGV[0]

def check_entry_level data, value_to_write
	acceptable_extensions = [ '.c', '.cpp', '.cc', '.rb', '.py', '.java', '.html', '.js', '.pas' ]
	hash = Hash.new { |hash, student_name| hash[student_name] = Array.new }

	Dir.glob("vhodno_nivo/**/*.*") do |file|
		first_name, last_name, problem_num = file.gsub(/.*\/|\..*/, '').split('_')

		if acceptable_extensions.include?(File.extname(file)) && (Integer(problem_num) rescue false)
			problem_num = problem_num.to_i
			unless first_name.empty? || last_name.empty? || !problem_num.between?(2,18)
				full_name = first_name.capitalize + '_' + last_name.capitalize
				hash[full_name] << problem_num unless hash[full_name].include? problem_num
			end
		end
	end

	case value_to_write
		when 1
			hash.each { |name, problems| problems.size >= 3 ? data[name][0] = 1 : data[name][0] = 0 }
		when 2
			hash.each { |name, problems| data[name][0] = 2 if problems.size >= 3 }
	end
end

def check_folder folder_path, data, folder_number, filename_format, value_to_write
	Dir.glob("#{folder_path}**/*.*") do |file_path|
		filename = file_path.split('/').last

		if filename =~ filename_format
			first_name, last_name = filename.split('_')
			full_name = first_name + '_' + last_name
			data[full_name][folder_number] = value_to_write

			if value_to_write == 1 # Run flay and flog on the latest versions
				flog_output = `flog #{file_path} 2> /dev/null` # Ignore the standard error

				cur_class = folder_path.split('_').first # folder_path is either class??? or class???_homework
				
				cur_hw_number = cur_class.match(/[1-9]+/).to_s.to_i # match returns MatchData, it has no to_i method
				flog_value_index_in_results = TOTAL_HOMEWORKS + 1 + HOMEWORK_NUMBERS_FLOG_FLAY.index(cur_hw_number)

				if $?.to_i == 0
					flog_value = flog_output.split("\n").first.split(':').first.gsub(' ', '')
					data[full_name][flog_value_index_in_results] = flog_value
				else
					data[full_name][flog_value_index_in_results] = "error"
				end

				flay_output = `flay #{file_path}`

				flay_value_index_in_results = TOTAL_HOMEWORKS + 1 + HOMEWORK_NUMBERS_FLOG_FLAY.size + 
					HOMEWORK_NUMBERS_FLOG_FLAY.index(cur_hw_number)

				flay_value = flay_output.split("\n").first.match(/\d+/)

				data[full_name][flay_value_index_in_results] = flay_value

				# BUG: FLAY ENCOUNTERING AN ERROR -> the error code flay returns is 0 regardless of whether an error
				# 		occurred or not, therefore I cannot do what I did with flog 
				# 		Momchil's homework 12 does not compile and "error" gets written in the g12 column (flog), as expected
				# 		this is not the case with flay, though - in the y12 column there is a 0
			end
		end
	end
end

def presentation_names data, student_to_team, value_to_write
	data.each do |student_name, results|
		file = "#{ARGV[0]}class009_homework/#{student_to_team[student_name]}.pdf"
		data[student_name][4] = value_to_write if student_to_team.key?(student_name) && File.exist?(file)
	end
end

def csv_reading(student_to_team)
	CSV.foreach("#{ARGV[0]}class009_homework/project_to_names.csv") do |entry|
		team_name = entry.first
		student_name = entry.last.gsub(' ', '_')
		student_to_team[student_name] = team_name
	end
end

data = Hash.new do |hash, student_name| 
	hash[student_name] = Array.new(HOMEWORK_NAMES.size + 2*HOMEWORK_NUMBERS_FLOG_FLAY.size) 
end
current_path = Dir.pwd
Dir.chdir repo_folder

# --- CHECKING
student_to_team = Hash.new
csv_reading(student_to_team)
for i in 1..2
	0.upto(TOTAL_HOMEWORKS) do |curr_hw|
		system "git checkout `git rev-list -1 --before=\"#{DEADLINES[curr_hw]}\" master` -q" if i==2
		case curr_hw
			when 0
				check_entry_level data, i
			when 1..2
				check_folder "#{HOMEWORK_NAMES[curr_hw]}_homework/", data, curr_hw, /^[a-zA-Z0-9]+_[a-zA-Z0-9]+_Class#{HOMEWORK_NUMBERS[curr_hw]}_[12].rb$/, i
			when 3
				check_folder "class004", data, 3, /^[a-zA-Z0-9]+_[a-zA-Z0-9]+_Class4_[12].rb$/, i
			when 4
				presentation_names data, student_to_team, i
			when 5..6
				check_folder "#{HOMEWORK_NAMES[curr_hw]}_homework/", data, curr_hw, /^[a-zA-Z0-9]+_[a-zA-Z0-9]+_[AB]_\d+.rb$/, i
		end
	end
end

# fill in the missing flog and flay values with -1, i.e. no homework, no value to write, not 0 which is a value!
7.upto(data.first.last.size - 1) do |index| 
	data.each_value { |v| v[index] ||= -1 }
end

# --- ENZEROING

data.each_value do |results|
	results.map! { |curr_hw| curr_hw ||= 0 }
end

system("git checkout master -q")
Dir.chdir current_path
time_taken = Time.now - start_time

# --- WRITING

format = 'csv'
if ARGV.include?('-o')
	format_index = ARGV.index('-o')+1
	format = ARGV[format_index]
end
writer = eval("#{format.upcase}Writer.new") if format =~ /\Axml\Z|\Ahtml\Z|\Ajson\Z|\Asvg\Z|\Acsv\Z/
writer.write data.sort, time_taken
