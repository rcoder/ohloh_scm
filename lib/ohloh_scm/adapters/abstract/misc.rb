module OhlohScm::Adapters
  class AbstractAdapter

    def is_merge_commit?(commit)
      false
    end

    def tags
      []
    end

  end
end
