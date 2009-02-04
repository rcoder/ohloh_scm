require File.dirname(__FILE__) + '/../test_helper'

module Scm::Adapters
	# Repository graph.git has the following structure:
	#
	#      G -> H -> I -> J -> development
	#     /      \    \
	#    A -> B -> C -> D -> master
	#
	class GitWalkTest < Scm::Test

		def test_walk
			with_git_repository('git_walk') do |git|
				# Full history to a commit
				assert_equal [:A],                         walk_helper(git, nil, :A)
				assert_equal [:A, :B],                     walk_helper(git, nil, :B)
				assert_equal [:A, :B, :G, :H, :C],         walk_helper(git, nil, :C)
				assert_equal [:A, :B, :G, :H, :C, :I, :D], walk_helper(git, nil, :D)
				assert_equal [:A, :G],                     walk_helper(git, nil, :G)
				assert_equal [:A, :G, :H],                 walk_helper(git, nil, :H)
				assert_equal [:A, :G, :H, :I],             walk_helper(git, nil, :I)
				assert_equal [:A, :G, :H, :I, :J],         walk_helper(git, nil, :J)

				# Limited history from one commit to another
				assert_equal [],                           walk_helper(git, :A, :A)
				assert_equal [:B],                         walk_helper(git, :A, :B)
				assert_equal [:B, :G, :H, :C],             walk_helper(git, :A, :C)
				assert_equal [:B, :G, :H, :C, :I, :D],     walk_helper(git, :A, :D)
				assert_equal [:G, :H, :C, :I, :D],         walk_helper(git, :B, :D)
				assert_equal [:I, :D],                     walk_helper(git, :C, :D)
				assert_equal [:H, :I, :J],                 walk_helper(git, :G, :J)
			end
		end

		protected

		def walk_helper(walker, from, to)
			to_labels(walker.walk(from_label(from), from_label(to)))
		end

		def commit_labels
			{ '886b62459ef1ffd01a908979d4d56776e0c5ecb2' => :A,
				'db77c232f01f7a649dd3a2216199a29cf98389b7' => :B,
				'f264fb40c340a415b305ac1f0b8f12502aa2788f' => :C,
				'57fedf267adc31b1403f700cc568fe4ca7975a6b' => :D,
				'97b80cb9743948cf302b6e21571ff40721a04c8d' => :G,
				'b8291f0e89567de3f691afc9b87a5f1908a6f3ea' => :H,
				'd067161caae2eeedbd74976aeff5c4d8f1ccc946' => :I,
				'b49aeaec003cf8afb18152cd9e292816776eecd6' => :J
			}
		end

		def to_label(sha1)
			commit_labels[sha1.to_s]
		end

		def to_labels(sha1s)
			sha1s.collect { |sha1| to_label(sha1) }
		end

		def from_label(l)
			commit_labels.each_pair { |k,v| return k if v.to_s == l.to_s }
			nil
		end
	end
end
