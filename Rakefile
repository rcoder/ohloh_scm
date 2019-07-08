# frozen_string_literal: true

require 'rake/testtask'

ENV['SIMPLECOV_START'] = 'true'
task default: :test

Rake::TestTask.new do |task|
  task.libs << 'spec'
  task.pattern = 'spec/**/*_spec.rb'
end
