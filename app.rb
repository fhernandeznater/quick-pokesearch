require "sinatra"
require "sinatra/reloader"

require "http"

enable :sessions

# unified_id = 0
# generation = 0

# display_name = ""
# working_name = ""

# official_name = ""
# bulba_name = ""
# serebii_net_name = ""

# official_web_address = ""
# bulba_web_address = ""
# serebii_web_address = ""

def serebii_name_generator(working_name)
  if generation <= 7
    serebii_name = unified_id.to_s.rjust(3, "0") # Figure out how to add leading zeroes to a string
  elsif generation > 7
    serebii_name = params.fetch("name")
  end
end

def serebii_web_address_generator(serebii_name)
  if generation == 1
    serebii_web_address = "https://www.serebii.net/pokedex/#{serebii_name}.shtml"
  elsif generation == 2
    serebii_web_address = "https://www.serebii.net/pokedex-gs/#{serebii_name}.shtml"
  elsif generation == 3
    serebii_web_address = "https://www.serebii.net/pokedex-rs/#{serebii_name}.shtml"
  elsif generation == 4
    serebii_web_address = "https://www.serebii.net/pokedex-dp/#{serebii_name}.shtml"
  elsif generation == 5
    serebii_web_address = "https://www.serebii.net/pokedex-bw/#{serebii_name}.shtml"
  elsif generation == 6
    serebii_web_address = "https://www.serebii.net/pokedex-xy/#{serebii_name}.shtml"
  elsif generation == 7
    serebii_web_address = "https://www.serebii.net/pokedex-sm/#{serebii_name}.shtml"
  elsif generation == 8
    serebii_web_address = "https://www.serebii.net/pokedex-swsh/#{serebii_name}"
  elsif generation == 9
    serebii_web_address = "https://www.serebii.net/pokedex-sv/#{serebii_name}"
  end

  return serebii_web_address
end

get("/") do
  redirect("/search_one")
end

get("/search_one") do
  session.store(:bad_string, false)
  session.store(:bad_integer, false)
  erb(:search_one)
end

get("/search_two") do
  search_id = params.fetch("search_id", "")
  search_name = params.fetch("search_name", "")

  if not search_name.empty?
    # Searching by name
    formatted_string = search_name.gsub('é', 'e').gsub('. ','').gsub(' ','-').gsub(': ', '-')
    api_url = "https://pokeapi.co/api/v2/pokemon/#{formatted_string}"
    raw_response = HTTP.get(api_url)
    parsed_data = JSON.parse(raw_response.to_s)

    @id = parsed_data.fetch("id").to_i

    if @id.to_s.empty?
      session.store(:bad_string, true)
      redirect("/search_one")
    else
      session.store(:unified_id, @id)
      working_name = parsed_data.fetch("name")
      session.store(:display_name, working_name.capitalize)
    end

  elsif not search_id.empty? 
    # Searching by ID
    @formatting_id = @search_id.to_i
    if @formatting_id > 1025 || @formatting_id < 1
      session.store(:bad_integer, true)
      redirect("/search_one")
    else
      session.store(:unified_id, @formatting_id)
    end
    api_url = "https://pokeapi.co/api/v2/pokemon/#{unified_id}"
    raw_response = HTTP.get(api_url)
    parsed_data = JSON.parse(raw_response.to_s)

    working_name = parsed_data.fetch("name")
    session.store(:display_name, working_name.capitalize)
    session.store(:working_name, working_name)
  elsif search_name.empty? && search_id.empty?
    redirect("/search_one")
  end

  erb(:search_two)
end

get("/results") do
  bulba_name = session.fetch(:working_name).capitalize
  official_name = session.fetch(:working_name)

  @official_web_address = "https://www.pokemon.com/us/pokedex/{official_name}"

  @bulba_web_address = "https://bulbapedia.bulbagarden.net/wiki/{bulba_name}_(Pokémon)"



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
