require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/flash'
require 'slim'
require 'sass'
require 'pony'
require 'v8'
require 'coffee-script'
require './sinatra/auth'
require './song.rb'

configure :development do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
  set email_address: 'smtp.gmail.com',
      email_user_name: 'info@example.ru',
      email_password: 'secret',
      email_domain: 'localhost.localdomain'
end

configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'])
  set email_address: 'smtp.sendgrid.net',
      email_user_name: ENV['SENDGRID_USERNAME'],
      email_password: ENV['SENDGRID_PASSWORD'],
      email_domain: 'heroku.com'
end

configure do
  set :username, 'sergey'
  set :password, 'secret'
end

helpers do
  def css(*stylesheets)
    stylesheets.map do |stylesheet|
      "<link rel=\"stylesheet\" href=\"/#{stylesheet}.css\" media=\"all\" />"
    end.join
  end

  def current?(path='/')
    (request.path==path || request.path==path+'/') ? "current" : nil
  end

  def set_title
    @title ||= "Songs By Sinatra"
  end

  def send_message
    Pony.mail(
      from: "no-reply <" + settings.email_user_name + ">",
      to: 'sergey@gmail.com',
      subject: params[:name] + " has contacted you",
      body: params[:message] + " [email: " + params[:email] + "]",
      via: :smtp,
      via_options: {
        address: settings.email_address,
        port: '587',
        enable_starttls_auto: true,
        user_name: settings.email_user_name,
        password: settings.email_password,
        authentication: :plain,
        domain: settings.email_domain
      })
  end
end

before do
  set_title
end

get('/styles.css'){ sass :styles, style: :compressed }
get('/application.js'){ coffee :application }

get '/' do
  slim :home
end

get '/about' do
  @title = "All About This Website"
  slim :about
end

get '/contact' do
  @title = "Get in touch"
  slim :contact
end

post '/contact' do
  send_message
  flash[:notice] = "Thank you for your message. We'll be in touch soon"
  redirect to('/')
end

not_found do
  slim :not_found
end
