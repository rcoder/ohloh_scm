require_relative '../test_helper'

module OhlohScm::Adapters
	# Repository hg_walk has the following structure:
	#
	#      G -> H -> I
	#     /      \    \
	#    A -> B -> C -> D -> tip
	#
	class HgRevListTest < Scm::Test

		def test_rev_list
			with_hg_repository('hg_walk') do |hg|
				# Full history to a commit
				assert_equal [:A],                         rev_list_helper(hg, nil, :A)
				assert_equal [:A, :B],                     rev_list_helper(hg, nil, :B)
				assert_equal [:A, :B, :G, :H, :C],         rev_list_helper(hg, nil, :C)
				assert_equal [:A, :B, :G, :H, :C, :I, :D], rev_list_helper(hg, nil, :D)
				assert_equal [:A, :G],                     rev_list_helper(hg, nil, :G)
				assert_equal [:A, :G, :H],                 rev_list_helper(hg, nil, :H)
				assert_equal [:A, :G, :H, :I],             rev_list_helper(hg, nil, :I)

				# Limited history from one commit to another
				assert_equal [],                           rev_list_helper(hg, :A, :A)
				assert_equal [:B],                         rev_list_helper(hg, :A, :B)
				assert_equal [:B, :G, :H, :C],             rev_list_helper(hg, :A, :C)
				assert_equal [:B, :G, :H, :C, :I, :D],     rev_list_helper(hg, :A, :D)
				assert_equal [:G, :H, :C, :I, :D],         rev_list_helper(hg, :B, :D)
				assert_equal [:I, :D],                     rev_list_helper(hg, :C, :D)
			end
		end

		protected

		def rev_list_helper(hg, from, to)
			to_labels(hg.commit_tokens(:after => from_label(from), :up_to => from_label(to)))
		end

		def commit_labels
			{ '4bfbf836feeebb236492199fbb0d1474e26f69d9' => :A,
				'23edb79d0d06c8c315d8b9e7456098823335377d' => :B,
				'7e33b9fde56a6e3576753868d08fa143e4e8a9cf' => :C,
				'8daa1aefa228d3ee5f9a0f685d696826e88266fb' => :D,
				'e43cf1bb4b80d8ae70a695ec070ce017fdc529f3' => :G,
				'dca215d8a3e4dd3e472379932f1dd9c909230331' => :H,
				'3a1495175e40b1c983441d6a8e8e627d2bd672b6' => :I
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
