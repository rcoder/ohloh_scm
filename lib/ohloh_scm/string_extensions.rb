# frozen_string_literal: true

module OhlohScm
  module StringExtensions
    refine String do
      def camelize
        split('_').map(&:capitalize).join
      end
    end
  end
end
