module OhlohScm::Adapters
	# Some explanation is in order about "chaining."
	#
	# First, realize that a base SvnAdapter only tracks the history of a single
	# subdirectory. If you point an adapter at /trunk, then that adapter is
	# going to ignore eveything in /branches and /tags.
	#
	# The problem with this is that directories often get moved about.  What is
	# called "/trunk" today might have been in a branch directory at some point
	# in the past. But after we completely ignore other directories, we never see
	# that old history.
	#
	# Suppose for example that from revisions 1 to 100, development occured in
	# /branches/beta. Then at revision 101, /trunk was created by copying
	# /branches/beta, and this /trunk lives on to this day.
	#
	# The log for revision 101 is going to look something like this:
	#
	# Changed paths:
	#    D /branches/beta
	#    A /trunk (from /branches/beta:100)
	#
	# A single SvnAdapter pointed at today's /trunk will only see revisions 101
	# through HEAD, because /trunk didn't even exist before revision 101.
	#
	# To capture the prior history, we need to create *another* SvnAdapter
	# which points at /branches/beta, and which considers revisions from 1 to 100.
	#
	# That's what chaining is: when we find that the first commit of an adapter
	# indicates the wholesale renaming or copying of the entire tree from
	# another location, then we generate a new SvnAdapter that points to that
	# prior location, and process that SvnAdapter as well.
	#
	# This behavior recurses ("chains") all the way back to revision 1.
	#
	# It only works if the *entire branch* moves. We don't chain when
	# subdirectories or individual files are copied.
	class SvnChainAdapter < SvnAdapter
	end
end

require_relative 'svn_chain/chain'
require_relative 'svn_chain/commits'
require_relative 'svn_chain/cat_file'
