# NOTE: Setup before running benchmark. Replace hg with bzr in the following commands for bzr benchmarks.
# cd spec/scm_fixtures
# tar xf hg_large.tgz && cd hg_large
# bash create-large-file.sh 14 # Create a file as per given factor # 14=19MB # 15=38MB # 16=76MB # 17=151MB
# hg add && hg commit -m 'temp'
# cd ../../../
# ruby -I lib spec/benchmarks/hg_bzr_bash_vs_py_api.rb hg
# hg rollback  # bzr uncommit # revert last commit to try different file sizes.

require_relative '../../lib/ohloh_scm'
require 'benchmark'

OhlohScm::System.logger.level = :error

scm = ARGV[0] || :hg
repo_path = File.expand_path("../scm_fixtures/#{scm}_large", __dir__)

puts 'Benchmarks for `cat_file`'

activity = OhlohScm::Factory.get_core(scm_type: scm, url: repo_path).activity
commit = OhlohScm::Commit.new(token: '1')
diff = OhlohScm::Diff.new(path: 'large.php')

puts `du -sh #{repo_path}/large.php`

Benchmark.bmbm 20 do |reporter|
  reporter.report("#{scm}[bash api]  ") do
    if scm.to_s == 'hg'
      `cd #{activity.url} && hg cat -r #{commit.token} #{diff.path}`
    else
      token = commit.token.to_i + 1
      `cd #{activity.url} && bzr cat --name-from-revision -r #{token} '#{diff.path}'`
    end
  end

  reporter.report("#{scm}[python api]") do
    activity.cat_file(commit, diff)
  end
end
