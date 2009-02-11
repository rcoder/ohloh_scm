require File.dirname(__FILE__) + '/../test_helper'

module Scm::Adapters
	class SvnCommitsTest < Scm::Test

		def test_commits
			with_svn_repository('svn') do |svn|
				assert_equal 5, svn.commit_count
				assert_equal 3, svn.commit_count(2)
				assert_equal 0, svn.commit_count(1000)

				assert_equal [1,2,3,4,5], svn.commit_tokens
				assert_equal [3,4,5], svn.commit_tokens(2)
				assert_equal [], svn.commit_tokens(1000)

				assert_equal [1,2,3,4,5], svn.commits.collect { |c| c.token }
				assert_equal [3,4,5], svn.commits(2).collect { |c| c.token }
				assert_equal [], svn.commits(1000)
				assert !FileTest.exist?(svn.log_filename)
			end
		end

		# Confirms that the sha1 matches those created by git exactly
		def test_sha1
			with_svn_repository('svn') do |svn|
				assert_equal '0000000000000000000000000000000000000000', svn.compute_sha1(nil)
				assert_equal '0000000000000000000000000000000000000000', svn.compute_sha1('')
				assert_equal '30d74d258442c7c65512eafab474568dd706c430', svn.compute_sha1('test')
			end
		end

		# Given a commit with diffs, fill in all of the SHA1 values.
		def test_populate_sha1
			with_svn_repository('svn') do |svn|
				c = Scm::Commit.new(:token => 3)
				c.diffs = [Scm::Diff.new(:path => "/trunk/helloworld.c", :action => "M")]
				svn.populate_commit_sha1s!(c)
				assert_equal 'f6adcae4447809b651c787c078d255b2b4e963c5', c.diffs.first.sha1
				assert_equal '4c734ad53b272c9b3d719f214372ac497ff6c068', c.diffs.first.parent_sha1
			end
		end

		def test_strip_commit_branch
			svn = SvnAdapter.new(:branch_name => "/trunk")
			commit = Scm::Commit.new

			# nil diffs before => nil diffs after
			assert !svn.strip_commit_branch(commit).diffs

			# [] diffs before => [] diffs after
			commit.diffs = []
			assert_equal [], svn.strip_commit_branch(commit).diffs

			commit.diffs = [
				Scm::Diff.new(:path => "/trunk"),
				Scm::Diff.new(:path => "/trunk/helloworld.c"),
				Scm::Diff.new(:path => "/branches/a")
			]
			assert_equal ['', '/helloworld.c'], svn.strip_commit_branch(commit).diffs.collect { |d| d.path }.sort
		end

		def test_strip_diff_branch
			svn = SvnAdapter.new(:branch_name => "/trunk")
			assert !svn.strip_diff_branch(Scm::Diff.new)
			assert !svn.strip_diff_branch(Scm::Diff.new(:path => "/branches/b"))
			assert_equal '', svn.strip_diff_branch(Scm::Diff.new(:path => "/trunk")).path
			assert_equal '/helloworld.c', svn.strip_diff_branch(Scm::Diff.new(:path => "/trunk/helloworld.c")).path
		end

		def test_strip_path_branch
			# Returns nil for any path outside of SvnAdapter::branch_name
			assert !SvnAdapter.new.strip_path_branch(nil)
			assert !SvnAdapter.new(:branch_name => "/trunk").strip_path_branch("/branches/foo")
			assert !SvnAdapter.new(:branch_name => "/trunk").strip_path_branch("/t")

			# If branch_name is empty or root, returns path unchanged
			assert_equal '', SvnAdapter.new.strip_path_branch('')
			assert_equal '/trunk', SvnAdapter.new.strip_path_branch('/trunk')

			# If path is equal to or is a subdirectory of branch_name, returns subdirectory portion only.
			assert_equal '', SvnAdapter.new(:branch_name => "/trunk").strip_path_branch('/trunk')
			assert_equal '/foo', SvnAdapter.new(:branch_name => "/trunk").strip_path_branch('/trunk/foo')
		end

		def test_strip_path_branch_with_special_chars
			assert_equal '/foo', SvnAdapter.new(:branch_name => '/trunk/hamcrest-c++').strip_path_branch('/trunk/hamcrest-c++/foo')
		end

		def test_remove_dupes_add_modify
			svn = SvnAdapter.new
			c = Scm::Commit.new(:diffs => [ Scm::Diff.new(:action => "A", :path => "foo"),
																			Scm::Diff.new(:action => "M", :path => "foo") ])

			svn.remove_dupes(c)
			assert_equal 1, c.diffs.size
			assert_equal 'A', c.diffs.first.action
		end

		def test_remove_dupes_add_replace
			svn = SvnAdapter.new
			c = Scm::Commit.new(:diffs => [ Scm::Diff.new(:action => "R", :path => "foo"),
																			Scm::Diff.new(:action => "A", :path => "foo") ])

			svn.remove_dupes(c)
			assert_equal 1, c.diffs.size
			assert_equal 'A', c.diffs.first.action
		end

		# Had so many bugs around this case that a test was required
		def test_deepen_commit_with_nil_diffs
			with_svn_repository('svn') do |svn|
				c = svn.commits.first # Doesn't matter which
				c.diffs = nil
				svn.populate_commit_sha1s!(svn.deepen_commit(c)) # If we don't crash we pass the test.
			end
		end

		def test_deep_commits
			with_svn_repository('deep_svn') do |svn|

				# The full repository contains 4 revisions...
				assert_equal 4, svn.commit_count

				# ..however, looking only at the history of /trunk@4 shows 3 revisions.
				# 
				# That's because /trunk@3 was created by copying /branches/b@1
				#
				# I hope the following diagram helps to explain:
				#
				# r1              | r2             |        r3           |   r4
				# ----------------|----------------|---------------------|---------------
				#                 |                |                     |
				# /trunk(x) ------|-> deleted(x)   |    /--> /trunk(*) --|--> /trunk(*)
				#                 |                |   /                 |
				# /branches/b(*)--|----------------|--/                  |
				#                 |                |                     |
				#
				# (*) activity we track
				# (x) activity we ignore

				trunk = SvnAdapter.new(:url => File.join(svn.url,'trunk'), :branch_name => '/trunk').normalize
				assert_equal 3, trunk.commit_count
				assert_equal [1,3,4], trunk.commit_tokens

				commits = []
				trunk.each_commit { |c| commits << c }

				# The first commit we should see is /branches/b@1.
				# It should contain two files.

				assert_equal 1, commits.first.token
				assert_equal 2, commits.first.diffs.size # Two files seen

				assert_equal 'A', commits.first.diffs[0].action
				assert_equal '/subdir/bar.rb', commits.first.diffs[0].path
				assert_equal 'A', commits.first.diffs[1].action
				assert_equal '/subdir/foo.rb', commits.first.diffs[1].path

				# When the branch is moved to replace the trunk in revision 3,
				# the Subversion log shows
				#
				#   D /branches/b
				#   A /trunk (from /branches/b:2)
				#
				# The branch_name changes at this point, but none of the file contents
				# actually change. So there are no diffs to report at this point.
				assert_equal 3, commits[1].token
				assert_equal 0, commits[1].diffs.size

				# In Revision 4, a subdirectory is renamed. This shows in the Subversion log as
				#
				#   A /trunk/newdir (from /trunk/subdir:3)
				#   D /trunk/subdir
				#
				# There are files in this directory, so make sure our commit includes
				# both delete and add events for all of the files in this directory, but does
				# not actually refer to the directories themselves.

				assert_equal 4, commits.last.token

				# There should be 2 files removed and two files added
				assert_equal 4, commits.last.diffs.size

				assert_equal 'A', commits.last.diffs[0].action
				assert_equal '/newdir/bar.rb', commits.last.diffs[0].path
				assert_equal 'A', commits.last.diffs[1].action
				assert_equal '/newdir/foo.rb', commits.last.diffs[1].path

				assert_equal 'D', commits.last.diffs[2].action
				assert_equal '/subdir/bar.rb', commits.last.diffs[2].path
				assert_equal 'D', commits.last.diffs[3].action
				assert_equal '/subdir/foo.rb', commits.last.diffs[3].path
			end
		end

		# A mini-integration test.
		# Check that SHA1 values are populated, directories are recursed, and outside branches are ignored.
		def test_each_commit
			commits = []
			with_svn_repository('svn') do |svn|
				svn.each_commit do |e|
					commits << e
					assert e.token.to_s =~ /\d+/
					assert e.committer_name.length > 0
					assert e.committer_date.is_a?(Time)
					assert e.message
					assert e.diffs.any?
					e.diffs.each do |d|
						assert d.action.length == 1
						assert d.path.length > 0
					end
				end
				assert !FileTest.exist?(svn.log_filename) # Make sure we cleaned up after ourselves
			end

			assert_equal [1, 2, 3, 4, 5], commits.collect { |c| c.token }
			assert_equal ['robin','robin','robin','jason','jason'], commits.collect { |c| c.committer_name }

			assert commits[0].committer_date - Time.utc(2006,6,11,18,28,0) < 1 # commits include milliseconds
			assert commits[1].committer_date - Time.utc(2006,6,11,18,32,13) < 1
			assert commits[2].committer_date - Time.utc(2006,6,11,18,34,17) < 1
			assert commits[3].committer_date - Time.utc(2006,7,14,22,17,8) < 1
			assert commits[4].committer_date - Time.utc(2006,7,14,23,7,15) < 1

			assert_equal "Initial Checkin\n", commits[0].message
			assert_equal "added makefile", commits[1].message
			assert_equal "added some documentation and licensing info", commits[2].message
			assert_equal "added bs COPYING to catch global licenses", commits[3].message
			assert_equal "moving COPYING", commits[4].message

			assert_equal 1, commits[0].diffs.size
			assert_equal 'A', commits[0].diffs[0].action
			assert_equal '/trunk/helloworld.c', commits[0].diffs[0].path

			assert_equal 1, commits[1].diffs.size
			assert_equal 'A', commits[1].diffs[0].action
			assert_equal '/trunk/makefile', commits[1].diffs[0].path

			assert_equal 2, commits[2].diffs.size
			assert_equal 'A', commits[2].diffs[0].action
			assert_equal '/trunk/README', commits[2].diffs[0].path
			assert_equal 'M', commits[2].diffs[1].action
			assert_equal '/trunk/helloworld.c', commits[2].diffs[1].path

			assert_equal 1, commits[3].diffs.size
			assert_equal 'A', commits[3].diffs[0].action
			assert_equal '/COPYING', commits[3].diffs[0].path

			assert_equal 2, commits[4].diffs.size
			assert_equal 'D', commits[4].diffs[0].action
			assert_equal '/COPYING', commits[4].diffs[0].path
			assert_equal 'A', commits[4].diffs[1].action
			assert_equal '/trunk/COPYING', commits[4].diffs[1].path
		end

		def test_verbose_commit_with_chaining
			with_svn_repository('svn_with_branching','/trunk') do |svn|

				assert svn.verbose_commit(9)
				assert_equal 'modified helloworld.c', svn.verbose_commit(9).message
				assert_equal ['/helloworld.c'], svn.verbose_commit(9).diffs.collect { |d| d.path }

				assert svn.verbose_commit(8)
				assert_equal [], svn.verbose_commit(8).diffs

				# Reaching these commits requires chaining
				assert svn.verbose_commit(5)
				assert_equal 'add a new branch, with goodbyeworld.c', svn.verbose_commit(5).message
				assert_equal ['/goodbyeworld.c'], svn.verbose_commit(5).diffs.collect { |d| d.path }

				assert svn.verbose_commit(4)
				assert_equal [], svn.verbose_commit(4).diffs

				# Reaching these commits requires chaining twice
				assert svn.verbose_commit(2)
				assert_equal 'Added helloworld.c to trunk', svn.verbose_commit(2).message
				assert_equal ['/helloworld.c'], svn.verbose_commit(2).diffs.collect { |d| d.path }

				assert svn.verbose_commit(1)
				assert_equal [], svn.verbose_commit(1).diffs
			end
		end

	end
end
