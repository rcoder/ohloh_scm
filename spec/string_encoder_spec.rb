# frozen_string_literal: true

require 'spec_helper'

describe 'string_encoder' do
  it 'preserve length of translated content' do
    file_path = File.expand_path('data/sample-content', __dir__)
    original_content_length = File.size(file_path)
    original_content_lines = File.readlines(file_path).size

    output = `cat #{ file_path } \
      | #{ OhlohScm::Base.new(:git, 'url').string_encoder_path }`

    assert_equal original_content_length, output.length
    assert_equal original_content_lines, output.split("\n").length
  end

  it 'must convert invalid characters' do
    invalid_utf8_word_path = File.expand_path('data/invalid-utf-word', __dir__)

    string = `cat #{ invalid_utf8_word_path } \
      | #{ OhlohScm::Base.new(:git, 'url').string_encoder_path }`

    assert_equal true, string.valid_encoding?
  end
end
