require "digest"
require "semantic_version"

class Digest::Blake3 < ::Digest
  {{ Digest.has_constant?(:Base) ? "::Base" : "" }} # Crystal < 0.36 compatible
  @[Link(ldflags: "-L#{__DIR__}/../../blake3c -lblake3")]
  lib Lib
    fun version = blake3_version : LibC::UChar*

    fun init = blake3_hasher_init(ptr : Void*)
    fun init_keyed = blake3_hasher_init_keyed(ptr : Void*, key : LibC::UChar*)
    fun init_derive_key = blake3_hasher_init_derive_key(ptr : Void*, context : LibC::UChar*)

    fun update = blake3_hasher_update(ptr : Void*, input : LibC::UChar*, size : LibC::SizeT)

    fun final = blake3_hasher_finalize(ptr : Void*, output : LibC::UChar*, size : LibC::SizeT)
    fun final_seek = blake3_hasher_finalize_seek(ptr : Void*, seek : UInt64, output : LibC::UChar*, size : LibC::SizeT)

    fun reset = blake3_hasher_reset(ptr : Void*)
  end

  KEY_SIZE = 32
  OUT_SIZE = 32

  LIB_VERSION = SemanticVersion.parse(String.new(Lib.version))

  @hasher = StaticArray(UInt8, 1912).new 0

  getter digest_size : Int32

  def initialize(@digest_size : Int32 = OUT_SIZE, key = nil, context = nil)
    super()

    if k = key
      raise ArgumentError.new("can't set key and derive") if context

      slice = k.to_slice
      raise ArgumentError.new("key must be #{KEY_SIZE} bytes, got #{slice.bytesize}") if slice.bytesize != KEY_SIZE
      Lib.init_keyed self, slice
    elsif c = context
      raise "not tested"
      Lib.init_derive_key self, c
    else
      Lib.init self
    end
  end

  protected def update_impl(data : Bytes) : Nil
    Lib.update self, data, data.bytesize
  end

  protected def final_impl(data : Bytes) : Nil
    Lib.final self, data, data.bytesize
  end

  protected def reset_impl : Nil
    Lib.reset self
  end

  # :nodoc:
  def to_unsafe
    pointerof(@hasher)
  end
end
