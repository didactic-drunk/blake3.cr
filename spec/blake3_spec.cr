require "./spec_helper"
require "../src/digest/blake3"
require "json_mapping"

class TestVectors
  class Case
    JSON.mapping(
      input_len: UInt32,
      hash: String,
      keyed_hash: String,
      derive_key: String,
    )
  end

  JSON.mapping(
    key: String,
    context_string: String,
    cases: Array(Case),
  )
end

describe Digest::Blake3 do
  it "resets" do
    [{nil, "04e0bb39f30b1a3feb89f536c93be15055482df748674b00d26e5a75777702e9"},
     {"01234567890123456789012345678901", "b5fef3e03571cf95791c4c34950d2819f807152bf5bc789541ac8cfa9f62733a"},
    ].each do |key, output|
      d = Digest::Blake3.new key: key
      d.update "foo"
      h1 = d.final.hexstring
      h1.should eq output

      d.reset
      d.update "foo"
      h2 = d.final.hexstring
      h2.should eq h1
    end
  end

  it "dups" do
    d1 = Digest::Blake3.new
    d2 = d1.dup

    d1.update "foo"
    h1 = d1.final.hexstring

    d2.update "foo"
    h2 = d2.final.hexstring

    h1.should eq "04e0bb39f30b1a3feb89f536c93be15055482df748674b00d26e5a75777702e9"
    h1.should eq h2
  end

  vectors = TestVectors.from_json(File.read(Path.new({{__DIR__}}).join("test_vectors.json")))

  max_isize = vectors.cases.map { |c| c.input_len }.sum
  ibuf = Slice(UInt8).new(max_isize)
  max_isize.times do |i|
    ibuf[i] = (i % 251).to_u8
  end

  it "test vectors" do
    out_size = 131

    vectors.cases.each do |c|
      d = Digest::Blake3.new(out_size)
      d.update ibuf[0, c.input_len]
      d.final.hexstring.should eq c.hash

      d = Digest::Blake3.new(out_size, key: vectors.key)
      d.update ibuf[0, c.input_len]
      d.final.hexstring.should eq c.keyed_hash

      d = Digest::Blake3.new(out_size, context: vectors.context_string)
      d.update ibuf[0, c.input_len]
      d.final.hexstring.should eq c.derive_key
    end
  end

  pending "derive key if anyone uses it" do
  end

  it ".digest" do
    vectors.cases.each do |c|
      Digest::Blake3.digest(ibuf[0, c.input_len], digest_size: 131).hexstring.should eq c.hash
      Digest::Blake3.digest(ibuf[0, c.input_len], key: vectors.key, digest_size: 131).hexstring.should eq c.keyed_hash
      Digest::Blake3.digest(ibuf[0, c.input_len], context: vectors.context_string, digest_size: 131).hexstring.should eq c.derive_key
    end
  end

  it ".hexdigest" do
    vectors.cases.each do |c|
      Digest::Blake3.hexdigest(ibuf[0, c.input_len]).should eq c.hash[0, 64]
      Digest::Blake3.hexdigest(ibuf[0, c.input_len], key: vectors.key).should eq c.keyed_hash[0, 64]
      Digest::Blake3.hexdigest(ibuf[0, c.input_len], context: vectors.context_string).should eq c.derive_key[0, 64]
    end
  end

  it ".base64digest" do
    vectors.cases.each do |c|
      Digest::Blake3.base64digest(ibuf[0, c.input_len]).should eq Base64.strict_encode(c.hash[0, 64].hexbytes)
      Digest::Blake3.base64digest(ibuf[0, c.input_len], key: vectors.key).should eq Base64.strict_encode(c.keyed_hash[0, 64].hexbytes)
      Digest::Blake3.base64digest(ibuf[0, c.input_len], context: vectors.context_string).should eq Base64.strict_encode(c.derive_key[0, 64].hexbytes)
    end
  end
end
