
class BaseParser
  def parse(uri)
    sync_result = process_sync uri
    threads = []
    async_result = []
    sync_result.each do |x|
      threads << Thread.new(x) { |x| async_result << process_async(x) }
    end
    threads.each { |t| t.join }
    return async_result.compact
  end

  # To be overridden by subclasses
  def process_sync(uri)
    return [uri]
  end

  # To be overridden by subclasses
  def process_async(uri)
    return uri
  end
end

class RedditRSSParser < BaseParser
  def process_sync uri

  end

  def process_async uri

  end
end

