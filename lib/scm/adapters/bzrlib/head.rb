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
      tokens = []
      bzr_commander.get_parent_tokens(to_rev_param(commit.token, false)).to_enum.each {|t| tokens << t}
      return tokens
		end

		def parents(commit)
			parent_tokens(commit).collect { |token| verbose_commit(token) }
		end
	end
end
