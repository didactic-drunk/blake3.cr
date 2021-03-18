require "option_parser"
require "../src/digest/blake3"
# require "openssl"

out_size = 64
buf_size = 8192
digest_name = "blake3"

optp = OptionParser.new
optp.on("--out-size=INT", "") { |arg| out_size = arg.to_i }
optp.on("--buf-size=INT", "") { |arg| buf_size = arg.to_i }
optp.on("--digest=NAME", "") { |arg| digest_name = arg }
optp.parse

class Digest::Null < Digest
  def update_impl(data : Bytes) : Nil
  end

  def final_impl(data : Bytes) : Nil
  end

  def reset_impl : Nil
  end

  def digest_size : Int32
    0
  end
end

digest = case digest_name
         when "blake3"
           Digest::Blake3.new
           # out_size
         when "null"
           Digest::Null.new
         else
           raise "unsupported #{digest_name}"
           #		OpenSSL::Digest.new digest_name
         end

buf = Bytes.new buf_size

loop do
  r = STDIN.read buf
  break if r <= 0

  digest.update buf[0, r]
end

puts digest.final.hexstring
