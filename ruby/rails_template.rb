
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
gem 'bcrypt' if enable_bcrypt
gem 'webpacker', '~> 3.4' if enable_webpack
gem 'faker'
gem_group :development, :test do
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
end

run 'bundle install'

##############################
## CREATE FILE FOR ENV VARIABLES
##############################
create_file '.env'
create_file '.env.example'
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
if yes?('Generate a user-model?')
  params = [:model, 'user', 'name', 'email']
  params << 'password_digest' if enable_bcrypt
  generate(*params)
  run 'rails db:create db:migrate'
  gsub_file 'app/models/user.rb', "Record\n", "Record\n\thas_secure_password\n" if enable_bcrypt
end

if enable_webpack
  rails_command 'webpacker:install'
  rails_command 'webpacker:install:vue'
end
environment "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }", env: 'development'
environment "config.action_mailer.delivery_method = :smtp", env: 'development'
environment "config.action_mailer.smtp_settings = { address: 'localhost', port: 1025 }", env: 'development'

after_bundle do
  run 'spring stop'
  git add: '.'
  git commit: "-m 'Initial commit'"
end
