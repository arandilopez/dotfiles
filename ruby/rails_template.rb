# frozen_string_literal: true

### Helpers
def yarn(*packages)
  run("yarn add #{packages.join(' ')}")
end

def create_bin(name, command = nil)
  create_file "bin/#{name}" do
    <<~EOF
      #!/usr/bin/env ruby
      APP_ROOT = File.expand_path('..', __dir__)
      Dir.chdir(APP_ROOT) do
        begin
          exec '#{command || name}'
        rescue Errno::ENOENT
          $stderr.puts "#{name} executable was not detected in the system."
          exit 1
        end
      end
    EOF
  end
  `chmod +x bin/#{name}`
end

##################
# Methods
##################

def install_bootstrap?
  return unless yes?('Would you like to install Bootstrap?')

  yarn 'jquery', 'popper.js', 'bootstrap'

  inject_into_file 'config/webpack/environment.js', after: "const { environment } = require('@rails/webpacker')\n" do
    <<~JAVASCRIPT
      const webpack = require('webpack')
      environment.plugins.append('Provide', new webpack.ProvidePlugin({
        $: 'jquery',
        jQuery: 'jquery',
        'window.jQuery': 'jquery',
        Popper: ['popper.js', 'default']
      }))
    JAVASCRIPT
  end

  inject_into_file 'app/views/layouts/application.html.erb', before: '</head>' do
    <<~ERB
      <%= stylesheet_pack_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
    ERB
  end

  inject_into_file 'app/javascript/packs/application.js' do
    <<~JAVASCRIPT
      import 'bootstrap/dist/js/bootstrap'
      import 'bootstrap/dist/css/bootstrap'
    JAVASCRIPT
  end
end

def install_tailwind?
  return unless yes?('Would you like to install Tailwind?')

  yarn 'tailwindcss'
  run 'yarn tailwind init'
  run 'mkdir app/javascript/css'
  run 'touch app/javascript/css/application.css'
  inject_into_file 'app/javascript/css/application.css' do
    <<~CSS
      @import "tailwindcss/base";
      @import "tailwindcss/components";
      @import "tailwindcss/utilities";
    CSS
  end

  inject_into_file 'app/javascript/packs/application.js' do
    <<~JAVASCRIPT
      require("css/application.css")
    JAVASCRIPT
  end

  inject_into_file 'postcss.config.js', before: "require('postcss-import')" do
    <<~JAVASCRIPT
      require('tailwindcss'),
      require('autoprefixer'),
    JAVASCRIPT
  end

  gsub_file 'tailwind.config.js', /purge:\s\[],/, <<~PURGE
    purge: [
      './app/**/*.html.erb',
      './app/helpers/**/*.rb',
      './src/**/*.html',
      './src/**/*.vue',
      './src/**/*.jsx',
    ],
  PURGE

  inject_into_file 'app/views/layouts/application.html.erb', before: '</head>' do
    <<~ERB
      <%= stylesheet_pack_tag 'stylesheets', media: 'all', 'data-turbolinks-track': 'reload' %>
    ERB
  end
end

def install_frontend_framework?
  driver = ask('Which front-end framework will you use? [vue, react, angular, stimulus, none] (default: vue) (none option will not install any)')
  driver = 'vue' if driver.blank?
  return if driver == 'none'

  rails_command "webpacker:install:#{driver}"
end

def install_devise?
  return unless yes?('Would you like to install Devise?')

  run 'bundle add devise'
  run 'bundle install'
  generate 'devise:install'
  environment "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }", env: 'development'
  model_name = ask('What would you like the user model to be called? [default: user]')
  model_name = 'user' if model_name.blank?
  attributes = ''
  attributes = ask('What attributes?') if yes?("Do you want to any extra attributes to #{model_name}? [y/n]")
  run "rails generate devise #{model_name} #{attributes}"

  append_to_file 'test/test_helper.rb' do
    <<~CODE
      class ActionController::TestCase
        include Devise::Test::IntegrationHelpers
      end

      class ActionDispatch::IntegrationTest
        include Devise::Test::IntegrationHelpers
      end

      class ActionDispatch::SystemTestCase
        include Devise::Test::IntegrationHelpers
      end
    CODE
  end
end

def install_delayed_job?
  return unless yes? 'Would you like to install Delayed Job?'

  run 'bundle add delayed_job_active_record'
  run 'bundle install'
  generate 'delayed_job:active_record'
  environment 'config.active_job.queue_adapter = :delayed_job', env: :production
  initializer 'delayed_job_queues.rb', <<~TEXT
    Delayed::Worker.queue_attributes = {
      high_priority: { priority: 0 },
      default: { priority: 5 },
      low_priority: { priority: 10 }
    }
  TEXT
  append_to_file 'Procfile', 'worker: bundle exec rails jobs:work'
end

def install_sidekiq?
  return unless yes?('Would you like to install sidekiq?')

  run 'bundle add sidekiq'
  run 'bundle install'
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
  return unless yes?('Would you like to instal postmarkapp for mailing?')

  run 'bundle add postmark-rails'
  run 'bundle install'
  environment <<~RUBY, env: :production
    config.action_mailer.delivery_method = :postmark
    config.action_mailer.postmark_settings = { api_token: ENV.fetch('POSTMARK_API_TOKEN') }
  RUBY
  append_to_file '.env.example', 'POSTMARK_API_TOKEN='
  append_to_file '.env', 'POSTMARK_API_TOKEN='
  puts 'Save your Postmark Server API Token to `.env`'
