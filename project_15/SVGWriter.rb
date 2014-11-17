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
		  	doc.rect x:-80, y:-400, width:660, height:500, fill: "#FFFFCC"
		  	doc.text_ "Results", x:175, y:-325, "font-size"=> 40
		  	doc.text_ "Time taken: #{time_taken}", x:-60, y:-385, "font-size"=> 10
		  	HOMEWORK_NAMES.each_with_index do |hw_name, column|
		  		percentage = (valid_tasks[column]/58.0)*100
		  		doc.rect x:(column*column_separation*5),y:-valid_tasks[column]*5,width:50,height:valid_tasks[column]*5,stroke:"red"
				doc.text_ "#{percentage.round(2)}%", x:(column*75), y:-(valid_tasks[column]*5)-20, "font-size"=> 15
				doc.text_ "(#{valid_tasks[column]}/58)", x:(column*75), y:-(valid_tasks[column]*5)-3, "font-size"=> 15
				doc.text_ hw_name, x:(column*column_separation*5), y:(column_separation-5), "font-size"=> 12
		  	end
		  end
		end
		#puts b.to_xml
		File.open("results_Dimitar_Terziev_A_6.svg", "w") do |file|
			file.puts b.to_xml
		end
	end
end

#stop offset="0%" style="stop-color:rgb(255,255,0);stop-opacity:1" />
#<stop offset="100%" style="stop-color:rgb(255,0,0);stop-opacity:1" />
#doc.linearGradient id:"fade_to_white", x1:"0%", y1:"0%", x2:"100%", x2:"0%", doc.stop( offset:"0%", "stop-color"=>"#75E3FF", "stop-opacity"=>1 ), doc.stop( offset:"100%", "stop-color"=>"#F1FCFF", "stop-opacity"=>1 )
