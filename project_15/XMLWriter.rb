require 'nokogiri'

class XMLWriter
	def write data, time_taken
		xml_results = Nokogiri::XML::Builder.new do |xml|
		xml.homework_evaluation{
			xml.title "Results"
			xml.description "results from homeworks' turn-in"
			xml.time_taken "#{time_taken}"
			xml.legend{
				xml.result "0-not turned in"
				xml.result "1-turned in but not on time"
				xml.result "2-turned in on time"
			}
			data.each{|key, value|
				xml.student{
					xml.name key
					xml.results{
						0.upto(TOTAL_HOMEWORKS) do |curr_hw|
							xml.send(HOMEWORK_NAMES[curr_hw], "#{value[curr_hw]}")
						end
					}
				}
			}
		}
		end
		File.open("results_Dimitar_Terziev_A_6.xml","w"){ |file| 
			file.write(xml_results.to_xml)
		}
	end
end
