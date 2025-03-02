require "sinatra"
require "sinatra/reloader"

get("/") do
  "
  <h1>Welcome to your Sinatra App!</h1>
  <p>Define some routes in app.rb</p>
  "
  erb(:search_one)
end

get("/search_details") do
  erb(:search_two)
end

get("/results") do
  erb(:search_results)
end
