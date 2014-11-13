require 'nokogiri' # gem install nokogiri

class SVGWriter
	def write data, time_taken

		valid_tasks = Array.new(10)
		valid_tasks[0] = 0
		valid_tasks[1] = 0
		valid_tasks[2] = 0
		valid_tasks[3] = 0
		valid_tasks[4] = 0
		valid_tasks[5] = 0
		valid_tasks[6] = 0

		data.each do |value, i|
			valid_tasks[0] += 1 if i[0].to_i == 2
			valid_tasks[1] += 1 if i[1].to_i == 2
			valid_tasks[2] += 1 if i[2].to_i == 2
			valid_tasks[3] += 1 if i[3].to_i == 2
			valid_tasks[4] += 1 if i[4].to_i == 2
			valid_tasks[5] += 1 if i[5].to_i == 2
			valid_tasks[6] += 1 if i[6].to_i == 2
		end

		b = Nokogiri::XML::Builder.new do |doc|
		  doc.svg xmlns:"http://www.w3.org/2000/svg", viewBox:"0 -150 200 200" do
		  	0.upto(6){|column|
		  		doc.rect x:column*15, y:-valid_tasks[column], width:10, height: valid_tasks[column]
		  		doc.text_ "text"
		  	}
		      	      #doc.text(x:80, y:0){"text"}
		  end
		end
		File.open("results_Dimitar_Terziev_A_6.svg", "w") do |file|
			file.puts b.to_xml
		end
	end
end
