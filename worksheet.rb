require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "yaml"
require "bcrypt"

# /
# new worksheet button
  # directs to /new
# hold a list of all the created worksheets

get "/" do
  erb :index, layout: :layout
end

# /new
# form to create a new work sheet
  # creating the worksheet
  # takes a block of text 
  # removes words that are surrounded by ()
  # on submit
    # direct to the newly created /worksheet/:id

get "/new" do
  erb :new, layout: :layout
end

# /worksheet/:id
# displays the worksheet

