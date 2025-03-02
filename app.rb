require "sinatra"
require "sinatra/reloader"
require "http"

enable :sessions

def serebii_name_generator(working_name)
  if session.fetch(:generation) <= 7
    session.store(:serebii_name, session.fetch(:unified_id).to_s.rjust(3, "0"))
  elsif session.fetch(:generation) > 7
    session.store(:serebii_name, working_name)
  end
end

def serebii_web_address_generator(serebii_name)
  generation = session.fetch(:generation)
  serebii_web_address = ""

  case generation
  when 1
    serebii_web_address = "https://www.serebii.net/pokedex/#{serebii_name}.shtml"
  when 2
    serebii_web_address = "https://www.serebii.net/pokedex-gs/#{serebii_name}.shtml"
  when 3
    serebii_web_address = "https://www.serebii.net/pokedex-rs/#{serebii_name}.shtml"
  when 4
    serebii_web_address = "https://www.serebii.net/pokedex-dp/#{serebii_name}.shtml"
  when 5
    serebii_web_address = "https://www.serebii.net/pokedex-bw/#{serebii_name}.shtml"
  when 6
    serebii_web_address = "https://www.serebii.net/pokedex-xy/#{serebii_name}.shtml"
  when 7
    serebii_web_address = "https://www.serebii.net/pokedex-sm/#{serebii_name}.shtml"
  when 8
    serebii_web_address = "https://www.serebii.net/pokedex-swsh/#{serebii_name}"
  when 9
    serebii_web_address = "https://www.serebii.net/pokedex-sv/#{serebii_name}"
  end

  return serebii_web_address
end

get("/") do
  redirect("/search_one")
end

get("/search_one") do
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

    if raw_response.status.code == 404
      session.store(:bad_string, true)
      redirect("/search_one")
    else
      parsed_data = JSON.parse(raw_response.to_s)
      id = parsed_data.fetch("id").to_i
      session.store(:unified_id, id)
      working_name = parsed_data.fetch("name")
      session.store(:display_name, working_name.capitalize)
      session.store(:working_name, working_name)
    end

  elsif not search_id.empty?
    # Searching by ID
    formatting_id = search_id.to_i
    if formatting_id > 1025 || formatting_id < 1
      session.store(:bad_integer, true)
      redirect("/search_one")
    else
      session.store(:unified_id, formatting_id)
      api_url = "https://pokeapi.co/api/v2/pokemon/#{session.fetch(:unified_id)}"
      raw_response = HTTP.get(api_url)
      parsed_data = JSON.parse(raw_response.to_s)
      working_name = parsed_data.fetch("name")
      session.store(:display_name, working_name.capitalize)
      session.store(:working_name, working_name)
    end
  elsif search_name.empty? && search_id.empty?
    redirect("/search_one")
  end

  erb(:search_two)
end

get("/results") do
  bulba_name = session.fetch(:working_name).capitalize
  official_name = session.fetch(:working_name)

  @official_web_address = "https://www.pokemon.com/us/pokedex/#{official_name}"
  @bulba_web_address = "https://bulbapedia.bulbagarden.net/wiki/#{bulba_name}_(Pokémon)"

  session.store(:generation, params.fetch("gen_selection").to_i)

  serebii_formatted_name = serebii_name_generator(session.fetch(:working_name))

  @serebii_web_address = serebii_web_address_generator(serebii_formatted_name)

  erb(:search_results)
end
