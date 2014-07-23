
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
  def process_sync(uri)
    rss = open(uri) { |file| RSS::Parser.parse(file) }
    return rss.items.collect { |x| x.link }
  end

  def process_async(uri)
    begin
      rss = open(uri + '.rss') { |file| RSS::Parser.parse(file) }
      doc = Nokogiri::HTML(rss.items.first.description)
      a = doc.css('a').find { |el| el.text == '[link]' }
      if a
        return a['href']
      end
    rescue
    end
  end
end

