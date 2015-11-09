class Website < ApplicationController
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
end
