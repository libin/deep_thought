$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

ENV['RACK_ENV'] = 'test'
ENV['SESSION_SECRET'] = 'secret'

require 'deep_thought'
require 'rubygems'
require 'fileutils'
gem 'minitest'
require 'minitest/autorun'
require 'rack/test'
require 'mocha/setup'
require 'capybara'
require 'database_cleaner'

begin; require 'turn/autorun'; rescue LoadError; end

DeepThought.setup(ENV)

Capybara.app = DeepThought::App

DatabaseCleaner.clean_with(:truncation)
DatabaseCleaner.strategy = :transaction

MiniTest::Unit::TestCase.add_setup_hook {
  DatabaseCleaner.start

  if File.directory?(".projects/_test")
    FileUtils.rm_rf(".projects/_test")
  end
}

MiniTest::Unit::TestCase.add_teardown_hook {
  if File.directory?(".projects/_test")
    FileUtils.rm_rf(".projects/_test")
  end

  DatabaseCleaner.clean
}

def login(email, password)
  visit '/login'
  within(".content > form") do
    fill_in 'email', :with => email
    fill_in 'password', :with => password
    click_button 'login'
  end
end
