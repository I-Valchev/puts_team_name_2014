require 'nokogiri'

repo_path = ARGV[0]

student_to_arguments = {
	"Stanimir_Bogdanov" => "#{repo_path}class016/Vanya_Santeva_5_B/fixture/",
	"Elena_Karakoleva" => "#{repo_path}class016/Iliyan_Germanov_17_B/fixture/task1.csv",
	"Dimitar_Matev" => "#{repo_path}class016/Veselin_Dechev_2_A/fixture/"
}

student_to_produced_file = {
	"Stanimir_Bogdanov" => "result.json",
	"Elena_Karakoleva" => "result.xml",
	"Dimitar_Matev" => "result.csv"
}

results = Hash.new
student_to_arguments.each do |student_name, arguments|
	results[student_name] = nil
end

where_I_was = Dir.pwd
Dir.chdir "#{repo_path}class019_test/files_for_exam_2/results/"

Dir.glob("*.rb") do |long_filepath|
	file = long_filepath.split('/').last

	next unless file =~ /^\w+_\w+_\d+_\w+.rb$/

	first_name, last_name = file.split('_')
	hashcode = file.split('.').first.split('_').last

	next unless hashcode.length == 8

	Dir.glob("../expects/#{hashcode}.*") do |expect_file|
		expect_content = File.read(expect_file)
		if first_name == 'Elena' || first_name == 'Stanimir' || last_name == 'Matev'
			system("ruby #{long_filepath} #{student_to_arguments[first_name + '_' + last_name]}")
			if $?.to_i != 0
				results[first_name + '_' + last_name] = "error"
				next
			end
			produced_file_content = File.read(student_to_produced_file[first_name + '_' + last_name])
			results[first_name + '_' + last_name] = expect_content.chomp == produced_file_content.chomp ? '1' : '0'
			File.delete student_to_produced_file[first_name + '_' + last_name]
		end
	end
end

html_results = Nokogiri::HTML::Builder.new do |html|
	html.html {
		html.head {
			html.title 'Results for test from class019'
		}

		html.body {
			html.table(:border => 1) {
				results.sort_by { |name, result| name }.each do |student_name, result|
					first_name, last_name = student_name.split('_')
					html.tr { 
						html.td first_name
						html.td last_name
						html.td result
					}
				end
			}
		}
	}
end

Dir.chdir where_I_was

File.open('test_results.html','w') do |file| 
	file.write(html_results.to_html)
end