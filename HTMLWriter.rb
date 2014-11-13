require 'nokogiri'

class HTMLWriter
	def write data, time_taken
		html_results = Nokogiri::HTML::Builder.new do |html|
		html.html{
			html.head{
				html.title "Results"
			}
			html.body{
				html.table{
					html.tr{
						html.td "#{time_taken}"
						html.td ""
						html.td "VH"
						html.td "002"
						html.td "003"
						html.td "004"
						html.td "009"
						html.td "012"
						html.td "014"
					}
					data.each{|key, value|
						html.tr{
							html.td key.split('_').first
							html.td key.split('_').last
							value.each{|value|
								html.td value
							}
						}
					}
				}
			}
		}
		end
		File.open("results_Dimitar_Terziev_A_6.html","w"){ |file| 
			file.write(html_results.to_html)
		}
	end
end
