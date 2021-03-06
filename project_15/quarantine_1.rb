require 'time'
require_relative "CSVWriter"
require_relative "HTMLWriter"
require_relative "XMLWriter"
require_relative "JSONWriter"
require_relative "SVGWriter"

TOTAL_HOMEWORKS = 6
HOMEWORK_NAMES = {
	0 => "vh_nivo",
	1 => "class002",
	2 => "class003",
	3 => "class004",
	4 => "class009",
	5 => "class012",
	6 => "class014"
}.freeze

time_start = Time.now
repo_folder = ARGV[0]

def check_entry_level(folder_path)
	acceptable_extensions = [ '.c', '.cpp', '.cc', '.rb', '.py', '.java', '.html', '.js', '.pas' ]
	hash = Hash.new { |hash, key| hash[key] = Array.new(TOTAL_HOMEWORKS)}

	Dir.glob("#{folder_path}**/*.*") do |file|
	  extension = file.split('/').last.split('.').last
	  fields = file.split('/').last.split('.').first.split('_')
	  if acceptable_extensions.include?('.' + extension)
	    if fields.length == 3 
	      first_name = fields[0]
	      last_name = fields[1]
	      problem_num = fields[2]
	      unless first_name.empty? || last_name.empty? || problem_num.empty? 
		if problem_num.to_i.to_s == problem_num && 
		  problem_num.to_i > 1 && problem_num.to_i < 19 
		    unless hash[first_name.capitalize+'_'+last_name.capitalize].include? problem_num.to_i
		      hash[first_name.capitalize+'_'+last_name.capitalize].push problem_num.to_i
		    end
		end
	      end
	    end
	  end 
	end

	hash
end

def check_folder(folder_path, hash, folder_number, filename_format, value_to_write)
	Dir.glob("#{folder_path}**/*.*") do |file|
		if file.split('/').last =~ filename_format
			first_name = file.split('/').last.split('_')[0]
			last_name = file.split('/').last.split('_')[1]
			hash[first_name+'_'+last_name][folder_number] = value_to_write
		end
	end
end

def presentation_names(data, student_to_team, value_to_write)
	data.each do |key, value|
		if student_to_team.key? key 
			if File.exist?(ARGV[0] + "class009_homework/" + student_to_team[key] + '.pdf')
				data[key][4] = value_to_write
			end
		end
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
#idea: make a method that does all that to make it impossible to screw the order, and a sigle method for the similar checks
# --- ENTRY LEVEL
entry_level_hash = check_entry_level(ARGV[0] + 'vhodno_nivo/')
entry_level_hash.each { |name, problems| problems.size >= 3 ? data[name][0] = 1 : data[name][0] = 0 }

# --- CLASS 002
check_folder(ARGV[0] + 'class002_homework/', data, 1, /^[a-zA-Z0-9]+_[a-zA-Z0-9]+_Class2_[12].rb$/, 1)

# --- CLASS 003 
check_folder(ARGV[0] + 'class003_homework/', data, 2, /^[a-zA-Z0-9]+_[a-zA-Z0-9]+_Class3_[12].rb$/, 1)

# --- CLASS 004 
check_folder(ARGV[0] + 'class004/', data, 3, /^[a-zA-Z0-9]+_[a-zA-Z0-9]+_Class4_[12].rb$/, 1)

# --- CLASS 009
student_to_team = Hash.new
csv_reading(student_to_team)
presentation_names(data, student_to_team, 1)

# --- CLASS 012
check_folder(ARGV[0] + 'class012_homework/', data, 5, /^[a-zA-Z0-9]+_[a-zA-Z0-9]+_[AB]_\d+.rb$/, 1)

# --- CLASS 014
check_folder(ARGV[0] + 'class014_homework/', data, 6, /^[a-zA-Z0-9]+_[a-zA-Z0-9]+_[AB]_\d+.rb$/, 1)

# --- TIME-ON-CHECKS 

system('git checkout `git rev-list -1 --before="Sep 17 2014 20:00" master` -q')
entry_level_hash = check_entry_level(ARGV[0] + 'vhodno_nivo/')
entry_level_hash.each { |name, problems| data[name][0] = 2 if problems.size >= 3 }

system('git checkout `git rev-list -1 --before="Sep 22 2014 20:00" master` -q')
check_folder(ARGV[0] + 'class002_homework/', data, 1, /^[a-zA-Z0-9]+_[a-zA-Z0-9]+_Class2_[12].rb$/, 2)

system('git checkout `git rev-list -1 --before="Sep 24 2014 20:00" master` -q')
check_folder(ARGV[0] + 'class003_homework/', data, 2, /^[a-zA-Z0-9]+_[a-zA-Z0-9]+_Class3_[12].rb$/, 2)

system('git checkout `git rev-list -1 --before="Sep 29 2014 20:00" master` -q')
check_folder(ARGV[0] + 'class004/', data, 3, /^[a-zA-Z0-9]+_[a-zA-Z0-9]+_Class4_[12].rb$/, 2)

system('git checkout `git rev-list -1 --before="Oct 27 2014 20:00" master` -q')
presentation_names(data, student_to_team, 2)

system('git checkout `git rev-list -1 --before="Nov 10 2014 20:00" master` -q')
check_folder(ARGV[0] + 'class012_homework/', data, 5, /^[a-zA-Z0-9]+_[a-zA-Z0-9]+_[AB]_\d+.rb$/, 2)

system('git checkout `git rev-list -1 --before="Nov 13 2014 06:00" master` -q')
check_folder(ARGV[0] + 'class014_homework/', data, 6, /^[a-zA-Z0-9]+_[a-zA-Z0-9]+_[AB]_\d+.rb$/, 2)
# --- ENZEROING

data.each_value{|key|
	0.upto(TOTAL_HOMEWORKS){|counter|key[counter]=0 if key[counter].nil?}	#TODO make a better zeroer
}

system("git checkout master -q")
Dir.chdir current_path

time_taken = Time.now - time_start

# --- WRITING

writer = CSVWriter.new
case ARGV[2]
	when "xml"
		writer = XMLWriter.new
	when "csv"
		writer = CSVWriter.new 
	when "json"
		writer = JSONWriter.new
	when "html"
		writer = HTMLWriter.new
	when "svg"
		writer = SVGWriter.new
end
writer.write data.sort, time_taken
