# gem 'sinatra', '1.3.0'
require 'sinatra/base'
require 'sinatra/reloader' #if development?
require 'sqlite3'
require 'better_errors'
require 'open-uri'
require 'json'
require 'uri'

class Movies < Sinatra::Base
  configure :development do
    register Sinatra::Reloader 
  end

  before do
    @app_name = "Movies App"
    # sets the default page title
    @page_title = @app_name
  end

  get "/" do 
    @page_title += ":Home"
    erb :home
  end

  get "/search" do
    @page_title += ": Search for #{@query}"
    @query = params[:q]
    @button = params[:button]
    if @button == "lucky"
      file = open("http://www.omdbapi.com/?t=#{URI.escape(@query)}")
      @result = JSON.load(file.read)
      @actors = @result["Actors"].split(", ")
      @directors = @result["Director"].split(", ")
      erb :detail
    else
      file = open("http://www.omdbapi.com/?s=#{URI.escape(@query)}")
      @results = JSON.load(file.read)["Search"] || []
      if @results.size == 1
        redirect "/movies?id=#{@results.first["imdbID"]}"
      else
        erb :results
      end
    end
  end

  get "/movies" do
    @id = params[:id]
    file = open("http://www.omdbapi.com/?i=#{URI.escape(@id)}&tomatoes=true")
    @result = JSON.load(file.read)
    @query = params[:q]
    @actors = @result["Actors"].split(", ")
    @directors = @result["Director"].split(", ")
    erb :detail
  end

 run!
end