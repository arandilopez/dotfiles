APP_NAME = @app_name.titleize
RAILS_VERSION = File.read('Gemfile').scan(%r{(?<=gem 'rails', '~> ).*(?=')}).first

##################
# Methods
##################
def install_webpack?
  return unless yes? "Would you like to install Webpack?"
  gem 'webpacker'
  rails_command 'webpacker:install'
  driver = ask("Which front-end framework will you use? [vue, react, angular, stimulus] (default: vue)")
  driver = 'vue' if driver.blank?
  rails_command "webpacker:install:#{driver}"
end

def install_devise?
  return unless yes?("Would you like to install Devise?")
  gem "devise"
  generate "devise:install"
  model_name = ask("What would you like the user model to be called? [user]")
  model_name = "user" if model_name.blank?
  generate "devise", model_name
end

def install_delayed_job?
  return unless yes? "Would you like to instal Delayed Job?"
  gem 'delayed_job_active_record'
  generate "delayed_job:active_record"
  environment 'config.active_job.queue_adapter = :delayed_job', env: :production
  initializer "active_job.rb", <<-TEXT
  Delayed::Worker.queue_attributes = {
    high_priority: { priority: -10 },
    default: { priority: 0 },
    low_priority: { priority: 10 }
  }
  TEXT
end

def install_haml?
  return unless yes? "Would you like to install Haml and convert your erb views to haml?"
  gem 'hamlit-rails'
  rails_command 'hamlit:erb2haml'
end

# Everything starts here!

# Remove all coments and empty space fron the gemfile
gsub_file 'Gemfile', /(^#|^. #).*?\n+/, ''
gsub_file 'Gemfile', /^[\r\n]+/, "\n"

# Adding dependencies
gem_group :development, :test do
  gem 'faker'
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
end

##############################
## CREATE FILE FOR ENV VARIABLES
##############################
%w{.env .env.example}.each do |env_file|
  file env_file, <<-TEXT
  DATABASE_USER=
  DATABASE_PASSWORD=
  DATABASE_PORT=5432
  DATABASE_HOST=localhost
  TEXT
end
append_to_file '.gitignore', ".env\n"

install_webpack?
install_delayed_job?
install_devise?
install_haml?

##############################
## GENERATING HOME CONTROLLER
##############################
if yes?('Generate home controller and root path?')
  generate :controller, 'home index'
  gsub_file 'config/routes.rb', "get 'home/index'", "root to: 'home#index'"
end

environment "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }", env: 'development'
environment "config.action_mailer.delivery_method = :smtp", env: 'development'
environment "config.action_mailer.smtp_settings = { address: 'localhost', port: 1025 }", env: 'development'

application "config.time_zone = 'America/Mexico_City'"

after_bundle do
  run 'spring stop'
  git add: '.'
  git commit: "-m 'Initial commit'"
  puts "****************************************"
  puts "Don't forget to create and migrate your db!"
  puts "****************************************"
end
