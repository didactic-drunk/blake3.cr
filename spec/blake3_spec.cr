require "./spec_helper"
require "../src/digest/blake3"

describe Digest::Blake3 do
  it "resets" do
    [{nil, "04e0bb39f30b1a3feb89f536c93be15055482df748674b00d26e5a75777702e9"}, {"01234567890123456789012345678901", "b5fef3e03571cf95791c4c34950d2819f807152bf5bc789541ac8cfa9f62733a"}].each do |key, output|
      d = Digest::Blake3.new key: key
      d.update "foo"
      h1 = d.final.hexstring

      d.reset
      d.update "foo"
      h2 = d.final.hexstring

      h1.should eq output
      h1.should eq h2
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
end
