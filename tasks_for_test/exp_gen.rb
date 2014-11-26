require 'csv'
require 'json'
require 'nokogiri'
def generate_expected(sort_by, order, condition_object, condition, condition_value, task_num, path)
	arr = []
	case task_num
	when 1
		f = File.open("example.xml")
		doc = Nokogiri::XML(f)
		f.close
		xml_arr = doc.to_xml.split(/<\/?album>/)[1..-2]
		xml_arr.each{|album|
			is_condition_met = eval("#{album.split(/<\/?price>/)[1].to_i}#{condition}#{condition_value.to_s}")
			if is_condition_met
				arr.push(album.split(/<\/?name>/)[1])
			end
			arr.uniq.sort
			arr.reverse if order=="DESC"
		}
		CSV.open("expected#{task_num}.csv","w") do |csv|
			arr.each do |el|
				csv << [el]
			end
		end
	when 2
		condition_object = condition_object.to_i-1
		Dir.glob("#{path}*") do |file|
			file_name = file.to_s.gsub(/\A.*\/|\..*/,'')
			is_condition_met = eval("#{file_name.split('_')[condition_object].length}==#{condition_value}")
			if is_condition_met
				arr.push(file_name.split('_'))
			end
		end
		arr.sort_by{|element|element[sort_by]}
		arr.reverse if order=="DESC"
		json_hash=Hash.new
		json_hash["students_with_#{condition_value}_letters"]=Array.new
		json_insides = json_hash["students_with_#{condition_value}_letters"]
		arr.each do |el|
			loc_hash=Hash.new
			loc_hash["first_name"] = el[0]
			loc_hash["last_name"] = el[1]
			loc_hash["number"] = el[2]
			loc_hash["class"] = el[3]
			json_insides.push loc_hash
		end
		pretty_json = JSON.pretty_generate(json_hash)
		File.open("expected#{task_num}.json", "w") do |result|
			result.puts pretty_json
		end
	when 3
		csv_pars = []
		CSV.foreach(path) do |person|
		   	csv_pars << person
		end
		csv_pars.each{|person|
			if person.include?("0")
				arr.push("person[0]_person[1]")
			end
			arr.uniq.sort
			arr.reverse if order=="DESC"
		}
		json_hash=Hash.new
		json_hash["students_with_zero"]=Array.new
		json_insides = json_hash["students_with_zero"]
		arr.each do |el|
			json_insides.push el
		end
		pretty_json = JSON.pretty_generate(json_hash)
		File.open("expected#{task_num}.json", "w") do |result|
			result.puts pretty_json
		end
	end
end
generate_expected(0,"ASC","1",">",5,2,"/home/dtrz/puts_team_name_2014/tasks_for_test/fixture_2/")
