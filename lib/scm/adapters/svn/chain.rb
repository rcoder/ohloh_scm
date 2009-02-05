module Scm::Adapters
	class SvnAdapter < AbstractAdapter

		def first_token(since=0)
			first_commit(since).token
		end

		def first_commit(since=0)
			Scm::Parsers::SvnXmlParser.parse(next_revision_xml(since)).first
		end
	
		# Returns the first commit with a revision number greater than the provided revision number
		def next_revision_xml(since)
			run "svn log --verbose --xml --stop-on-copy -r #{since+1}:#{final_token || 'HEAD'} --limit 1 #{opt_auth} '#{SvnAdapter.uri_encode(File.join(self.root, self.branch_name))}@#{final_token || 'HEAD'}'"
		end

		def parent_svn(since=0)
			parent = nil
			c = first_commit(since)
			if c
				c.diffs.each do |d|
					if d.action == 'A' && d.path == branch_name && d.from_path && d.from_revision
						parent = SvnAdapter.new(:url => File.join(root, d.from_path),
													 :username => username, :password => password, 
													 :branch_name => d.from_path, :final_token => d.from_revision).normalize
						break
					end
				end
			end
			parent
		end

		# Returns the parent_svn ancestry as a list, oldest first
		def chain
			(parent_svn ? parent_svn.chain : []) << self
		end

		#------------------------------------------------------------------
		# Recursive or "chained" versions of the commit accessors.
		#
		# These methods recurse through the chain of ancestors for this
		# adapter, calling the base_* method in turn for each ancestor.
		#------------------------------------------------------------------

		# Returns the count of commits following revision number 'since'.
		def chained_commit_count(since=0)
			(parent_svn ? parent_svn.chained_commit_count(since) : 0) + base_commit_count(since)
		end

		# Returns an array of revision numbers for all commits following revision number 'since'.
		def chained_commit_tokens(since=0)
			(parent_svn ? parent_svn.chained_commit_tokens(since) : []) + base_commit_tokens(since)
		end

		def chained_commits(since=0)
			(parent_svn ? parent_svn.chained_commits(since) : []) + base_commits(since)
		end

		def chained_each_commit(since=0, &block)
			parent_svn.chained_each_commit(since, &block) if parent_svn
			base_each_commit(since) do |commit|
				block.call commit
			end
		end

	end
end
