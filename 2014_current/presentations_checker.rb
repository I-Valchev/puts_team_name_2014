class PresentationsChecker
	def initialize data, repo_folder, project_to_names_file
		@data = data
		@repo_folder = repo_folder

		@student_to_team = Hash.new
		CSV.foreach("#{repo_folder}#{project_to_names_file}") do |entry|
			team_name = entry.first
			student_name = entry.last.gsub(' ', '_')

			@student_to_team[student_name] = team_name
		end
		@student_to_team.delete "Student_Name"
	end

	def check value_to_write, how_many_to_check
		checked_presentations = 0
		@student_to_team.each do |student, team|
			expected_file = "#{@repo_folder}class009_homework/#{team}.pdf"

			if File.exist?(expected_file)
				@data[student][4] = value_to_write
			else
				@data[student][4] ||= "no presentation found"
			end

			checked_presentations += 1

			break if how_many_to_check.to_i != -1 && checked_presentations >= how_many_to_check.to_i
		end
	end
end