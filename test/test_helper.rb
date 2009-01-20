require 'test/unit'
require 'fileutils'
require 'find'

unless defined?(TEST_DIR)
	TEST_DIR = File.dirname(__FILE__)
end
require TEST_DIR + '/../lib/scm'

Scm::Adapters::AbstractAdapter.logger = Logger.new(File.open('log/test.log','a'))

unless defined?(REPO_DIR)
	REPO_DIR = File.expand_path(File.join(TEST_DIR, 'repositories'))
end

unless defined?(DATA_DIR)
	DATA_DIR = File.expand_path(File.join(TEST_DIR, 'data'))
end

class Scm::Test < Test::Unit::TestCase
	# For reasons unknown, the base class defines a default_test method to throw a failure.
	# We override it with a no-op to prevent this 'helpful' feature.
	def default_test
	end

	def assert_convert(parser, log, expected)
		result = ''
		parser.parse File.new(log), :writer => Scm::Parsers::XmlWriter.new(result)
		assert_buffers_equal File.read(expected), result
	end

	# assert_equal just dumps the massive strings to the console, which is not helpful.
	# Instead we try to indentify the line of the first error.
	def assert_buffers_equal(expected, actual)
		return if expected == actual

		expected_lines = expected.split("\n")
		actual_lines = actual.split("\n")

		expected_lines.each_with_index do |line, i|
			if line != actual_lines[i]
				assert_equal line, actual_lines[i], "at line #{i} of the reference buffer"
			end
		end

		# We couldnt' find the mismatch. Just bail.
		assert_equal expected_lines, actual_lines
	end

	# Expands a tarballed git repository and yields a GitAdapter that points to it.
	def with_git_repository(name)
		archive = name + '.tgz'
		if Dir.entries(REPO_DIR).include?(archive)
			Scm::ScratchDir.new do |dir|
				`tar xzf #{File.join(REPO_DIR, archive)} --directory #{dir}`
				yield Scm::Adapters::GitAdapter.new(:url => File.join(dir, name)).normalize
			end
		else
			raise RuntimeError.new("Repository archive #{File.join(REPO_DIR, archive)} not found.")
		end
	end

	def with_svn_repository(name)
		if Dir.entries(REPO_DIR).include?(name)
			Scm::ScratchDir.new do |dir|
				`cp -R #{File.join(REPO_DIR, name)} #{dir}`
				yield Scm::Adapters::SvnAdapter.new(:url => File.join(dir, name)).normalize
			end
		else
			raise RuntimeError.new("Repository archive #{File.join(REPO_DIR, name)} not found.")
		end
	end

	def with_cvs_repository(name)
		if Dir.entries(REPO_DIR).include?(name)
			Scm::ScratchDir.new do |dir|
				`cp -R #{File.join(REPO_DIR, name)} #{dir}`
				yield Scm::Adapters::CvsAdapter.new(:url => File.join(dir, name)).normalize
			end
		else
			raise RuntimeError.new("Repository archive #{File.join(REPO_DIR, name)} not found.")
		end
	end

	def with_hg_repository(name)
		if Dir.entries(REPO_DIR).include?(name)
			Scm::ScratchDir.new do |dir|
				`cp -R #{File.join(REPO_DIR, name)} #{dir}`
				yield Scm::Adapters::HgAdapter.new(:url => File.join(dir, name)).normalize
			end
		else
			raise RuntimeError.new("Repository archive #{File.join(REPO_DIR, name)} not found.")
		end
	end
end
