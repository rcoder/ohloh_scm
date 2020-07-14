module OhlohScm::Parsers
	class BranchNumber
		def initialize(s)
			@a = s.split('.').collect { |i| i.to_i }
			# Accomodate CVS magic branch numbers by swapping the magic zero
			# That is, 1.1.0.2 => 1.1.2.0
			if @a.size > 2 and @a[-2]==0
				@a[-1],@a[-2] = @a[-2],@a[-1]
			end
		end

		def to_s
			@a.join('.')
		end

		def to_a
			@a
		end

		# Returns true if <branch_number> is an ancestor of this object.
		# Also returns true if <branch_number> is the same as this object.
		def inherits_from?(branch_number)
			b = branch_number.to_a

			return false if b.size > @a.size

			if b.size == 2
				return false if b[0] > @a[0]
				return false if b[0] == @a[0] and b[1] > @a[1]
			else
				0.upto(b.size-2) do |i|
					return false if b[i] != @a[i]
				end
				return false if b[-1] > @a[b.size-1]
			end

			true
		end

		# Returns true if <branch_number> is an ancestor of this object,
		# or if this object follows <branch_number> on the same line.
		def on_same_line?(branch_number)
			b = branch_number.to_a

			if b.size > @a.size
				# b has been branched more times than this object.
				return false
			elsif b.size == @a.size
				# b and a have the same number of branch events.
				# If either one inherits from the other then they
				# are on the same line.
				return (inherits_from?(branch_number) or branch_number.inherits_from?(self))
			elsif b.size < @a.size
				# b has not been branched as often as this object.
				# That's OK if b is an ancestor of this object.
				return inherits_from?(branch_number)
			end
		end
	end
end
