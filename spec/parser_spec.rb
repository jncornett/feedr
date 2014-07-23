require 'rspec'
require 'yaml'
require 'nokogiri'
require 'rss'
require 'parsers'

describe BaseParser do
  before(:all) do
    class ChildParser < BaseParser
      def process_sync(uri)
      end
      def process_async(uri)
      end
    end

    @childinstance = ChildParser.new
    @uri = 'http://www.example.com'
    @sync_result = [0, 1, 2, 3]
    @async_result = @sync_result.collect { |x| x + @sync_result.length }
  end

  describe BaseParser, '#parse' do
    it "calls its child classes' process_sync and process_async methods to parse a uri" do
      expect(@childinstance).to receive(:process_sync).with(@uri).and_return(@sync_result)
      @sync_result.zip(@async_result) do |s, a|
        expect(@childinstance).to receive(:process_async).with(s).and_return(a)
      end
      rv = @childinstance.parse @uri
      expect(rv).to match_array(@async_result)
    end

    it "possesses overridable methods which pass through their arguments" do
      b = BaseParser.new
      rv = b.parse @uri
      expect(rv).to contain_exactly(@uri)
    end
  end
end

describe RedditRSSParser do
    before(:all) do
	@uri = 'http://www.reddit.com/r/EarthPorn/.rss'
        @raw_rss_landing = open('snapshot.rss') { |file| file.read }
        @feed_landing = RSS::Parser.parse(@raw_rss_landing)
        @sync_result = @feed_landing.items.collect { |item| item.link }
        @async_raw_rss_html = open('async_results.yaml') { |file| YAML::load(file.read) }
        @async_feeds = @async_raw_rss_html.collect { |rss| RSS::Parser.parse(rss) }
        @async_descriptions = @async_feeds.collect { |feed| feed.items[0].description }
        @async_result = @async_descriptions.collect do |html|
          doc = Nokogiri::HTML(html)
          a = doc.css('a').find { |el| el.text == '[link]' }
          if a
            next a['href']
          end
        end

        @parserinstance = RedditRSSParser.new
    end

    before(:each) do
      allow(@parserinstance).to receive(:open).with(@uri).and_return(@raw_rss_landing)
      @sync_result.zip(@async_raw_rss_html) do |link, raw|
        allow(@parserinstance).to receive(:open).with(link).and_return(raw)
      end
    end
    
    describe RedditRSSParser, '#process_sync' do
      it "Parses the links out of a reddit landing page" do
        rv = @parserinstance.process_sync @uri
        expect(rv).to match_array(@sync_result)
      end
    end

    describe RedditRSSParser, '#process_async' do
      it "Parses the remote links out of reddit post pages" do
        rv = @sync_result.collect { |link| @parserinstance.process_async(link) }
        expect(rv).to match_array(@async_result)
      end
    end

    describe RedditRSSParser, '#parse' do
      it "Parses a reddit landing page into resources" do
        rv = @parserinstance.parse @uri
        expect(rv).to
end
