require 'time'
require_relative 'homework_checker'
require_relative 'command_line_arguments_parser'

start_time = Time.now

command_line_arguments_parser = CommandLineArgumentsParser.new(ARGV)
output_file_format = command_line_arguments_parser.get_output_file_format(default: 'csv') 
how_many_to_check = command_line_arguments_parser.get_number_of_programs_to_check 
repo_folder = command_line_arguments_parser.get_repo_folder

require_relative "#{output_file_format.upcase}Writer"

checker = HomeworkChecker.new(repo_folder, how_many_to_check)
checker.check_homeworks

writer = eval("#{output_file_format.upcase}Writer.new checker")

writer.write(checker.data.sort, Time.now - start_time)