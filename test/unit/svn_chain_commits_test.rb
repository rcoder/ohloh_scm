require_relative '../test_helper'

module OhlohScm::Parsers
	class SvnChainTest < OhlohScm::Test

		def test_chained_commit_tokens
			with_svn_chain_repository('svn_with_branching', '/trunk') do |svn|
				assert_equal [1,2,4,5,8,9,11], svn.commit_tokens
				assert_equal [2,4,5,8,9,11], svn.commit_tokens(:after => 1)
				assert_equal [4,5,8,9,11], svn.commit_tokens(:after => 2)
				assert_equal [4,5,8,9,11], svn.commit_tokens(:after => 3)
				assert_equal [5,8,9,11], svn.commit_tokens(:after => 4)
				assert_equal [8,9,11], svn.commit_tokens(:after => 5)
				assert_equal [8,9,11], svn.commit_tokens(:after => 6)
				assert_equal [8,9,11], svn.commit_tokens(:after => 7)
				assert_equal [9,11], svn.commit_tokens(:after => 8)
				assert_equal [11], svn.commit_tokens(:after => 9)
				assert_equal [], svn.commit_tokens(:after => 11)
			end
		end

		def test_chained_commit_count
			with_svn_chain_repository('svn_with_branching', '/trunk') do |svn|
				assert_equal 7, svn.commit_count
				assert_equal 6, svn.commit_count(:after => 1)
				assert_equal 5, svn.commit_count(:after => 2)
				assert_equal 5, svn.commit_count(:after => 3)
				assert_equal 4, svn.commit_count(:after => 4)
				assert_equal 3, svn.commit_count(:after => 5)
				assert_equal 3, svn.commit_count(:after => 6)
				assert_equal 3, svn.commit_count(:after => 7)
				assert_equal 2, svn.commit_count(:after => 8)
				assert_equal 1, svn.commit_count(:after => 9)
				assert_equal 0, svn.commit_count(:after => 11)
			end
		end

		def test_chained_commits
			with_svn_chain_repository('svn_with_branching', '/trunk') do |svn|
				assert_equal [1,2,4,5,8,9,11], svn.commits.collect { |c| c.token }
				assert_equal [2,4,5,8,9,11], svn.commits(:after => 1).collect { |c| c.token }
				assert_equal [4,5,8,9,11], svn.commits(:after => 2).collect { |c| c.token }
				assert_equal [4,5,8,9,11], svn.commits(:after => 3).collect { |c| c.token }
				assert_equal [5,8,9,11], svn.commits(:after => 4).collect { |c| c.token }
				assert_equal [8,9,11], svn.commits(:after => 5).collect { |c| c.token }
				assert_equal [8,9,11], svn.commits(:after => 6).collect { |c| c.token }
				assert_equal [8,9,11], svn.commits(:after => 7).collect { |c| c.token }
				assert_equal [9,11], svn.commits(:after => 8).collect { |c| c.token }
				assert_equal [11], svn.commits(:after => 9).collect { |c| c.token }
				assert_equal [], svn.commits(:after => 11).collect { |c| c.token }
			end
		end

		# This test is primarly concerned with the checking the diffs
		# of commits. Specifically, when an entire branch is moved
		# to a new name, we should not see any diffs. From our
		# point of view the code is unchanged; only the base directory
		# has moved.
		def test_chained_each_commit
			commits = []
			with_svn_chain_repository('svn_with_branching', '/trunk') do |svn|
				svn.each_commit do |c|
					assert c.scm # To support checkout of chained commits, the
					             # commit must include a link to its containing adapter.
					commits << c
				end
			end

			assert_equal [1,2,4,5,8,9,11], commits.collect { |c| c.token }

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

      # Revision 10: /trunk/goodbyeworld.c & /trunk/helloworld.c are modified
      # on branches/development, hence no commit reported.

      # Revision 11: The trunk is reverted back to revision 9.
			assert_equal 0, commits[6].diffs.size
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
			with_svn_chain_repository('svn_with_tree_move', '/myproject/trunk') do |svn|
				assert_equal svn.url, svn.root + '/myproject/trunk'
				assert_equal svn.branch_name, '/myproject/trunk'

				p = svn.parent_svn
				assert_equal p.url, svn.root + '/all/myproject/trunk'
				assert_equal p.branch_name, '/all/myproject/trunk'
				assert_equal p.final_token, 1

				assert_equal [1, 2], svn.commit_tokens
			end
		end

		def test_verbose_commit_with_chaining
			with_svn_chain_repository('svn_with_branching','/trunk') do |svn|

				c = svn.verbose_commit(9)
				assert_equal 'modified helloworld.c', c.message
				assert_equal ['/helloworld.c'], c.diffs.collect { |d| d.path }
				assert_equal '/trunk', c.scm.branch_name

				c = svn.verbose_commit(8)
				assert_equal [], c.diffs
				assert_equal '/trunk', c.scm.branch_name

				# Reaching these commits requires chaining
				c = svn.verbose_commit(5)
				assert_equal 'add a new branch, with goodbyeworld.c', c.message
				assert_equal ['/goodbyeworld.c'], c.diffs.collect { |d| d.path }
				assert_equal '/branches/development', c.scm.branch_name

				# Reaching these commits requires chaining twice
				c = svn.verbose_commit(4)
				assert_equal [], c.diffs
				assert_equal '/trunk', c.scm.branch_name

				# And now a fourth chain (to skip over /trunk deletion in rev 3)
				c = svn.verbose_commit(2)
				assert_equal 'Added helloworld.c to trunk', c.message
				assert_equal ['/helloworld.c'], c.diffs.collect { |d| d.path }
				assert_equal '/trunk', c.scm.branch_name

				c = svn.verbose_commit(1)
				assert_equal [], c.diffs
				assert_equal '/trunk', c.scm.branch_name
			end
		end
	end
end
