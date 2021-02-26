require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "yaml"
require "bcrypt"

# Defined permament session secret for the purpose of testing. Not for deployment.
configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
end

helpers do
  def find_words_to_replace(text_block)
    words_to_redact = text_block.split(' ').each_with_object([]) do |word, array| 
      array << word if word.match?(/\[.*?\]/)
    end
  end

  def replace_words_with_blanks(text_block, words_to_redact)
    # add in word number of spaces -2 to account for []
    # iterate over the text block
    # iterate over the words to redact
  end
end

# Load a worksheet or return and error if there is not worksheet at the specified index.
def load_worksheet(id)
  worksheet = session[:worksheets].find{ |worksheet| worksheet[:id] == id }
  return worksheet if worksheet

  session[:error] = "The specified worksheet cannot be found."
  redirect "/worksheets"
end

# Return an error message if the name is invalid. Return nil if the name is valid.
def error_for_worksheet_name(worksheet_name)
  if !(1..100).cover? worksheet_name.size
    "Worksheet name must be between 1 and 100 characters."
  elsif session[:worksheets].any? { |list| list[:worksheet_name] == worksheet_name }
    "Worksheet name must be unique."
  end
end

# create error to check for one period
def error_for_worksheet_body(text_block)
  if text_block.count(".") < 1
    "Worksheet must contain at least one sentence that ends with a period ('.')."
  end
end

def next_element_id(elements)
  max = elements.map { |element| element[:id] }.max || 0
  max + 1
end

before do
  session[:worksheets] ||= []
end

get "/" do
  redirect "/worksheets"
end

# View list of worksheets
get "/worksheets" do
  @worksheets = session[:worksheets]
  erb :worksheets, layout: :layout
end

# Render the new worksheet form
get "/worksheets/new" do
  erb :new_worksheet, layout: :layout
end

# Create a new worksheet
post "/worksheets" do
  worksheet_name = params[:worksheet_name].strip
  text_block = params[:text_block].strip
  
  name_error = error_for_worksheet_name(worksheet_name)
  text_block_error = error_for_worksheet_body(text_block)

  if name_error
    session[:error] = name_error
    erb :new_worksheet, layout: :layout
  elsif text_block_error
    session[:error] = text_block_error
    erb :new_worksheet, layout: :layout
  else
    words_to_redact = find_words_to_replace(text_block)
    redacted_text_block = replace_words_with_blanks(text_block, words_to_redact)
    id = next_element_id(session[:worksheets])
    session[:worksheets] << { id: id, worksheet_name: worksheet_name, text_block: redacted_text_block }
    session[:success] = "Worksheet created."
    redirect "/worksheets"
  end
end

# View a single worksheet
get "/worksheets/:id" do
  @worksheet_id = params[:id].to_i
  @worksheet = load_worksheet(@worksheet_id)
  erb :worksheet, layout: :layout
end

