module OhlohScm::Adapters
	class SvnChainAdapter < SvnAdapter
		def cat(path, revision)
			parent_svn(revision) ? parent_svn.cat(path, revision) : super(path, revision)
		end
	end
end

