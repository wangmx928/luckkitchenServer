ENV['RACK_ENV'] = 'test'
#the above line is used to specify the database in database.yml as test.
require 'sinatra' 
require 'sinatra/activerecord'
require 'json'
require 'stripe'
require 'digest/md5'

require './model/user'
require './helper/encrypt'

# db = URI.parse('postgres://Ping:pass@localhost/Ping')
# ActiveRecord::Base.establish_connection(
#   :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
#   :host     => db.host,
#   :username => db.user,
#   :password => db.password,
#   :database => db.path[1..-1],
#   :encoding => 'utf8'
# )
# If you have a config/database.yml, it will automatically be loaded, no need to specify it. 
# Also, in production, the $DATABASE_URL environment variable will automatically be read as the database 
# (if you haven't specified otherwise).

#the 
use Rack::Session::Pool, :expire_after => 2592000
set :session_secret, 'super secret'


helpers do
	def foo
		"foo in helpers"
	end
	def check_user_email(user_email)
		user = User.find_by(user_email: user_email)
	end
	def encrypt(text)
		Digest::MD5.hexdigest(text)
	end
end

get '/' do
	# psw = encrypt('123456')
	# user = User.create(user_email: "pingzhang@gmail.com", user_psw: psw, user_name: "Ping Zhang", user_tel: "7346233057")
  	status 200
  	return "Great, your backend is set up. Now you can configure the Stripe example iOS apps to point here."
end


post '/register' do
	user_email = params['email']
	user_psw = encrypt(params['psw'])
	user_name = params['name']
	user_tel = params['tel']

	check_user = User.find_by(user_email: user_email)
	if !check_user.nil?
		status 501
		return "User already exists"
	end

	user = User.create(user_email: user_email, user_psw: user_psw, user_name: user_name, user_tel: user_tel)
	if user.valid?
		status 200
		return "Register succeeded"
	else
		status 500
		return "Register failed"
	end
end

#done
post '/login' do
	user_email = params['email']
	psw = encrypt(params['psw'])
	user = User.find_by(user_email: user_email)
	if user.nil?
		status 404
		body "No user found!"
	elsif user.user_psw == psw
		status 200
		body "Log in succeeded!"
	else
		status 403
		body "Invalid password!"
	end
end

#the following part is used to deal with payment
Stripe.api_key = "sk_test_G34wY8GJcuKad0CO9qAvo5VR"

post '/charge' do
  # Get the credit card details submitted by the form
  	token = params[:stripeToken]
  	puts token
  	puts params[:amount]
  # Create the charge on Stripe's servers - this will charge the user's card
  	begin
    	charge = Stripe::Charge.create(
      		:amount => params[:amount], # this number should be in cents
      		:currency => "usd",
      		:card => token,
      		:description => "Example Charge"
    	)
  	rescue Stripe::CardError => e
    	status 402
    	return "Error creating charge."
  	end

  	status 200
  	return "Order successfully created"
end