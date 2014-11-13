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
		  	0.upto(6) do |column|
		  		percentage = (valid_tasks[column]/58.0)*100
		  		doc.rect x:(column*column_separation*5), y:-valid_tasks[column]*5, width:50, height: valid_tasks[column]*5, stroke:"red"
				doc.text_ "#{percentage.round(2)}%", x:(column*75), y:-(valid_tasks[column]*5)-10#, font-size:24
				doc.text_ "vh_nivo", x:(column*column_separation*5), y:+column_separation if column==0
				doc.text_ "class002", x:(column*column_separation*5), y:+column_separation if column==1
				doc.text_ "class003", x:(column*column_separation*5), y:+column_separation if column==2
				doc.text_ "class004", x:(column*column_separation*5), y:+column_separation if column==3
				doc.text_ "class009", x:(column*column_separation*5), y:+column_separation if column==4
				doc.text_ "class012", x:(column*column_separation*5), y:+column_separation if column==5
				doc.text_ "class014", x:(column*column_separation*5), y:+column_separation if column==6
		  	end
		  end
		end
		puts b.to_xml
		File.open("results_Dimitar_Terziev_A_6.svg", "w") do |file|
			file.puts b.to_xml
		end
	end
end
