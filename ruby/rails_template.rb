APP_NAME = @app_name.titleize
RAILS_VERSION = File.read('Gemfile').scan(%r{(?<=gem 'rails', '~> ).*(?=')}).first.to_f

##################
# Methods
##################
def install_webpack?
  driver = ask("Which front-end framework will you use? [vue, react, angular, stimulus] (default: vue)")
  driver = 'vue' if driver.blank?
  rails_command "webpacker:install:#{driver}"
end

def install_devise?
  return unless yes?("Would you like to install Devise?")
  gem "devise"
  generate "devise:install"
  environment "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }", env: 'development'
  environment "config.action_mailer.delivery_method = :smtp", env: 'development'
  environment "config.action_mailer.smtp_settings = { address: 'localhost', port: 1025 }", env: 'development'
  model_name = ask("What would you like the user model to be called? [user]")
  model_name = "user" if model_name.blank?
  generate "devise", model_name
end

def install_delayed_job?
  return unless yes? "Would you like to install Delayed Job?"
  gem 'delayed_job_active_record'
  generate "delayed_job:active_record"
  environment 'config.active_job.queue_adapter = :delayed_job', env: :production
  initializer "active_job.rb", <<~TEXT
  Delayed::Worker.queue_attributes = {
    high_priority: { priority: 0 },
    default: { priority: 5 },
    low_priority: { priority: 10 }
  }
  TEXT
  append_to_file 'Procfile', 'worker: bundle exec rails jobs:work'
end

def install_sidekiq?
  return unless yes?("Would you like to install sidekiq?")
  gem 'sidekiq'
  environment 'config.active_job.queue_adapter = :sidekiq', env: :production
  environment "config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'", env: :production
  prepend_to_file 'config/routes.rb', "require 'sidekiq/web'\n\n"
  route <<~TEXT
  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end
  TEXT
  append_to_file 'Procfile', 'worker: bundle exec sidekiq -q default -q mailers'
end

def install_postmarkapp?
  return unless yes?("Would you like to instal postmarkapp for mailing?")
  gem 'postmark-rails'
  environment 'config.action_mailer.delivery_method = :postmark', env: :production
  environment 'config.action_mailer.postmark_settings = { api_token: Rails.application.credentials.postmark_api_token }', env: :production
  puts 'Save your Postmark Server API Token to `config/credentials.yml.enc` by running `rails secret then rails credentials:edit`'
end

def install_haml?
  return unless yes? "Would you like to install Haml and convert your erb views to haml?"
  gem 'hamlit-rails'
  rails_command 'hamlit:erb2haml'
end

# Everything starts here!

# Remove all coments and empty space fron the gemfile and routes
gsub_file 'Gemfile', /(^#|^. #).*?\n+/, ''
gsub_file 'Gemfile', /^[\r\n]+/, "\n"
gsub_file 'config/routes.rb', /(^#|^. #).*?\n+/, ''

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
  file env_file, <<~TEXT
  DATABASE_USERNAME=
  DATABASE_PASSWORD=
  TEXT
end
append_to_file '.gitignore', '.env'

# Replace database.yml settings
remove_file('config/database.yml')
file 'config/database.yml', <<~YAML
default: &default
  adapter: postgresql
  username: ENV.fetch('DATABASE_USERNAME') { 'postgres' }
  password: ENV.fetch('DATABASE_PASSWORD') { 'postgres' }
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: accounting_development

test:
  <<: *default
  database: accounting_test

production:
  url: <%= ENV['DATABASE_URL'] %>
YAML

file 'Procfile', <<~TEXT
  web: bundle exec rails server -p $PORT
TEXT

after_bundle do
  install_webpack?
  install_devise?
  install_delayed_job?
  install_sidekiq?
  install_haml?
  install_postmarkapp?
  if yes?('Generate home controller and root path?')
    generate :controller, 'home index'
    gsub_file 'config/routes.rb', "get 'home/index'", "root to: 'home#index'"
  end


  application "config.time_zone = 'America/Mexico_City'"

  run 'spring stop'
  git add: '.'
  git commit: "-m 'Initial commit'"
  puts "****************************************"
  puts "Don't forget to create and migrate your db!"
  puts "****************************************"
end
