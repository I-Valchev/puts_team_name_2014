require_relative 'task.rb'

class Task1 < Task

	def init_contexts
	
		context1_1 = {
			:task_number=>"1",
			:condition=>"more expensive than",
			:value=>"10 dollars",
			:in_what_order=>"ASC",
			:expected=>
"F5le8,L5le1
F5le2,L5le2
F5le3,L5le3
"
		}

		context1_2 = {
			:task_number=>"1",
			:condition=>"cheaper than",
			:value=>"15 dollars",
			:in_what_order=>"DESC",
			:expected=>
"F5le8,L5le1
F5le2,L5le2
F5le3,L5le3
"
		}

		context1_3 = {
			:task_number=>"1",
			:condition=>"released after",
			:value=>"2000",
			:in_what_order=>"ASC",
			:expected=>
"F5le8,L5le1
F5le2,L5le2
F5le3,L5le3
"
		}

		context1_4 = {
			:task_number=>"1",
			:condition=>"released before",
			:value=>"2007",
			:in_what_order=>"DESC",
			:expected=>
"F5le8,L5le1
F5le2,L5le2
F5le3,L5le3
"
		}
		
		[context1_1,context1_2,context1_3,context1_4]
	end
	
	def initialize
		super 'task1.eruby'
	end
end
