require 'csv'
require 'json'
arr = []
order = "ASC"
condition = "line.include?(\"0\")"
num = 5
problem_num  = 3
to_do = <<END_OF_STRING
Ivo,Valchev,2,2,2,2,2,2
Dimitar,Nestorov,2,2,2,0,0,0
Marian,Belchev,2,0,2,2,0,0
Konstantin,Kostov,2,0,2,2,2,2
Dimitar,Terziev,2,2,2,2,2,2
Dimitar,Matev,2,2,2,0,2,2
Dimitar,Andreev,2,2,2,2,0,2
atanaska,ivancheva,2,0,0,0,0,0
Kamena,Dacheva,2,2,2,2,2,2
Vladimir,Yordanov,2,2,2,2,2,2
Denis,Stoinev,2,2,2,2,2,2
Velislav,Kostov,2,2,2,2,2,2
Kaloyan,Nikov,2,2,0,2,2,2
Lubomir,Yankov,2,2,2,2,2,2
Stefan,Radev,2,2,2,2,2,2
Veselina,Kolova,2,2,2,2,2,2
Simeon,Shopkin,2,2,2,2,0,2
Valentin,Georgiev,2,2,2,2,2,2
Stanislav,Gospodinov,2,2,2,2,0,0
Stanimir,Bogdanov,2,2,2,2,2,2
Lili,Kokalova,2,2,2,2,2,2
Iosyf,Saleh,2,2,2,2,2,2
Radoslav,Kostadinov,2,2,2,2,2,2
Ivelin,Slavchev,2,2,2,2,2,2
Valentin,Varbanov,2,2,2,2,2,2
Georgi,Ivanov,2,2,0,2,2,0
mladen,karadimov,2,0,0,0,0,0
END_OF_STRING
case problem_num
when 1
	to_do.each_line{|line|
		if eval condition
			arr.push(line.sub(',','_').split(',').first)
		end
		arr.uniq.sort
		arr.reverse if order=="DESC"
	}
	CSV.open("expected#{problem_num}.csv","w") do |csv|
		arr.each do |el|
			csv << [el]
		end
	end
when 2
	to_do.each_line{|line|
		if eval condition
			arr.push(line.gsub(/\..*|\n/,'').split('_'))
		end
		arr.uniq.sort
		arr.reverse if order=="DESC"
	}
	json_hash=Hash.new
	json_hash["students_with_#{num}_letters"]=Array.new
	json_insides = json_hash["students_with_#{num}_letters"]
	arr.each do |el|
		loc_hash=Hash.new
		loc_hash["first_name"] = el[0]
		loc_hash["last_name"] = el[1]
		loc_hash["number"] = el[2]
		loc_hash["class"] = el[3]
		json_insides.push loc_hash
	end
	pretty_json = JSON.pretty_generate(json_hash)
	File.open("expected#{problem_num}.json", "w") do |result|
		result.puts pretty_json
	end
when 3
	to_do.each_line{|line|
		if eval condition
			arr.push(line.sub(',','_').split(',').first)
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
	File.open("expected#{problem_num}.json", "w") do |result|
		result.puts pretty_json
	end
end
