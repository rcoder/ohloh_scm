module Scm
end

require 'rbconfig'

$: << File.join(File.dirname(__FILE__),"..")

NULL_SHA1 = '0000000000000000000000000000000000000000' unless defined?(NULL_SHA1)

require 'lib/scm/systemu'
require 'lib/scm/scratch_dir'
require 'lib/scm/commit'
require 'lib/scm/diff'

require 'lib/scm/adapters/abstract_adapter'
require 'lib/scm/adapters/cvs_adapter'
require 'lib/scm/adapters/svn_adapter'
require 'lib/scm/adapters/git_adapter'

require 'lib/scm/parsers/parser'
require 'lib/scm/parsers/branch_number'
require 'lib/scm/parsers/cvs_parser'
require 'lib/scm/parsers/svn_parser'
require 'lib/scm/parsers/svn_xml_parser'
require 'lib/scm/parsers/array_writer'
require 'lib/scm/parsers/xml_writer'
require 'lib/scm/parsers/human_writer'
