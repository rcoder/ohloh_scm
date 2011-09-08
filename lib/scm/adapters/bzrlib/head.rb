module Scm::Adapters
	class BzrlibAdapter < BzrAdapter
		def head_token
			run("bzr log --limit 1 --show-id #{url} 2> /dev/null | grep ^revision-id | cut -f2 -d' '").strip
      #bzr_log(nil).scan(/^revision-id:\s(.*)$/)[0][0].strip
		end

		def head
			verbose_commit(head_token)
		end

		def parent_tokens(commit)
			#run("cd '#{url}' && bzr log --long --show-id --limit 1 -c #{to_rev_param(commit.token)} | grep ^parent | cut -f2 -d' '").split("\n")
      s = bzr_log(to_rev_param(commit.token, false))
      bzr_log(to_rev_param(commit.token, false)).scan(/^parent:\s(.*)$/)[0]
		end

		def parents(commit)
			parent_tokens(commit).collect { |token| verbose_commit(token) }
		end

    def bzr_log(revision)
      pwd = Dir.pwd
      begin
        out = bzrlib_commands.bzr_log(self.url, revision)
      rescue => expt
        raise RuntimeError.new(expt.message)
      ensure
        Dir.chdir(pwd)
      end 
      out.to_s
    end
	end
end
