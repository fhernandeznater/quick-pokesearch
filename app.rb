require "sinatra"
require "sinatra/reloader"

bad_string = false
bad_integer = false

unified_id = 0
generation = 0

display_name = ""
working_name = ""

official_name = ""
bulba_name = ""
serebii_net_name = ""

official_web_address = ""
bulba_web_address = ""
serebii_web_address = ""

def serebii_name_generator(working_name)
  if generation == 1 | 2 | 3 | 4 | 5 | 6 | 7
    serebii_name = unified_id.to_s # Figure out how to add leading zeroes to a string
  elsif generation == 8 | 9
    serebii_name = params.fetch("name")
  end
end

def serebii_web_address_generator(serebii_name)
  if generation == 1
    
    serebii_web_address = “https://www.serebii.net/pokedex/{serebii_name}.shtml”

  elsif generation == 2

    serebii_web_address = “https://www.serebii.net/pokedex-gs/{serebii_name}.shtml”

  elsif generation == 3

    serebii_web_address = “https://www.serebii.net/pokedex-rs/{serebii_name}.shtml”

  elsif generation == 4

    serebii_web_address = “https://www.serebii.net/pokedex-dp/{serebii_name}.shtml”

  elsif generation == 5

    serebii_web_address = “https://www.serebii.net/pokedex-bw/{serebii_name}.shtml”

  elsif generation == 6

    serebii_web_address = “https://www.serebii.net/pokedex-xy/{serebii_name}.shtml”

  elsif generation == 7

    serebii_web_address = “https://www.serebii.net/pokedex-sm/{serebii_name}.shtml”

  elsif generation == 8

    serebii_web_address = “https://www.serebii.net/pokedex-swsh/{serebii_name}”

  elsif generation == 9

    serebii_web_address = “https://www.serebii.net/pokedex-sv/{serebii_name}“

  else
    pp "You made a big mistake with the generation checker! Go fix it!"
  end
end

get("/") do
  redirect("/search_one")
end

get("/search_one") do
  erb(:search_one)
end

get("/search_two") do

  if params.fetch("search_id") == "" # Do parameters initialize as blank?
    formatted_string = params.fetch("search_name").gsub!(/[Ã¨Ã©ÃªÃ«Ä?Ä?Ä?Ä?Ä?]/u, 'e').gsub('.','').gsub(' ','-')
    api_url = "https://pokeapi.co/api/v2/pokemon/#{formatted_string}"
    @raw_respnose = HTTP.get(api_url)
    @raw_string = @raw_response.to_s
    @parsed_data = JSON.parse(@raw_string)
    @id = @parsed_data.fetch("id").to_i
    if @id == "" # I have to do this check somehow but I am not sure how to check for this
      bad_string = true
      redirect("/search_one")
    else
      unified_id = @id
    end
  end
  if params.fetch("search_name") == "" # Again, I should check if this works to check that this parameter hasn't been initialized
    @formatting_id = @search_id.to_i
    if @formatting_id > 1025 | @formatting_id < 1
      bad_integer = true
      redirect("/search_one")
    else
      unified_id = @formatting_id
    end
    api_url = "https://pokeapi.co/api/v2/pokemon/#{unified_id}"
    @raw_respnose = HTTP.get(api_url)
    @raw_string = @raw_response.to_s
    @parsed_data = JSON.parse(@raw_string)

    working_name = @parsed_data.fetch("name")
    display_name = working_name.capitalize
  end
  erb(:search_two)
end

get("/results") do
  erb(:search_results)
  unified_id = 0
  generation = 0

  display_name = ""
  working_name = ""

  official_name = ""
  bulba_name = ""
  serebii_net_name = ""

  official_web_address = ""
  bulba_web_address = ""
  serebii_web_address = ""
end
