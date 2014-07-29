require 'uri'
require 'open-uri'
require 'securerandom'
require 'fileutils'

EXT_MAP = {
  'svg+xml' => 'svg'
}

module Utils
  def Utils.load_hash_from_list(path)
    h = {}
    open(path).each do |line|
      key, value = line.chomp.split(' ', 2)
      if key and value
        h[key] = value
      end
    end

    return h
  end

  def Utils.dump_hash_into_list(path, hash)
    open(path, 'wb') do |file|
      hash.each { |key, value| file.write("#{key} #{value}\n") }
    end
  end

  def Utils.file_hash_add(path, key, value)
    h = load_hash_from_list(path)
    if h.has_key? key
      return false
    end

    h[key] = value

    Utils.dump_hash_into_list(path, h)

    return true
  end

  def Utils.file_hash_remove(path, key)
    h = load_hash_from_list(path)
    if h.has_key? key
      h.delete key
      Utils.dump_hash_into_list(path, h)
      return true
    end

    return false
  end

  def Utils.make_temp_dir
    return %x(mktemp -d feedr.XXX).chomp
  end

  def Utils.get_mime_type(path)
    return %x(file --mime -b #{path}).split(';').first
  end

  def Utils.download_resource(uri, target_dir)
    begin
      tempdir = Utils.make_temp_dir
      uname = URI(uri).path.split('/').last
      path = File.join tempdir, uname 
      open(uri) { |infile| open(path, 'wb') { |outfile| outfile.write(infile.read) } }
      type = Utils.get_mime_type path 
      klass, ext = type.split '/' 
      if klass != 'image'
        return
      end

      if not ext
        return
      end

      target_name = SecureRandom.urlsafe_base64(5) + '.' + EXT_MAP.fetch(ext, ext)
      target_path = File.join target_dir, target_name 

      FileUtils.cp path, target_path
      
      return target_name
    rescue Exception
      return nil
    ensure
      if tempdir
        FileUtils.rm_r [tempdir]
      end
    end
  end
end
