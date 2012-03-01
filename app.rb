use_edge_files = false
use_edge_files = true if yes?("Would you want to use edge version of assets files?")

if use_edge_files
 RAW_REPO_URL = "https://raw.github.com/samir/rails-app-template/master"
else
  RAW_REPO_URL = '/Users/samirbraga/Sites/github/rails-app-template'
end

run "rm -rf test"
remove_file "README"
remove_file "public/index.html"
remove_file "public/robots.txt"
remove_file "app/assets/images/rails.png"
remove_file "app/views/layouts/*"
remove_file "app/assets/stylesheets/application.css"

use_devise = false
use_devise = true if yes?("Would you want to use Devise? (yes or no)")

if use_devise
  model_name = ask("What do you want to call the devise model (default: User)?")
  model_name = "User" if model_name.strip.blank?
end

gem "haml"

install_image_gems = false
install_image_gems = true if yes?("Would you want to install gems for image manipulation? (yes or no)")

if install_image_gems
  gem "carrierwave"
  gem "mini_magick"
end

gem "dalli"
gem "kaminari"
gem "permalink"
gem "simple_form"
# gem "swiss_knife"
gem "bourbon"
gem "responders"

gem 'twitter-bootstrap-rails', :group => :assets

gem "devise" if use_devise

gem "capybara",             :group => :test
gem "factory_girl",         :group => :test
gem "factory_girl-preload", :group => :test
gem "ffaker",               :group => :test
gem "fuubar",               :group => :test
gem "guard-spork",          :group => :test
gem "shoulda-matchers",     :group => :test
gem "simplecov",            :group => :test

gem "haml-rails",           :group => :development

gem "guard-rspec",          :group => [:development, :test]
gem "jasmine", "1.1.0",     :group => [:development, :test]
gem "rspec-rails",          :group => [:development, :test]
gem "spork", "~> 0.9.0.rc", :group => [:development, :test]

# Comment some gems
# gsub_file "Gemfile", /gem "?'?dalli"?'?/i, '# gem "dally"'
# gsub_file "Gemfile", /gem "?'?kaminari"?'?/i, '# gem "kaminari"'

generators = <<-GENERATORS

    config.sass.preferred_syntax = :sass
    config.generators do |g|
      g.template_engine   :haml
      g.stylesheet_engine :sass
      g.test_framework    :rspec
      g.integration_tool  :rspec
      g.request_specs     true
      g.routing_specs     false
      g.view_specs        false
    end

GENERATORS
application generators
application "  config.assets.compress = true"


if use_edge_files
  get "https://raw.github.com/svenfuchs/rails-i18n/master/rails/locale/en-US.yml", "config/locales/default.en.yml"
  get "https://raw.github.com/svenfuchs/rails-i18n/master/rails/locale/pt-BR.yml", "config/locales/default.pt-BR.yml"
else
  get "#{RAW_REPO_URL}/defaults/config/locales/default.en.yml",    "config/locales/default.en.yml"
  get "#{RAW_REPO_URL}/defaults/config/locales/default.pt-BR.yml", "config/locales/default.pt-BR.yml"
end

run "mkdir -p vendor/assets"

get "#{RAW_REPO_URL}/defaults/vendors/assets/*", "vendor/assets"

if use_edge_files
  get "https://raw.github.com/jzaefferer/jquery-validation/master/jquery.validate.js", "vendor/assets/javascripts/jquery.validate.js"
  get "https://github.com/fnando/dispatcher-js/raw/master/dispatcher.js",              "vendor/assets/javascripts/dispatcher.js"
end

activerecord_rescue = <<-ACTIVERECORD
  rescue_from "ActiveRecord::RecordNotFound" do |e|
    render :file => "\#{Rails.root}/public/404.html", :layout => false, :status => 404
  end
ACTIVERECORD

gsub_file "app/controllers/application_controller.rb", "protect_from_forgery", <<-APPLICATION_CONTROLLER
protect_from_forgery
#{activerecord_rescue}
APPLICATION_CONTROLLER

# Config and Initializers

get "#{RAW_REPO_URL}/defaults/config/database.yml",         "config/databse.yml"
gsub_file "config/databse.yml", "APP_NAME", app_name

get "#{RAW_REPO_URL}/defaults/initializers/haml.rb",        "config/initializers/haml.rb"

remove_file "app/views/layouts/application.html.erb"
get "#{RAW_REPO_URL}/defaults/layouts/application.html.haml", "app/views/layouts/application.html.haml"
gsub_file "app/views/layouts/application.html.haml", "APP_NAME", app_name.humanize

remove_file ".gitignore"
get "#{RAW_REPO_URL}/defaults/gitignore", ".gitignore"

run "bundle install"

# Generators

# SimpleForm
generate "simple_form:install --bootstrap"

# remove_file "config/initializers/simple_form.rb"
# get "#{RAW_REPO_URL}/defaults/initializers/simple_form.rb", "config/initializers/simple_form.rb"

generate "rspec:install"
generate "kaminari:config"
generate "kaminari:views default -e haml"
if use_devise
  generate "devise:install"
  generate "devise #{model_name.camelize}"
  generate "devise:views -e erb"
  run "for i in `find app/views/devise -name '*.erb'` ; do html2haml -e $i ${i%erb}haml ; rm $i ; done"
end
run "rake i18n:js:setup"

if use_devise
  gsub_file "spec/spec_helper.rb", "config.use_transactional_fixtures = true", <<-SPEC_HELPER
  config.use_transactional_fixtures = true
    config.include Devise::TestHelpers, :type => :controller
    config.extend ControllerMacros, :type => :controller

  SPEC_HELPER
end


git :init
git :add => "."
git :commit => "-am 'Initial commit'"


docs = <<-DOCS
Run the following commands to complete the setup of #{app_name.humanize}:

== MySQL
CREATE SCHEMA #{app_name}_development CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE SCHEMA #{app_name}_test CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE SCHEMA #{app_name}_production CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE SCHEMA #{app_name}_staging CHARACTER SET utf8 COLLATE utf8_general_ci;

DOCS

log docs
