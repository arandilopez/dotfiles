
APP_NAME = @app_name.titleize
RAILS_VERSION = File.read('Gemfile').scan(%r{(?<=gem 'rails', '~> ).*(?=')}).first

##############################
## INSTALL GEMS
##############################
# Remove all coments and empty space fron the gemfile
gsub_file 'Gemfile', /(^#|^. #).*?\n+/, ''
gsub_file 'Gemfile', /^[\r\n]+/, "\n"
enable_webpack = yes?("Enable webpack?")
enable_bcrypt = yes?("Enable bcrypt for has_secure_password?")
enable_devise = yes?("Enable devise for authenticacion?") unless enable_bcrypt
enable_delayed_job = yes?("Enable delayed job for jobs?")
enable_haml = yes?("Enable haml?")
gem "haml-rails", "~> 1.0" if enable_haml
gem 'bcrypt' if enable_bcrypt
gem 'devise' if enable_devise
gem 'webpacker', '~> 3.4' if enable_webpack
gem 'delayed_job_active_record' if enable_delayed_job
gem 'faker'
gem_group :development, :test do
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
end

run 'bundle install'

if enable_haml
  ENV['HAML_RAILS_DELETE_ERB'] = 'true'
  rails_command 'haml:erb2haml'
end

if enable_webpack
  rails_command 'webpacker:install'
  rails_command 'webpacker:install:vue'
end

if enable_delayed_job
  generate 'delayed_job:active_record'
end

if enable_devise
  generate 'devise:install'
  generate 'devise user'
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

##############################
## GENERATING HOME CONTROLLER
##############################
if yes?('Generate home controller and root path?')
  generate :controller, 'home index'
  gsub_file 'config/routes.rb', "get 'home/index'", "root to: 'home#index'"
end

##############################
## MODEL & DB
##############################
unless File.exist?('app/models/user.rb')
  if yes?('Generate a user-model?')
    params = [:model, 'user', 'email']
    params << 'password_digest' if enable_bcrypt
    generate(*params)
    gsub_file 'app/models/user.rb', "Record\n", "Record\n\thas_secure_password\n" if enable_bcrypt
  end
end

environment "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }", env: 'development'
environment "config.action_mailer.delivery_method = :smtp", env: 'development'
environment "config.action_mailer.smtp_settings = { address: 'localhost', port: 1025 }", env: 'development'

after_bundle do
  run 'spring stop'
  git add: '.'
  git commit: "-m 'Initial commit'"
  puts "****************************************"
  puts "Don't forget to migrate your db!"
  puts "****************************************"
end
