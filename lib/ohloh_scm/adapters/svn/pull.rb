module OhlohScm::Adapters
	class SvnAdapter < AbstractAdapter

		def pull(from)
			logger.warn { "Pulling #{from.url}" }
			yield(0,1) if block_given? # Progress bar callback

			unless self.exist?
				svnadmin_create
				svnsync_init(from)
			end
			SvnAdapter.svnsync_sync(from, self)

			yield(1,1) if block_given? # Progress bar callback
		end

		# Initialize a new Subversion repository on disk.
		#
		# This method can work either locally (file://) or on another machine
		# in the server cluster (svn+ssh://).
		def svnadmin_create
			return if exist?
			if hostname
				svnadmin_create_remote
			else
				svnadmin_create_local
			end
		end

		# The local template for the Subversion hook
		def pre_revprop_change_template
			File.join(File.dirname(__FILE__), 'pre-revprop-change')
		end

		# The destination location for the Subversion hook
		def pre_revprop_change_path
			File.join(path, 'hooks', 'pre-revprop-change')
		end

		def svnadmin_create_local
			FileUtils.mkdir_p path
			FileUtils.rmdir path
			run "svnadmin create #{path}"
			FileUtils.cp pre_revprop_change_template, pre_revprop_change_path
      FileUtils.chmod 0755, pre_revprop_change_path
		end

		def svnadmin_create_remote
			run "ssh #{hostname} 'mkdir -p #{path} && rmdir #{path} && svnadmin create #{path}'"
			run "scp #{pre_revprop_change_template} #{hostname}:#{pre_revprop_change_path}"
		end

		def svnsync_init(from)
			run "svnsync init --trust-server-cert --non-interactive #{from.opt_auth} '#{url}' #{from.root}"
		end

		def self.svnsync_sync(src, dest)
			# We might not be pulling from the same repository we pulled from last time.
			# We use svnsync to manage multiple backups on our server cluster, as well as to
			# pull from the well-known public repository.
			# Therefore we have to set the root and UUID of the svnsync every time.
			dest.propset('sync-from-url', src.root)
			dest.propset('sync-from-uuid', src.uuid)

			run "svnsync sync #{src.opt_auth} --trust-server-cert --non-interactive '#{SvnAdapter.uri_encode(dest.root)}'"
		end

		def propget(propname)
			run("svn propget --trust-server-cert --non-interactive #{opt_auth} --revprop -r 0 svn:#{propname} '#{SvnAdapter.uri_encode(root)}'").strip!
		end

		def propset(propname, value)
			run("svn propset --trust-server-cert --non-interactive #{opt_auth} --revprop -r 0 svn:#{propname} #{value} '#{SvnAdapter.uri_encode(root)}'")
		end

	end
end
