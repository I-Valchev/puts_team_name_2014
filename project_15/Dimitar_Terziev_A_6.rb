require 'time'
require_relative "CSVWriter"
require_relative "HTMLWriter"
require_relative "XMLWriter"
require_relative "JSONWriter"
require_relative "SVGWriter"

TOTAL_HOMEWORKS = 6
HOMEWORK_NUMBERS = ["",2,3,4,9,12,14]
HOMEWORK_NAMES = ["vh_nivo","class002","class003","class004","class009","class012","class014"].freeze
DEADLINES = ["Sep 17 2014 20:00","Sep 22 2014 20:00","Sep 24 2014 20:00","Sep 29 2014 20:00","Oct 27 2014 20:00","Nov 10 2014 20:00","Nov 13 2014 06:00"].freeze
time_start = Time.now

repo_folder = ARGV[0]
def check_entry_level data, value_to_write
	acceptable_extensions = [ '.c', '.cpp', '.cc', '.rb', '.py', '.java', '.html', '.js', '.pas' ]
	hash = Hash.new {|hash, key| hash[key] = Array.new}
	Dir.glob("vhodno_nivo/**/*.*") do |file|
		first_name, last_name, problem_num = file.gsub(/.*\/|\..*/,'').split('_')
		if acceptable_extensions.include?(File.extname(file)) && (Integer(problem_num) rescue false)
			problem_num = problem_num.to_i
			unless first_name.empty? || last_name.empty? || !(1..18)===problem_num
				hash_key = first_name.capitalize+'_'+last_name.capitalize
				hash[hash_key].push problem_num unless hash[hash_key].include? problem_num
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
def check_folder folder_path, hash, folder_number, filename_format, value_to_write
	Dir.glob("#{folder_path}**/*.*") do |file|
		if file.split('/').last =~ filename_format
			first_name, last_name = file.split('/').last.split('_')
			hash[first_name+'_'+last_name][folder_number] = value_to_write
		end
	end
end
def presentation_names data, student_to_team, value_to_write
	data.each do |key, value|
		file = "#{ARGV[0]}class009_homework/#{student_to_team[key]}.pdf"
		data[key][4] = value_to_write if student_to_team.key?(key) && File.exist?(file)
	end
end
def csv_reading(student_to_team)
	CSV.foreach("#{ARGV[0]}class009_homework/project_to_names.csv") do |entry|
		team_name = entry.first
		student_name = entry.last.gsub(' ', '_')
		student_to_team[student_name] = team_name
	end
end

data = Hash.new { |hash, key| hash[key] = Array.new }
current_path = Dir.pwd
Dir.chdir repo_folder
data.each { |key, value| data[key][value] = nil }

# --- CHECKERER
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
				check_folder "class004/", data, 3, /^[a-zA-Z0-9]+_[a-zA-Z0-9]+_Class4_[12].rb$/, i
			when 4
				presentation_names data, student_to_team, i
			when 5..6
				check_folder "#{HOMEWORK_NAMES[curr_hw]}_homework/", data, curr_hw, /^[a-zA-Z0-9]+_[a-zA-Z0-9]+_[AB]_\d+.rb$/, i
		end
	end
end

# --- ENZEROING

data.each_value{ |key|
	0.upto(TOTAL_HOMEWORKS){ |counter| key[counter]=0 if key[counter].nil? }
}
system("git checkout master -q")
time_taken = Time.now - time_start
Dir.chdir current_path

# --- WRITING

format = 'csv'
if ARGV.include?('-o')
	format_index = ARGV.index('-o')+1
	format = ARGV[format_index]
end
writer = eval("#{format.upcase}Writer.new") if format =~ /\Axml\Z|\Ahtml\Z|\Ajson\Z|\Asvg\Z|\Acsv\Z/
writer.write data.sort, time_taken
