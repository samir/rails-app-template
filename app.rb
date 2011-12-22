RAW_REPO_URL = "https://raw.github.com/samir/rails-app-template/master"

run "rm -rf test"
remove_file "README"
remove_file "public/index.html"
remove_file "public/robots.txt"
remove_file "app/assets/images/rails.png"
remove_file "app/views/layouts/*"

use_devise = false
use_devise = true if yes?("Would you want to use Devise? (yes or no)")

if use_devise
  model_name = ask("What do you want to call the devise model (default: User)?")
  model_name = "User" if model_name.strip.blank?
end

gem "carrierwave"
gem "dalli"
gem "haml"
gem "kaminari"
gem "mini_magick"
gem "permalink"
gem "simple_form"
gem "swiss_knife"
gem "bourbon"
gem "devise" if use_devise

gem "capybara",             :group => :test
gem "factory_girl",         :group => :test
gem "factory_girl-preload", :group => :test
gem "ffaker",               :group => :test
gem "fuubar",               :group => :test
gem "guard-spork",          :group => :test
gem "shoulda-matchers",     :group => :test
gem "simplecov",            :group => :test

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

get "https://raw.github.com/svenfuchs/rails-i18n/master/rails/locale/en-US.yml", "config/locales/default.en.yml"
get "https://raw.github.com/svenfuchs/rails-i18n/master/rails/locale/pt-BR.yml", "config/locales/default.pt-BR.yml"

run "mkdir -p vendor/assets/javascripts"

get "https://raw.github.com/jzaefferer/jquery-validation/master/jquery.validate.js", "vendor/assets/javascripts/jquery.validate.js"
get "https://github.com/fnando/dispatcher-js/raw/master/dispatcher.js",              "vendor/assets/javascripts/dispatcher.js"

# Twitter Bootstrap
get "https://raw.github.com/twitter/bootstrap/master/bootstrap.css",             "vendor/assets/stylesheets/bootstrap.css"
get "https://raw.github.com/twitter/bootstrap/master/bootstrap.min.css",         "vendor/assets/stylesheets/bootstrap.min.css"

get "https://raw.github.com/twitter/bootstrap/master/js/bootstrap-alerts.js",    "vendor/assets/javascripts/bootstrap-alerts.js"
get "https://raw.github.com/twitter/bootstrap/master/js/bootstrap-buttons.js",   "vendor/assets/javascripts/bootstrap-buttons.js"
get "https://raw.github.com/twitter/bootstrap/master/js/bootstrap-dropdown.js",  "vendor/assets/javascripts/bootstrap-dropdown.js"
get "https://raw.github.com/twitter/bootstrap/master/js/bootstrap-modal.js",     "vendor/assets/javascripts/bootstrap-modal.js"
get "https://raw.github.com/twitter/bootstrap/master/js/bootstrap-popover.js",   "vendor/assets/javascripts/bootstrap-popover.js"
get "https://raw.github.com/twitter/bootstrap/master/js/bootstrap-scrollspy.js", "vendor/assets/javascripts/bootstrap-scrollspy.js"
get "https://raw.github.com/twitter/bootstrap/master/js/bootstrap-tabs.js",      "vendor/assets/javascripts/bootstrap-tabs.js"
get "https://raw.github.com/twitter/bootstrap/master/js/bootstrap-twipsy.js",    "vendor/assets/javascripts/bootstrap-twipsy.js"

get "#{RAW_REPO_URL}/defaults/assets/javascripts/jquery.maskedinput.js",         "vendor/assets/javascripts/jquery.maskedinput.js"
get "#{RAW_REPO_URL}/defaults/assets/javascripts/jquery.maskedinput.min.js",     "vendor/assets/javascripts/jquery.maskedinput.min.js"
get "#{RAW_REPO_URL}/defaults/assets/javascripts/jquery.ui.datepicker-pt-BR.js", "vendor/assets/javascripts/jquery.ui.datepicker-pt-BR.js"
get "#{RAW_REPO_URL}/defaults/assets/javascripts/selectivizr-min.js",            "vendor/assets/javascripts/selectivizr-min.js"
get "#{RAW_REPO_URL}/defaults/assets/javascripts/selectivizr.js",                "vendor/assets/javascripts/selectivizr.js"


get "#{RAW_REPO_URL}/defaults/assets/stylesheets/application.css.sass.erb",      "app/assets/stylesheets/application.css"
get "#{RAW_REPO_URL}/defaults/assets/stylesheets/fonts.css.sass.erb",            "app/assets/stylesheets/fonts.css"
get "#{RAW_REPO_URL}/defaults/assets/stylesheets/simple_form.css.sass.erb",      "app/assets/stylesheets/simple_form.css"


activerecord_rescue = <<-ACTIVERECORD
  rescue_from "ActiveRecord::RecordNotFound" do |e|
    render :file => "\#{Rails.root}/public/404.html", :layout => false, :status => 404
  end
ACTIVERECORD
end

gsub_file "app/controllers/application_controller.rb", "protect_from_forgery", <<-APPLICATION_CONTROLLER
protect_from_forgery
#{activerecord_rescue}
APPLICATION_CONTROLLER

# Initializers
get "#{RAW_REPO_URL}/defaults/initializers/haml.rb",        "config/initializers/haml.rb"
get "#{RAW_REPO_URL}/defaults/initializers/simple_form.rb", "config/initializers/simple_form.rb"

remove_file "app/views/layouts/application.html.erb"
get "#{RAW_REPO_URL}/defaults/layouts/application.html.haml", "app/views/layouts/application.html.haml"
gsub_file "app/views/layouts/application.html.haml", "APP_NAME", app_name.humanize

remove_file ".gitignore"
get "#{RAW_REPO_URL}/defaults/gitignore", ".gitignore"

run "bundle install"

generate "simple_form:install"
generate "rspec:install"
generate "kaminari:config"
generate "kaminari:views default -e haml"
if use_devise
  generate "devise:install"
  generate "devise #{model_name.camelize}"
  generate "devise:views #{model_name.camelize} -e erb"
  run "for i in `find app/views/devise -name '*.erb'` ; do html2haml -e $i ${i%erb}haml ; rm $i ; done"
end
run "rake i18n:js:setup"

# if use_devise
#   gsub_file "spec/spec_helper.rb", "config.use_transactional_fixtures = true", <<-SPEC_HELPER
#   config.use_transactional_fixtures = true
#
#     config.include Sorcery::TestHelpers::Rails, :type => :controllers
#   SPEC_HELPER
# end


git :init
git :add => "."
git :commit => "-am 'Initial commit'"
