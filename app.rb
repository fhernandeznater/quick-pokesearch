require "sinatra"
require "sinatra/reloader"

get("/") do
  redirect("/search_one")
end

get("/search_one") do
  erb(:search_one)
end

get("/search_details") do
  erb(:search_two)
end

get("/results") do
  erb(:search_results)
end
