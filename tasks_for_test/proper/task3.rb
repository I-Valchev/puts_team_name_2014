require_relative 'task.rb'

class Task3 < Task

	def init_contexts

		context1_1 = {
			:task_number=>"1",
			:which_to_sort => "first name",
			:in_what_order => "ASC",
			:expected=>
"F10letter1_L10letter1.rb,24
F10letter2_L10letter2.rb,24
F10letter3_L10letter4.rb,24
F10letters_L10letters.rb,24
FirstName3Invalid_LastName3Invalid.rb,37
FirstName3_LastName3Invalid.rb,31
invalid.rb,10
"
		}

		context1_2 = {
			:task_number=>"1",
			:which_to_sort => "last name",
			:in_what_order => "ASC",
			:expected=>
"F10letter1_L10letter1.rb,24
F10letter2_L10letter2.rb,24
F10letter3_L10letter4.rb,24
F10letters_L10letters.rb,24
FirstName3Invalid_LastName3Invalid.rb,37
FirstName3_LastName3Invalid.rb,31
invalid.rb,10
"
		}

		context1_3 = {
			:task_number=>"1",
			:which_to_sort => "last name",
			:in_what_order => "DESC",
			:expected=>
"F10letter1_L10letter1.rb,24
F10letter2_L10letter2.rb,24
F10letter3_L10letter4.rb,24
F10letters_L10letters.rb,24
FirstName3Invalid_LastName3Invalid.rb,37
FirstName3_LastName3Invalid.rb,31
invalid.rb,10
"
		}

		context1_4 = {
			:task_number=>"1",
			:which_to_sort => "first name",
			:in_what_order => "DESC",
			:expected=>
"F10letter1_L10letter1.rb,24
F10letter2_L10letter2.rb,24
F10letter3_L10letter4.rb,24
F10letters_L10letters.rb,24
FirstName3Invalid_LastName3Invalid.rb,37
FirstName3_LastName3Invalid.rb,31
invalid.rb,10
"
		}

	
		
		[context1_1,context1_2,context1_3,context1_4]
	end
	
	def initialize
		super 'task3.eruby'
	end

end
