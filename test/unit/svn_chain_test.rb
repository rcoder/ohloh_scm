require File.dirname(__FILE__) + '/../test_helper'

module Scm::Parsers
	class SvnChainTest < Scm::Test

		def test_chain
			with_svn_repository('svn_with_branching', '/trunk') do |svn|
				chain = svn.chain
				assert_equal 4, chain.size

				# In revision 1, the trunk is created.
				assert_equal '/trunk', chain[0].branch_name
				assert_equal 1, chain[0].first_token
				assert_equal 2, chain[0].final_token

				# In revision 3, the trunk was deleted, but restored in revision 4.
				# This creates the first discontinuity, and the first link in the chain.
				assert_equal '/trunk', chain[1].branch_name
				assert_equal 4, chain[1].first_token
				assert_equal 4, chain[1].final_token

				# In revision 5, the branch is created by copying the trunk from revision 4.
				assert_equal '/branches/development', chain[2].branch_name
				assert_equal 5, chain[2].first_token
				assert_equal 7, chain[2].final_token

				# In revision 8, a new trunk is created by copying the branch.
				# This trunk still lives on, so its final_token is nil.
				assert_equal '/trunk', chain[3].branch_name
				assert_equal 8, chain[3].first_token
				assert_equal nil, chain[3].final_token
			end
		end

		def test_parent_svn
			with_svn_repository('svn_with_branching', '/trunk') do |svn|
				# In this repository, /branches/development becomes
				# the /trunk in revision 8. So there should be no record
				# before revision 8 in the 'traditional' base commit parser.
				assert_equal [8,9], svn.base_commit_tokens

				p1 = svn.parent_svn
				assert_equal p1.url, svn.root + '/branches/development'
				assert_equal p1.branch_name, '/branches/development'
				assert_equal p1.final_token, 7

				# There's another move at revision 5, in which /branch/development
				# is created by copying /trunk from revision 4.
				p2 = p1.parent_svn
				assert_equal p2.url, svn.root + '/trunk'
				assert_equal p2.branch_name, '/trunk'
				assert_equal p2.final_token, 4
			end
		end

		def test_chained_commit_tokens
			with_svn_repository('svn_with_branching', '/trunk') do |svn|
				assert_equal [1,2,4,5,8,9], svn.chained_commit_tokens
				assert_equal [2,4,5,8,9], svn.chained_commit_tokens(1)
				assert_equal [4,5,8,9], svn.chained_commit_tokens(2)
				assert_equal [4,5,8,9], svn.chained_commit_tokens(3)
				assert_equal [5,8,9], svn.chained_commit_tokens(4)
				assert_equal [8,9], svn.chained_commit_tokens(5)
				assert_equal [8,9], svn.chained_commit_tokens(6)
				assert_equal [8,9], svn.chained_commit_tokens(7)
				assert_equal [9], svn.chained_commit_tokens(8)
				assert_equal [], svn.chained_commit_tokens(9)
				assert_equal [], svn.chained_commit_tokens(10)
			end
		end

		def test_chained_commit_count
			with_svn_repository('svn_with_branching', '/trunk') do |svn|
				assert_equal 6, svn.chained_commit_count
				assert_equal 5, svn.chained_commit_count(1)
				assert_equal 4, svn.chained_commit_count(2)
				assert_equal 4, svn.chained_commit_count(3)
				assert_equal 3, svn.chained_commit_count(4)
				assert_equal 2, svn.chained_commit_count(5)
				assert_equal 2, svn.chained_commit_count(6)
				assert_equal 2, svn.chained_commit_count(7)
				assert_equal 1, svn.chained_commit_count(8)
				assert_equal 0, svn.chained_commit_count(9)
			end
		end

		def test_chained_commits
			with_svn_repository('svn_with_branching', '/trunk') do |svn|
				assert_equal [1,2,4,5,8,9], svn.chained_commits.collect { |c| c.token }
				assert_equal [2,4,5,8,9], svn.chained_commits(1).collect { |c| c.token }
				assert_equal [4,5,8,9], svn.chained_commits(2).collect { |c| c.token }
				assert_equal [4,5,8,9], svn.chained_commits(3).collect { |c| c.token }
				assert_equal [5,8,9], svn.chained_commits(4).collect { |c| c.token }
				assert_equal [8,9], svn.chained_commits(5).collect { |c| c.token }
				assert_equal [8,9], svn.chained_commits(6).collect { |c| c.token }
				assert_equal [8,9], svn.chained_commits(7).collect { |c| c.token }
				assert_equal [9], svn.chained_commits(8).collect { |c| c.token }
				assert_equal [], svn.chained_commits(9).collect { |c| c.token }
			end
		end

		# This test is primarly concerned with the checking the diffs
		# of commits. Specifically, when an entire branch is moved
		# to a new name, we should not see any diffs. From our
		# point of view the code is unchanged; only the base directory
		# has moved.
		def test_chained_each_commit
			commits = []
			with_svn_repository('svn_with_branching', '/trunk') do |svn|
				svn.chained_each_commit do |c|
					commits << c
					# puts "r#{c.token} #{c.message}"
					c.diffs.each do |d|
						# puts "\t#{d.action} #{d.path}"
					end
				end
			end

			assert_equal [1,2,4,5,8,9], commits.collect { |c| c.token }

			# This repository spends a lot of energy moving directories around.
			# File edits actually occur in just 3 commits.

			# Revision 1: /trunk directory created, but it is empty
			assert_equal 0, commits[0].diffs.size

			# Revision 2: /trunk/helloworld.c is added
			assert_equal 1, commits[1].diffs.size
			assert_equal 'A', commits[1].diffs.first.action
			assert_equal '/helloworld.c', commits[1].diffs.first.path

			# Revision 3: /trunk is deleted. We can't see this revision.

			# Revision 4: /trunk is re-created by copying it from revision 2.
			# From our point of view, there has been no change at all, and thus no diffs.
			assert_equal 0, commits[2].diffs.size

			# Revision 5: /branches/development is created by copying /trunk.
			# From our point of view, the contents of the repository are unchanged, so
			# no diffs result from the copy.
			# However, /branches/development/goodbyeworld.c is also created, so we should
			# have a diff for that.
			assert_equal 1, commits[3].diffs.size
			assert_equal 'A', commits[3].diffs.first.action
			assert_equal '/goodbyeworld.c', commits[3].diffs.first.path

			# Revision 6: /trunk/goodbyeworld.c is created, but we only see activity
			# on /branches/development, so no commit reported.

			# Revision 7: /trunk is deleted, but again we don't see it.

			# Revision 8: /branches/development is moved to become the new /trunk.
			# The directory contents are unchanged, so no diffs result.
			assert_equal 0, commits[4].diffs.size

			# Revision 9: an edit to /trunk/helloworld.c
			assert_equal 1, commits[5].diffs.size
			assert_equal 'M', commits[5].diffs.first.action
			assert_equal '/helloworld.c', commits[5].diffs.first.path
		end

		# Specifically tests this case:
		# Suppose we're importing /myproject/trunk, and the log
		# contains the following:
		#
		#   A /myproject (from /all/myproject:1)
		#   D /all/myproject
		#
		# We need to make sure we detect the move here, even though
		# "/myproject" is not an exact match for "/myproject/trunk".
		def test_tree_move
			with_svn_repository('svn_with_tree_move', '/myproject/trunk') do |svn|
				assert_equal svn.url, svn.root + '/myproject/trunk'
				assert_equal svn.branch_name, '/myproject/trunk'

				p = svn.parent_svn
				assert_equal p.url, svn.root + '/all/myproject/trunk'
				assert_equal p.branch_name, '/all/myproject/trunk'
				assert_equal p.final_token, 1

				assert_equal [1, 2], svn.commit_tokens
			end
		end

		def test_new_branch_name
			svn = Scm::Adapters::SvnAdapter.new(:branch_name => "/trunk")

			assert_equal "/branches/b", svn.new_branch_name(Scm::Diff.new(:action => 'A',
					:path => "/trunk", :from_revision => 1, :from_path => "/branches/b"))
		end

	end
end
