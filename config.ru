require 'bundler'

Bundler.require

require File.join(File.dirname(__FILE__), 'application')
run Application::Application