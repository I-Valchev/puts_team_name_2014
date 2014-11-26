require_relative 'task.rb'

class Task2 < Task

	def init_contexts

		context1_1 = {
			:task_number=>"1",
			:how_many_letters=>"5",
			:what_name=>"first",
			:which_to_sort => "last name",
			:in_what_order => "ASC",
			:expected=>
"L5le1,F5le8
L5le2,F5le2
"
		}

		context1_2 = {
			:task_number=>"1",
			:how_many_letters=>"10",
			:what_name=>"last",
			:which_to_sort => "first name",
			:in_what_order => "DESC",
			:expected=>
"L5le1,F5le8
L5le2,F5le2
"
		}

		context1_3 = {
			:task_number=>"1",
			:how_many_letters=>"7",
			:what_name=>"first",
			:which_to_sort => "first name",
			:in_what_order => "DESC",
			:expected=>
"L5le1,F5le8
L5le2,F5le2
"
		}
		
		[context1_1,context1_2,context1_3]
	end
	
	def initialize
		super 'task2.eruby'
	end
	
end
