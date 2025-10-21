# frozen_string_literal: true

workers Integer(ENV['WEB_CONCURRENCY'] || 0)
threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup Puma::Configuration::DEFAULTS[:rackup]
port ENV['PORT'] || 3000
environment ENV['RACK_ENV'] || 'development'
