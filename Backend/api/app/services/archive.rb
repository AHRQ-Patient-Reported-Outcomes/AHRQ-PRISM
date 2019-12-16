module Archive
  def self.clean_meta(meta)
    meta.deep_symbolize_keys!

    if meta[:lastUpdated]
      meta[:lastUpdated] = DateTime.parse(meta[:lastUpdated]).iso8601
    end

    meta
  rescue ArgumentError
    meta.delete(:lastUpdated)
    meta
  end
end
