# frozen_string_literal: true

require 'rubygems'
require 'bundler'
require 'yaml'

APP_PATH = '../app'

case ENV['RACK_ENV']
when 'production'
  STDOUT.puts 'loading gems for env production'
  loaded = Bundler.require :default
when 'test'
  STDOUT.puts 'loading gems for env test'
  loaded = Bundler.require :default, :test
else
  STDOUT.puts 'loading gems for env development'
  loaded = Bundler.require :default, :development
end

# load .env if the `dotenv' gem is loaded, otherwise don't bother
begin
  if loaded.any? { |dep| dep.name == 'dotenv' }
    Dotenv.load
  end
rescue NameError
end

require_relative "#{ENV['ROOT_PATH']}/config/configs"

Configs.load "#{ENV['ROOT_PATH']}/config/config.yml", (ENV["RACK_ENV"] || 'development')

Requirable.load! 'config', 'app'
