require 'rubygems'
require 'sinatra'
require 'hominid' # MailChimp
require 'haml'
require 'sass'
require 'coffee-script'

# Set Sinatra variables
set :root, File.dirname(__FILE__)
set :haml, { :format => :html5 } # default Haml format is :xhtml

configure do
  # MailChimp configuration: ADD YOUR OWN ACCOUNT INFO HERE!
  set :mailchimp_api_key, ENV['MAILCHIMP-API'] 
  set :mailchimp_list_name, ENV['MAILCHIMP-LIST']
end

get '/' do
  haml :index
end

get '/styles' do
  content_type 'text/css', :charset => 'utf-8'
  scss :"scss/style"
  # less :"less/style"
end

get '/scripts/:name' do
  coffee :"/coffee/#{params[:name]}"
end

post '/signup' do
  email = params[:email]
  unless email.nil? || email.strip.empty?
    mailchimp = Hominid::API.new(settings.mailchimp_api_key)
    list_id = mailchimp.find_list_id_by_name(settings.mailchimp_list_name)
    raise "Unable to retrieve list id from MailChimp API." unless list_id
    mailchimp.list_subscribe(list_id, email, {}, 'html', false, true, true, false)
  end
  "Success."
end
