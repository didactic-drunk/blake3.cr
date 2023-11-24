require "digest"
require "semantic_version"

class Digest::Blake3 < ::Digest{{ Digest.has_constant?(:Base) ? "::Base" : "" }} # Crystal < 0.36 compatible
  {% if Digest.has_constant?(:ClassMethods) %} extend ClassMethods {% end %}

  @[Link(ldflags: "-L#{__DIR__}/../../blake3c -lblake3")]
  lib Lib
    alias Hasher = UInt8[1912]
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

  getter digest_size : Int32
  @hasher = uninitialized Lib::Hasher

  protected def self.init(hasher, key, context)
    if key
      raise ArgumentError.new("can't set key and derive") if context
      raise ArgumentError.new("key must be #{KEY_SIZE} bytes, got {key.bytesize}") unless key.bytesize == KEY_SIZE
      Lib.init_keyed hasher, key
    elsif context
      Lib.init_derive_key hasher, context
    else
      Lib.init hasher
    end
  end

  def initialize(@digest_size : Int32 = OUT_SIZE, key = nil, context = nil)
    self.class.init self, key, context
    super()
  end

  protected def update_impl(data : Bytes) : Nil
    Lib.update self, data, data.bytesize
  end

  protected def final_impl(dst : Bytes) : Nil
    Lib.final self, dst, dst.bytesize
  end

  protected def reset_impl : Nil
    Lib.reset self
  end

  # :nodoc:
  def to_unsafe
    pointerof(@hasher)
  end

  def self.digest(data : Bytes, key = nil, context = nil, digest_size = OUT_SIZE) : Bytes
    hasher = uninitialized Lib::Hasher
    hashsum = Bytes.new(digest_size)
    init pointerof(hasher), key, context
    Lib.update pointerof(hasher), data, data.bytesize
    Lib.final pointerof(hasher), hashsum, hashsum.bytesize
    hashsum
  end

  def self.hexdigest(data, key = nil, context = nil) : String
    hexdigest(data.to_slice, key, context)
  end

  def self.hexdigest(data : Bytes, key = nil, context = nil) : String
    hasher = uninitialized Lib::Hasher
    hashsum = uninitialized UInt8[32]
    init pointerof(hasher), key, context
    Lib.update pointerof(hasher), data, data.bytesize
    Lib.final pointerof(hasher), hashsum, 32
    hashsum.to_slice.hexstring
  end

  def self.base64digest(data, key = nil, context = nil) : String
    base64digest(data.to_slice, key, context)
  end

  def self.base64digest(data : Bytes, key = nil, context = nil) : String
    hasher = uninitialized Lib::Hasher
    hashsum = uninitialized UInt8[32]
    init pointerof(hasher), key, context
    Lib.update pointerof(hasher), data, data.bytesize
    Lib.final pointerof(hasher), hashsum, 32
    Base64.strict_encode(hashsum.to_slice)
  end
end
