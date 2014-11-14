require 'nokogiri' # gem install nokogiri

class SVGWriter
	def write data, time_taken

		valid_tasks = Array.new(10)
		0.upto(6) do |init_ind|
			valid_tasks[init_ind] = 0
		end

		data.each do |value, i|
			0.upto(6){|checked_index|
				valid_tasks[checked_index] += 1 if i[checked_index].to_i == 2
			}
		end

		b = Nokogiri::XML::Builder.new do |doc|
		  doc.svg xmlns:"http://www.w3.org/2000/svg", viewBox:"0 -400 500 500" do
		  	column_separation = 15
		  	doc.text_ "Results", x:175, y:-325, "font-size"=> 40
		  	doc.text_ "Time taken: #{time_taken}", x:-60, y:-385, "font-size"=> 10
		  	0.upto(TOTAL_HOMEWORKS) do |column|
		  		percentage = (valid_tasks[column]/58.0)*100
		  		doc.rect x:(column*column_separation*5),y:-valid_tasks[column]*5,width:50,height:valid_tasks[column]*5,stroke:"red"
				doc.text_ "#{percentage.round(2)}%", x:(column*75), y:-(valid_tasks[column]*5)-3, "font-size"=> 15
				doc.text_ HOMEWORK_NAMES[column], x:(column*column_separation*5), y:(column_separation-5), "font-size"=> 12
		  	end
		  end
		end
		#puts b.to_xml
		File.open("results_Dimitar_Terziev_A_6.svg", "w") do |file|
			file.puts b.to_xml
		end
	end
end
