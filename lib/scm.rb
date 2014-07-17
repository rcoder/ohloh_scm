module Scm
end

#require 'rbconfig'

#$: << File.join(File.dirname(__FILE__),"..")

require_relative 'scm/shellout'
require_relative 'scm/scratch_dir'
require_relative 'scm/commit'
require_relative 'scm/diff'

require_relative 'scm/adapters/abstract_adapter'
require_relative 'scm/adapters/cvs_adapter'
require_relative 'scm/adapters/svn_adapter'
require_relative 'scm/adapters/svn_chain_adapter'
require_relative 'scm/adapters/git_adapter'
require_relative 'scm/adapters/hg_adapter'
require_relative 'scm/adapters/hglib_adapter'
require_relative 'scm/adapters/bzr_adapter'
require_relative 'scm/adapters/bzrlib_adapter'
require_relative 'scm/adapters/factory'

require_relative 'scm/parsers/parser'
require_relative 'scm/parsers/branch_number'
require_relative 'scm/parsers/cvs_parser'
require_relative 'scm/parsers/svn_parser'
require_relative 'scm/parsers/svn_xml_parser'
require_relative 'scm/parsers/git_parser'
require_relative 'scm/parsers/git_styled_parser'
require_relative 'scm/parsers/hg_parser'
require_relative 'scm/parsers/hg_styled_parser'
require_relative 'scm/parsers/bzr_xml_parser'
require_relative 'scm/parsers/bzr_parser'

require_relative 'scm/parsers/array_writer'
require_relative 'scm/parsers/xml_writer'
require_relative 'scm/parsers/human_writer'
