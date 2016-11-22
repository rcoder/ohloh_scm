require 'rake'
require 'rake/clean'
require 'rake/testtask'

require 'rubygems'
require 'rubygems/package_task'

spec = Gem::Specification.new do |s|
  s.name = 'ohloh_scm'
  s.version = '0.0.1'
  s.author = 'Robin Luckey'
  s.email = 'robin@ohloh.net'
  s.homepage = 'http://labs.ohloh.net'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Ohloh Source Control Management Library'
  s.files = FileList['README', 'COPYING', '{bin,lib,test}/**/*']
  s.require_path = 'lib'
  s.executables = 'ohlog'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README']
  s.test_files = FileList["test/**/*"]
end

Gem::PackageTask.new(spec) do |pkg|
  pkg.need_tar = true
  pkg.need_zip = true
end

Rake::TestTask.new :unit_tests do |t|
	t.test_files = FileList[File.dirname(__FILE__) + '/test/unit/**/*_test.rb']
end

task :default => :unit_tests

