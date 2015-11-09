require 'sinatra/base'
require 'sinatra/flash'
require 'sass'
require 'slim'
require './sinatra/auth'
require 'v8'
require 'coffee-script'
require 'dm-core'
require 'dm-migrations'
require 'pony'
require_relative 'asset-handler'

class ApplicationController < Sinatra::Base
  enable :method_override
  use AssetsHandler
  register Sinatra::Flash
  register Sinatra::Auth

  configure do
    enable :sessions
    set :start_time, Time.now
    set :username, 'sergey'
    set :password, 'secret'
  end

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

  before do
    last_modified settings.start_time
    etag settings.start_time.to_s
    cache_control :public, :must_revalidate
  end

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
end
