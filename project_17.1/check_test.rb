repo_path = ARGV[0]

Dir.glob("#{repo_path}class017_test/files_for_exam_2/results/*.rb") do |long_filepath|
	file = long_filepath.split('/').last

	next unless file =~ /^\w+_\w+_\d+_\w+.rb$/

	first_name, last_name = file.split('_')
	hashcode = file.split('.').first.split('_').last

	next unless hashcode.length == 8

	# puts "+++ +++ +++"
	# puts first_name + last_name + " -> " + hashcode

	Dir.glob("#{repo_path}class017_test/files_for_exam_2/expects/#{hashcode}.*") do |expect_file|
		expect_content = File.read(expect_file)
		# puts expect_content
		# system('ruby #{long_filepath}')
	end
end

ALL_FIXTURE_PATHS = [
	"Denis_Stoinev_13_B/fixture/",
	"Iliyan_Germanov_17_B/fixture/",
	"Radoslav_Kostadinov_22_A/fixture/",
	"Stanislav_Iliev_26_B/fixture/",
	"Stefan_Iliev_B_28/fixture/",
	"Vanya_Santeva_5_B/fixture/"
	# "Ivailo_Ivanov_A_9",
    # "Moretti_Georgiev_A_19" 
	# NO FIXTURES PRESENT
].freeze