class CommitTokensHelper
  def initialize(base, commit_labels, trunk_only: false)
    @base = base
    @trunk_only = trunk_only
    @commit_labels = commit_labels
  end

  def between(from, to)
    to_labels(@base.activity.commit_tokens(after: from_label(from), up_to: from_label(to),
                                           trunk_only: @trunk_only))
  end

  private

  def to_label(sha1)
    @commit_labels.invert[sha1.to_s]
  end

  def to_labels(sha1s)
    sha1s.map { |sha1| to_label(sha1) }
  end

  def from_label(label)
    @commit_labels[label]
  end
end
