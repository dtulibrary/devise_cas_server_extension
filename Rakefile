#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require 'bundler/gem_tasks'
Bundler.setup

require 'rspec/mocks/version'
require 'rspec/core/rake_task'

require File.expand_path('../spec/testapp/config/application', __FILE__)

Testapp::Application.load_tasks
