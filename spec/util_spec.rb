require 'rspec'
require 'utils'

describe Utils do
  it("Contains utilities functions for cli and service") {} 

  before(:all) do
    @path = 'myfile.list'
    @contents = "one a\ntwo b\nthree c\n"
    @file_lines = ["one a\n", "two b\n", "three c\n"]
    @item_key = 'four'
    @item_value = 'd' 
    @existing_key = 'two'
    @existing_value = 'b'
    @existing_line = "#{@existing_key} #{@existing_value}\n"
  end

  before(:each) do
    @file_hash = { 'one' => 'a', 'two' => 'b', 'three' => 'c' }
    @file_object = instance_double('File')
    allow(@file_object).to receive(:write)
  end

  describe Utils, '#load_hash_from_list' do
    it "loads a file into a hash" do
      allow(Utils).to receive(:open).and_return(@file_lines)
      h = Utils.load_hash_from_list(@path)
      expect(h[@existing_key]).to eq(@existing_value)
    end
  end

  describe Utils, '#dump_hash_into_list' do
    it "dumps a hash into a file" do
      allow(Utils).to receive(:open).and_yield(@file_object)
      expect(@file_object).to receive(:write).with(@existing_line).once
      Utils.dump_hash_into_list(@path, @file_hash)
    end
  end

  describe Utils, '#file_hash_add' do
    before(:each) do
      allow(Utils).to receive(:load_hash_from_list).and_return(@file_hash)
      allow(Utils).to receive(:dump_hash_into_list) 
    end

    it("Adds a key-value pair to a list file and returns a success value") {}

    it "Adds a key and returns true if the specified key does not exist in the file" do
      expect(Utils).to receive(:dump_hash_into_list) do |path, h|
        expect(h.has_key? @existing_key).to eq(true)
        expect(h[@existing_key]).to eq(@existing_value)
      end

      rv = Utils.file_hash_add(@path, @item_key, @item_value)
      expect(rv).to be(true)
    end
    
    it "Doesn't overwrite the value and returns false if the key already exists" do
      utils_spy = object_double('Utils').as_null_object
      expect(utils_spy).to_not have_received(:dump_hash_into_list)
      rv = Utils.file_hash_add(@path, @existing_key, @existing_value)
      expect(rv).to be(false)
    end
  end

  describe Utils, '#file_hash_remove' do
    before(:each) do
      allow(Utils).to receive(:load_hash_from_list).and_return(@file_hash)
      allow(Utils).to receive(:dump_hash_into_list)
    end

    it("Removes an item from a list file and returns a success value") {}

    it "Removes a key and returns true if the specified key exists in the file" do
      expect(Utils).to receive(:dump_hash_into_list) do |path, h|
        expect(h.has_key? @existing_key).to be(false)
      end
      rv = Utils.file_hash_remove(@path, @existing_key)
      expect(rv).to be(true)
    end

    it "Returns false if the specified key doesn't exist in the file" do
      utils_spy = object_double('Utils').as_null_object
      expect(utils_spy).to_not have_received(:dump_hash_into_list)
      rv = Utils.file_hash_remove(@path, @item_key)
      expect(rv).to be(false)
    end
  end

  describe Utils, '#download_resource' do
    it "downloads the file at the given path"
    it "determines the filetype of the resource by its extension"
    it "uses filetype magic to do the detect if the extension is nonexistent"
    it "takes no action on text files, if the process_text arg is false"
  end
end
