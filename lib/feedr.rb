require 'parsers'
require 'utils'

DATA_DIR = "/usr/local/share/feedr"
TARGET_DIR = File.join(DATA_DIR, "media")
LIST_FILE = File.join(DATA_DIR, "db.list")
RESOURCE = "http://www.reddit.com/r/EarthPorn/.rss"

class DownloadingParser < RedditRSSParser
  def initialize(target_dir, db_hash)
    @target_dir = target_dir
    @db_hash = db_hash
  end

  def process_async(uri)
    if @db_hash.key? uri
      return
    end

    image_link = super uri
    result = Utils.download_resource image_link, @target_dir
    if result
      @db_hash[uri] = result
    end
  end
end

def fetch
  db_hash = Utils.load_hash_from_list LIST_FILE
  parser = DownloadingParser.new TARGET_DIR, db_hash
  rv = parser.parse RESOURCE
  Utils.dump_hash_into_list LIST_FILE, db_hash
end

%x(mkdir -p #{TARGET_DIR})
%x(touch #{LIST_FILE})

fetch

