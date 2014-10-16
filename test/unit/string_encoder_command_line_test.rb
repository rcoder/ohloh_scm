require_relative '../test_helper'

module OhlohScm::Parsers
  class StringEncoderCommandLineTest < OhlohScm::Test
    def test_length_of_content_unchanged
      file_path = File.expand_path('../../data/sample-content', __FILE__)
      original_content_length = File.size(file_path)
      original_content_lines = File.readlines(file_path).size

      output = %x[cat #{ file_path } \
        | #{ OhlohScm::Adapters::AbstractAdapter.new.string_encoder } ]

      assert_equal original_content_length, output.length
      assert_equal original_content_lines, output.split("\n").length
    end

    def test_encoding_invalid_characters
      invalid_utf8_word_path =
        File.expand_path('../../data/invalid-utf-word', __FILE__)

      string = %x[cat #{ invalid_utf8_word_path } \
        | #{ OhlohScm::Adapters::AbstractAdapter.new.string_encoder } ]

      assert_equal true, string.valid_encoding?
    end
  end
end
