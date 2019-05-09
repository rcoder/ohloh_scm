# frozen_string_literal: true

module AssertScmAttrHelper
  def get_base(scm_type, opts = {})
    OhlohScm::Factory.get_base({ scm_type: scm_type, url: 'foobar' }.merge(opts))
  end

  def assert_url_error(scm_type, *urls)
    urls.each do |url|
      base = get_base(scm_type, url: url)
      base.status.send(:url_errors).wont_be :empty?
    end
  end

  def assert_url_valid(scm_type, url)
    base = get_base(scm_type, url: url)
    base.status.send(:url_errors).must_be_nil
  end

  def assert_branch_name_error(scm_type, *branches)
    branches.each do |branch_name|
      base = get_base(scm_type, url: ':pserver:cvs:cvs@cvs.test.org:/test', branch_name: branch_name)
      base.status.send(:branch_name_errors).wont_be :empty?
    end
  end

  def assert_branch_name_valid(scm_type, branch_name)
    base = get_base(scm_type, url: ':pserver:cvs:cvs@cvs.test.org:/test', branch_name: branch_name)
    base.status.send(:branch_name_errors).must_be_nil
  end
end
