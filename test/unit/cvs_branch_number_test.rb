require_relative '../test_helper'

module OhlohScm::Parsers
	class CvsBranchNumberTest < Scm::Test
		def test_basic
			assert_equal [1,1], BranchNumber.new('1.1').to_a
			assert_equal [1234,1234], BranchNumber.new('1234.1234').to_a
			assert_equal [1,2,3,4], BranchNumber.new('1.2.3.4').to_a
		end

		def test_simple_inherits_from
			b = BranchNumber.new('1.3')

			assert b.inherits_from?(BranchNumber.new('1.2'))
			assert b.inherits_from?(BranchNumber.new('1.1'))
			assert b.inherits_from?(BranchNumber.new('1.3'))

			assert !b.inherits_from?(BranchNumber.new('1.4'))
			assert !b.inherits_from?(BranchNumber.new('1.1.2.1'))
			assert !b.inherits_from?(BranchNumber.new('1.2.2.1'))
			assert !b.inherits_from?(BranchNumber.new('1.3.2.1'))
		end

		def test_complex_inherits_from
			b = BranchNumber.new('1.3.6.3.2.3')

			assert b.inherits_from?(BranchNumber.new('1.2'))
			assert b.inherits_from?(BranchNumber.new('1.1'))
			assert b.inherits_from?(BranchNumber.new('1.3'))
			assert b.inherits_from?(BranchNumber.new('1.3.6.1'))
			assert b.inherits_from?(BranchNumber.new('1.3.6.2'))
			assert b.inherits_from?(BranchNumber.new('1.3.6.3'))
			assert b.inherits_from?(BranchNumber.new('1.3.6.3.2.1'))
			assert b.inherits_from?(BranchNumber.new('1.3.6.3.2.2'))
			assert b.inherits_from?(BranchNumber.new('1.3.6.3.2.3'))

			assert !b.inherits_from?(BranchNumber.new('1.4'))
			assert !b.inherits_from?(BranchNumber.new('1.1.2.1'))
			assert !b.inherits_from?(BranchNumber.new('1.2.2.1'))
			assert !b.inherits_from?(BranchNumber.new('1.3.2.1'))
			assert !b.inherits_from?(BranchNumber.new('1.3.4.1'))
			assert !b.inherits_from?(BranchNumber.new('1.3.6.1.2.1'))
			assert !b.inherits_from?(BranchNumber.new('1.3.6.4'))
			assert !b.inherits_from?(BranchNumber.new('1.3.6.3.4.1'))
			assert !b.inherits_from?(BranchNumber.new('1.3.6.3.2.2.2.1'))
			assert !b.inherits_from?(BranchNumber.new('1.3.6.3.2.4'))
		end

		def test_primary_revision_number_change
			b = BranchNumber.new('2.3')

			assert b.inherits_from?(BranchNumber.new('2.2'))
			assert b.inherits_from?(BranchNumber.new('2.1'))
			assert b.inherits_from?(BranchNumber.new('1.1'))
			assert b.inherits_from?(BranchNumber.new('1.9999'))

			assert !b.inherits_from?(BranchNumber.new('2.4'))
			assert !b.inherits_from?(BranchNumber.new('3.1'))
		end

		def test_complex_primary_revision_number_change
			b = BranchNumber.new('2.3.2.1')

			assert b.inherits_from?(BranchNumber.new('2.3'))
			assert b.inherits_from?(BranchNumber.new('2.2'))
			assert b.inherits_from?(BranchNumber.new('1.1'))
			assert b.inherits_from?(BranchNumber.new('1.9999'))

			assert !b.inherits_from?(BranchNumber.new('3.1'))
		end

		# Crazy CVS inserts a zero before the last piece of a branch number
		def test_magic_branch_numbers
			assert BranchNumber.new('1.1.2.1').inherits_from?(BranchNumber.new('1.1.0.2'))
			assert BranchNumber.new('1.1.2.1.2.1').inherits_from?(BranchNumber.new('1.1.0.2'))

			assert BranchNumber.new('1.1.0.2').inherits_from?(BranchNumber.new('1.1'))
			assert !BranchNumber.new('1.1.0.2').inherits_from?(BranchNumber.new('1.2'))
			assert !BranchNumber.new('1.1.0.2').inherits_from?(BranchNumber.new('1.1.2.1'))

			assert BranchNumber.new('1.1.0.4').inherits_from?(BranchNumber.new('1.1'))
			assert !BranchNumber.new('1.1.0.4').inherits_from?(BranchNumber.new('1.1.2.1'))
			assert !BranchNumber.new('1.1.0.4').inherits_from?(BranchNumber.new('1.1.0.2'))
			assert !BranchNumber.new('1.1.0.4').inherits_from?(BranchNumber.new('1.1.4.1'))
			assert !BranchNumber.new('1.1.0.4').inherits_from?(BranchNumber.new('1.1.0.6'))
		end

		def test_simple_on_same_line
			b = BranchNumber.new('1.3')

			assert b.on_same_line?(BranchNumber.new('1.2'))
			assert b.on_same_line?(BranchNumber.new('1.1'))
			assert b.on_same_line?(BranchNumber.new('1.3'))
			assert b.on_same_line?(BranchNumber.new('1.4'))

			assert !b.on_same_line?(BranchNumber.new('1.1.2.1'))
			assert !b.on_same_line?(BranchNumber.new('1.2.2.1'))
			assert !b.on_same_line?(BranchNumber.new('1.3.2.1'))
		end

		def test_complex_on_same_line
			b = BranchNumber.new('1.3.6.3.2.3')

			assert b.on_same_line?(BranchNumber.new('1.1'))
			assert b.on_same_line?(BranchNumber.new('1.2'))
			assert b.on_same_line?(BranchNumber.new('1.3'))
			assert b.on_same_line?(BranchNumber.new('1.3.6.1'))
			assert b.on_same_line?(BranchNumber.new('1.3.6.2'))
			assert b.on_same_line?(BranchNumber.new('1.3.6.3'))
			assert b.on_same_line?(BranchNumber.new('1.3.6.3.2.1'))
			assert b.on_same_line?(BranchNumber.new('1.3.6.3.2.2'))
			assert b.on_same_line?(BranchNumber.new('1.3.6.3.2.3'))
			assert b.on_same_line?(BranchNumber.new('1.3.6.3.2.4'))
			assert b.on_same_line?(BranchNumber.new('1.3.6.3.2.99'))

			assert !b.on_same_line?(BranchNumber.new('1.4'))
			assert !b.on_same_line?(BranchNumber.new('1.1.2.1'))
			assert !b.on_same_line?(BranchNumber.new('1.2.2.1'))
			assert !b.on_same_line?(BranchNumber.new('1.3.2.1'))
			assert !b.on_same_line?(BranchNumber.new('1.3.4.1'))
			assert !b.on_same_line?(BranchNumber.new('1.3.6.1.2.1'))
			assert !b.on_same_line?(BranchNumber.new('1.3.6.4'))
			assert !b.on_same_line?(BranchNumber.new('1.3.6.3.4.1'))
			assert !b.on_same_line?(BranchNumber.new('1.3.6.3.2.2.2.1'))
			assert !b.on_same_line?(BranchNumber.new('1.3.6.3.2.99.2.1'))
		end

		def test_primary_revision_number_change
			b = BranchNumber.new('2.3')

			assert b.on_same_line?(BranchNumber.new('2.2'))
			assert b.on_same_line?(BranchNumber.new('2.1'))
			assert b.on_same_line?(BranchNumber.new('1.1'))
			assert b.on_same_line?(BranchNumber.new('1.9999'))
			assert b.on_same_line?(BranchNumber.new('2.4'))
			assert b.on_same_line?(BranchNumber.new('3.1'))
		end

		def test_complex_primary_revision_number_change
			b = BranchNumber.new('2.3.2.1')

			assert b.on_same_line?(BranchNumber.new('2.3'))
			assert b.on_same_line?(BranchNumber.new('2.2'))
			assert b.on_same_line?(BranchNumber.new('1.1'))
			assert b.on_same_line?(BranchNumber.new('1.9999'))
			assert !b.on_same_line?(BranchNumber.new('2.4'))
			assert !b.on_same_line?(BranchNumber.new('3.1'))
		end

		# Crazy CVS inserts a zero before the last piece of a branch number
		def test_magic_branch_numbers
			assert BranchNumber.new('1.1.2.1').on_same_line?(BranchNumber.new('1.1.0.2'))
			assert BranchNumber.new('1.1.2.1.2.1').on_same_line?(BranchNumber.new('1.1.0.2'))

			assert BranchNumber.new('1.1.0.2').on_same_line?(BranchNumber.new('1.1'))
			assert !BranchNumber.new('1.1.0.2').on_same_line?(BranchNumber.new('1.2'))
			assert BranchNumber.new('1.1.0.2').on_same_line?(BranchNumber.new('1.1.2.1'))

			assert BranchNumber.new('1.1.0.4').on_same_line?(BranchNumber.new('1.1'))
			assert !BranchNumber.new('1.1.0.4').on_same_line?(BranchNumber.new('1.1.2.1'))
			assert !BranchNumber.new('1.1.0.4').on_same_line?(BranchNumber.new('1.1.0.2'))
			assert BranchNumber.new('1.1.0.4').on_same_line?(BranchNumber.new('1.1.4.1'))
			assert !BranchNumber.new('1.1.0.4').on_same_line?(BranchNumber.new('1.1.0.6'))
		end
	end
end
