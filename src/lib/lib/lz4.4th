( Basic interface to liblz4 that provides lz4-compress and lz4-decompress. )

NORTH-PLATFORM tmp" android" drop contains? [IF]
  library> liblz4.so
[ELSE]
  library> liblz4.so.1
[THEN]
( fixme top level IF gets shadowed by core.4th's IF )
( dup UNLESS library> liblz4.so.1 THEN )
import> LZ4_compress_default 1 LZ4_compress_default 4
import> LZ4_compressBound 1 LZ4_compressBound 1
import> LZ4_decompress_safe 1 LZ4_decompress_safe 4

def lz4-compress ( str length ++ out-str out-length )
  0 0
  arg0 LZ4_compressBound dup .s set-local1 stack-allot set-local0
  local1 arg0 local0 arg1 LZ4_compress_default .s
  negative? IF
    0 swap return2
  ELSE
    local0 swap exit-frame
  THEN
  local0 local1 exit-frame
end

def lz4-decompress ( str length out-ptr out-size -- str length out-ptr out-length )
  arg0 arg2 arg1 arg3 LZ4_decompress_safe set-arg0
end
