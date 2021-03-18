require "digest"

class Digest::Blake3 < ::Digest
  {{ Digest.has_constant?(:Base) ? "::Base" : "" }} # Crystal < 0.36 compatible
  @[Link(ldflags: "-L#{__DIR__}/../../BLAKE3/c -lblake3")]
  lib Lib
    fun init = blake3_hasher_init(ptr : Void*)
    fun init_keyed = blake3_hasher_init_keyed(ptr : Void*, key : LibC::UChar*)
    fun init_derive_key = blake3_hasher_init_derive_key(ptr : Void*, context : LibC::UChar*)

    fun update = blake3_hasher_update(ptr : Void*, input : LibC::UChar*, size : LibC::SizeT)

    fun final = blake3_hasher_finalize(ptr : Void*, output : LibC::UChar*, size : LibC::SizeT)
    fun final_seek = blake3_hasher_finalize_seek(ptr : Void*, seek : UInt64, output : LibC::UChar*, size : LibC::SizeT)
  end

  KEY_SIZE = 32

  OUT_SIZE = 32

  # :nodoc:
  enum Init
    Normal
    Keyed
    Derive
  end

  @hasher = StaticArray(UInt8, 1912).new 0
  @init = Init::Normal
  @key = StaticArray(UInt8, 32).new 0
  @context : Bytes?

  getter digest_size : Int32

  def initialize(@digest_size : Int32 = OUT_SIZE, key = nil, context = nil)
    super()

    if k = key
      raise ArgumentError.new("can't set key and derive") if context

      slice = k.to_slice
      raise ArgumentError.new("key must be #{KEY_SIZE} bytes, got #{slice.bytesize}") if slice.bytesize != KEY_SIZE
      @key.to_slice.copy_from slice
      @init = Init::Keyed
    elsif c = context
      raise "not implemented"
      @init = Init::Derive
    end

    reset
  end

  protected def update_impl(data : Bytes) : Nil
    Lib.update self, data, data.bytesize
  end

  protected def final_impl(data : Bytes) : Nil
    Lib.final self, data, data.bytesize
  end

  protected def reset_impl : Nil
    case @init
    when Init::Normal
      Lib.init self
    when Init::Keyed
      Lib.init_keyed self, @key.to_slice
    when Init::Derive
      Lib.init_derive_key self, @context.not_nil!
    end
  end

  # :nodoc:
  def to_unsafe
    pointerof(@hasher)
  end
end