end

def install_haml?
  return unless yes? 'Would you like to install Haml and convert your erb views to haml?'

  run 'bundle add hamlit-rails'
  run 'bundle install'
  rails_command 'hamlit:erb2haml'
end

def install_rubocop?
  return unless yes? 'Would you like to install Rubocop?'

  gem_group :development, :test do
    gem 'rubocop'
    gem 'rubocop-minitest'
    gem 'rubocop-performance'
    gem 'rubocop-rails'
  end

  run 'bundle install'

  create_file '.rubocop.yml' do
    <<~YAML
      require:
        - rubocop-rails
        - rubocop-performance
        - rubocop-minitest

      inherit_mode:
        merge:
          - Exclude

      AllCops:
      # RuboCop has a bunch of cops enabled by default. This setting tells RuboCop
      # to ignore them, so only the ones explicitly set in this file are enabled.
        DisabledByDefault: true
        NewCops: disabled
        Exclude:
          - '**/tmp/**/*'
          - '**/vendor/**/*'
          - '**/node_modules/**/*'

      Bundler/OrderedGems:
        Enabled: true
        AutoCorrect: true
      Layout/EmptyLinesAroundAttributeAccessor:
        Enabled: true
      Layout/LineLength:
        Enabled: true
        AutoCorrect: true
      Layout/SpaceAroundMethodCallOperator:
        Enabled: true
      Lint:
        Enabled: true
      Minitest:
        Enabled: true
      Performance:
        Enabled: true
      Rails:
        Enabled: true
      Security:
        Enabled: true
      Style/AccessorGrouping:
        Enabled: true
      Style/BisectedAttrAccessor:
        Enabled: true
      Style/ClassAndModuleChildren:
        Enabled: true
        AutoCorrect: true
      Style/ClassCheck:
        Enabled: true
      Style/CommandLiteral:
        Enabled: true
        EnforcedStyle: percent_x
      Style/Documentation:
        Enabled: false
      Style/ExponentialNotation:
        Enabled: true
      Style/FrozenStringLiteralComment:
        Enabled: true
      Style/HashEachMethods:
        Enabled: true
      Style/HashTransformKeys:
        Enabled: true
      Style/HashTransformValues:
        Enabled: true
      Style/HashSyntax:
        Enabled: true
      Style/RedundantAssignment:
        Enabled: true
      Style/RedundantFetchBlock:
        Enabled: true
      Style/RedundantRegexpCharacterClass:
        Enabled: true
      Style/RedundantRegexpEscape:
        Enabled: true
      Style/SlicingWithRange:
        Enabled: true
    YAML
  end

  create_bin 'rubocop', 'rubocop'
  create_bin 'rubocop_fix', 'rubocop --auto-correct-all'
end

# Everything starts here!

# Remove all coments and empty space fron the gemfile and routes
gsub_file 'Gemfile', /(^#|^. #).*?\n+/, ''
gsub_file 'Gemfile', /^[\r\n]+/, "\n"
gsub_file 'config/routes.rb', /(^#|^. #).*?\n+/, ''

# Adding dependencies
gem 'letter_opener', group: :development
gem_group :development, :test do
  gem 'faker'
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
end

##############################
## CREATE FILE FOR ENV VARIABLES
##############################
%w[.env .env.example].each do |env_file|
  file env_file, <<~TEXT
    DATABASE_USERNAME=
    DATABASE_PASSWORD=
  TEXT
end
append_to_file '.gitignore', '.env'

config <<~RUBY, env: :development
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.perform_deliveries = true
RUBY

# Replace database.yml settings
remove_file('config/database.yml')
file 'config/database.yml', <<~YAML
  default: &default
    adapter: postgresql
    username: <%= ENV.fetch('DATABASE_USERNAME') { 'postgres' } %>
    password: <%= ENV.fetch('DATABASE_PASSWORD') { 'postgres' } %>
    encoding: unicode
    pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

  development:
    <<: *default
    database: #{@app_name}_development

  test:
    <<: *default
    database: #{@app_name}_test

  production:
    url: <%= ENV['DATABASE_URL'] %>
YAML

file 'Procfile', <<~TEXT
  web: bundle exec rails server -p $PORT
TEXT

# Setup factory_bot_rails
File.open('test/test_helper.rb', 'r+') do |file|
  lines = file.each_line.to_a
  config_index = lines.map.with_index { |line, index| index if line == "end\n" }.last
  lines.insert(config_index, "  include FactoryBot::Syntax::Methods\n")
  file.rewind
  file.write(lines.join)
end

gsub_file 'config/environments/development.rb', "Rails.root.join('tmp', 'caching-dev.txt')",
          "Rails.root.join('tmp/caching-dev.txt')"

after_bundle do
  run 'spring stop'

  install_frontend_framework?
  install_bootstrap?
  install_tailwind?
  install_devise?
  install_delayed_job?
  install_sidekiq?
  install_postmarkapp?
  install_haml?
  install_rubocop?

  if yes?('Generate home controller and root path?')
    generate :controller, 'home index'
    gsub_file 'config/routes.rb', "get 'home/index'", "root to: 'home#index'"
  end

  application "config.time_zone = 'America/Mexico_City'"

  git add: '.'
  git commit: "-m 'Initial commit'"
  puts '*********************************************'
  puts "Don't forget to create and migrate your db!"
  puts '*********************************************'
end
