require 'yaml'

class CommandLineArgumentsParser
	def initialize arguments
		@arguments = arguments
		@valid_file_output_formats = YAML.load_file('valid_output_formats.yml')
	end

	def get_output_file_format(default={})
		format = (default.empty?) ? 'csv' : default[:default]
		if @arguments.include?('-o')
			format_index = @arguments.index('-o') + 1
			if @valid_file_output_formats.include?(@arguments[format_index])
				format = @arguments[format_index]
			else
				puts "Invalid format. Defaulting to CSV"
			end
		end
		format
	end

	def get_number_of_programs_to_check 
		programs_to_check = 100000000000000000000 
		if @arguments.include?('-n')
			num_index = @arguments.index('-n') + 1
			programs_to_check = (@arguments[num_index].nil?) ? 2 : @arguments[num_index]
		end
		programs_to_check
	end

	def get_repo_folder
		@arguments.first
	end
end
