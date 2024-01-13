( SHA-256 function:
  See RFC 6234 at https://www.rfc-editor.org/rfc/rfc6234 for details.
)

s[ src/lib/endian.4th
   src/lib/digest/hexdigest.4th
] load-list

def copy-UINT32 ( src dest n -- )
  ( Byte swap ~n~ big endian uint32's from ~src~ and store them in ~dest~. )
  arg0 0 uint> UNLESS 3 return0-n THEN
  arg0 1 - set-arg0
  arg0 4 *
  arg2 over + uint32@
  host-little-endian? IF byte-swap-uint32 THEN
  arg1 roll + uint32!
  repeat-frame
end

( SHA-256's magic numbers: )

0xc67178f2 0xbef9a3f7 0xa4506ceb 0x90befffa
0x8cc70208 0x84c87814 0x78a5636f 0x748f82ee
0x682e6ff3 0x5b9cca4f 0x4ed8aa4a 0x391c0cb3
0x34b0bcb5 0x2748774c 0x1e376c08 0x19a4c116
0x106aa070 0xf40e3585 0xd6990624 0xd192e819
0xc76c51a3 0xc24b8b70 0xa81a664b 0xa2bfe8a1
0x92722c85 0x81c2c92e 0x766a0abb 0x650a7354
0x53380d13 0x4d2c6dfc 0x2e1b2138 0x27b70a85
0x14292967 0x06ca6351 0xd5a79147 0xc6e00bf3
0xbf597fc7 0xb00327c8 0xa831c66d 0x983e5152
0x76f988da 0x5cb0a9dc 0x4a7484aa 0x2de92c6f
0x240ca1cc 0x0fc19dc6 0xefbe4786 0xe49b69c1
0xc19bf174 0x9bdc06a7 0x80deb1fe 0x72be5d74
0x550c7dc3 0x243185be 0x12835b01 0xd807aa98
0xab1c5ed5 0x923f82a4 0x59f111f1 0x3956c25b
0xe9b5dba5 0xb5c0fbcf 0x71374491 0x428a2f98
64 here const> SHA256-K-VALUES

0x5be0cd19 0x1f83d9ab 0x9b05688c 0x510e527f
0xa54ff53a 0x3c6ef372 0xbb67ae85 0x6a09e667
8 here const> SHA256-INIT-VALUES

( SHA's basic operations: )

( CH[ x, y, z] = [x AND y] XOR [ [NOT x] AND z] )
def sha256-ch ( z y x -- v )
  arg0 arg1 logand
  arg0 lognot arg2 logand
  logxor 3 return1-n
end

( MAJ[ x, y, z] = [x AND y] XOR [x AND z] XOR [y AND z] )
def sha256-maj ( z y x -- v )
  arg0 arg1 logand
  arg0 arg2 logand logxor
  arg1 arg2 logand logxor
  3 return1-n
end

( ROTR^n[x] = [x>>n] OR [x<<[w-n]] )
def sha256-rotr32 ( x n -- v )
  arg1 arg0 bsr
  arg1 32 arg0 - bsl logior
  2 return1-n
end

( ROTL^n[x] = [x<<n] OR [x>>[w-n]] )
def sha256-rotl32 ( x n -- v )
  arg1 arg0 bsl
  arg1 32 arg0 - bsr logior
  2 return1-n
end

( BSIG0[x] = ROTR^2[x] XOR ROTR^13[x] XOR ROTR^22[x] )
def sha256-bsig0 ( x -- v )
  arg0 2 sha256-rotr32
  arg0 13 sha256-rotr32 logxor
  arg0 22 sha256-rotr32 logxor
  1 return1-n
end

( BSIG1[x] = ROTR^6[x] XOR ROTR^11[x] XOR ROTR^25[x] )
def sha256-bsig1 ( x -- v )
  arg0 6 sha256-rotr32
  arg0 11 sha256-rotr32 logxor
  arg0 25 sha256-rotr32 logxor
  1 return1-n
end

( SSIG0[x] = ROTR^7[x] XOR ROTR^18[x] XOR SHR^3[x] )
def sha256-ssig0 ( x -- v )
  arg0 7 sha256-rotr32
  arg0 18 sha256-rotr32 logxor
  arg0 3 bsr logxor
  1 return1-n
end

( SSIG1[x] = ROTR^17[x] XOR ROTR^19[x] XOR SHR^10[x] )
def sha256-ssig1 ( x -- v )
  arg0 17 sha256-rotr32
  arg0 19 sha256-rotr32 logxor
  arg0 10 bsr logxor
  1 return1-n
end


( State storage: )

8 16 + 1 + const> sha256-state-size

( RFC calls these H. )
def sha256-state-hash ( nop ) end
def sha256-state-total-size arg0 8 cell-size * + set-arg0 end
def sha256-state-buffer-size arg0 9 cell-size * + set-arg0 end
def sha256-state-buffer arg0 10 cell-size * + set-arg0 end

def make-sha256-state
  sha256-state-size stack-allot-zero-seq exit-frame
end


( The actual bits of the hash function: )


def sha256-words-init-loop ( w t -- )
  ( For t = 16 to 63
       W[t] = SSIG1[W[t-2]] + W[t-7] + SSIG0[w[t-15]] + W[t-16] )
  arg0 64 uint< UNLESS 2 return0-n THEN
  arg1 arg0 2 - seq-peek sha256-ssig1
  arg1 arg0 7 - seq-peek +
  arg1 arg0 15 - seq-peek sha256-ssig0 +
  arg1 arg0 16 - seq-peek +
  arg1 arg0 seq-poke
  arg0 1 + set-arg0 repeat-frame
end

def sha256-words-init ( message w -- w )
  ( Prepare the message schedule W:
      For t = 0 to 15
        W[t] = M[i][t] )
  arg1 arg0 16 copy-UINT32
  ( For t = 16 to 63
      W[t] = SSIG1[W[t-2]] + W[t-7] + SSIG0[w[t-15]] + W[t-16] )
  arg0 16 sha256-words-init-loop
  arg0 2 return1-n
end

def sha256-inner-rounds ( work-vars W t -- work-vars )
  ( Perform the main hash computation:
         For t = 0 to 63
            T1 = h + BSIG1[e] + CH[e,f,g] + K[t] + W[t]
            T2 = BSIG0[a] + MAJ[a,b,c]
            h = g
            g = f
            f = e
            e = d + T1
            d = c
            c = b
            b = a
            a = T1 + T2 )
  arg0 64 uint< UNLESS arg2 3 return1-n THEN
  0 0
  ( T1 )
  arg2 7 seq-peek
  arg2 4 seq-peek sha256-bsig1 +
  arg2 6 seq-peek arg2 5 seq-peek arg2 4 seq-peek sha256-ch +
  SHA256-K-VALUES arg0 seqn-peek +
  arg1 arg0 seq-peek + set-local0
  ( T2 )
  arg2 0 seq-peek sha256-bsig0
  arg2 2 seq-peek arg2 1 seq-peek arg2 0 seq-peek sha256-maj + set-local1
  ( h -> a )
  arg2 6 seq-peek arg2 7 seq-poke
  arg2 5 seq-peek arg2 6 seq-poke
  arg2 4 seq-peek arg2 5 seq-poke
  arg2 3 seq-peek local0 + arg2 4 seq-poke
  arg2 2 seq-peek arg2 3 seq-poke
  arg2 1 seq-peek arg2 2 seq-poke
  arg2 0 seq-peek arg2 1 seq-poke
  local0 local1 + arg2 0 seq-poke
  ( loop )
  arg0 1 + set-arg0 drop-locals repeat-frame
end

def sha256-update-hash-value ( work-vars hash-value -- hash-value )
  ( Compute the intermediate hash value H[i]
         H[i]0 = a + H[i-1]0
         H[i]1 = b + H[i-1]1
         H[i]2 = c + H[i-1]2
         H[i]3 = d + H[i-1]3
         H[i]4 = e + H[i-1]4
         H[i]5 = f + H[i-1]5
         H[i]6 = g + H[i-1]6
         H[i]7 = h + H[i-1]7 )
  arg1 0 seq-peek arg0 0 seq-peek + arg0 0 seq-poke
  arg1 1 seq-peek arg0 1 seq-peek + arg0 1 seq-poke
  arg1 2 seq-peek arg0 2 seq-peek + arg0 2 seq-poke
  arg1 3 seq-peek arg0 3 seq-peek + arg0 3 seq-poke
  arg1 4 seq-peek arg0 4 seq-peek + arg0 4 seq-poke
  arg1 5 seq-peek arg0 5 seq-peek + arg0 5 seq-poke
  arg1 6 seq-peek arg0 6 seq-peek + arg0 6 seq-poke
  arg1 7 seq-peek arg0 7 seq-peek + arg0 7 seq-poke
  arg0 2 return1-n
end

def sha256-update-step ( message[n, 16] state -- state )
  ( Hashes a single 16 byte block and updates the state. )
  0 0
  64 stack-allot-zero-seq set-local0
  8 stack-allot-zero-seq set-local1
  arg0 sha256-state-hash local1 8 cell-size * copy
  arg1 local0 sha256-words-init
  local1 swap 0 sha256-inner-rounds arg0 sha256-state-hash sha256-update-hash-value
  arg0 2 return1-n
end


( Last block padding: )

def sha256-pad-buffer-head ( state -- )
  ( Standard requires a 1 bit be appeneded to the message followed by zeros to pad to 512 bits - 64 bits. )
  arg0 sha256-state-buffer-size @
  arg0 sha256-state-buffer
  ( terminate buffer & update )
  0x80 local1 local0 poke-off-byte
  local1 local0 + 1 + 64 local0 - 1 - 0 fill
  1 return0-n
end

def sha256-pad-buffer-tail ( state -- )
  ( The last, padded block also has appened to it the bit length as a big endian integer. )
  arg0 sha256-state-total-size @ 8 * host-little-endian? IF byte-swap-uint32 THEN
  arg0 sha256-state-buffer 60 + uint32!
  1 return0-n
end

def sha256-pad-buffer ( state -- )
  arg0 sha256-pad-buffer-head
  arg0 sha256-pad-buffer-tail
  1 return0-n
end


( Public facing words: )


def sha256-begin ( state -- state )
  ( init/reset working variables and state )
  SHA256-INIT-VALUES cell-size + arg0 sha256-state-hash 8 cell-size * copy
  0 arg0 sha256-state-total-size !
  0 arg0 sha256-state-buffer-size !
end

def sha256-update/4 ( byte-ptr length state n -- state )
  ( Process byte-ptr in 16 cell, 64 byte increments. )
  ( todo the other digests could reuse this block partitioning )
  arg1 sha256-state-buffer-size @ 0 uint> IF
    ( when anything is buffered: use that and fill the buffer with M[0, 64 - buffer_size] and update )
    arg1 sha256-state-buffer-size @
    64 local0 - arg2 arg0 - min
    arg3 arg1 sha256-state-buffer local0 + local1 copy
    local0 + arg1 sha256-state-buffer-size !
    arg1 sha256-state-buffer-size @ 64 uint< IF
      arg1 4 return1-n
    ELSE
      arg1 sha256-state-buffer arg1 sha256-update-step
      ( in the next iteration: any left overs not >=64 in length are copied to the buffer )
      0 arg1 sha256-state-buffer-size !
      arg1 sha256-state-total-size @ 64 + sha256-state-total-size !
      arg0 local1 + set-arg0 drop-locals repeat-frame
    THEN
  ELSE
    ( with nothing buffered, update with every 64 bytes from the message, buffering the last fragment )
    arg2 arg0 -
    local0 64 uint< IF
      arg3 arg0 + arg1 sha256-state-buffer local0 copy
      local0 arg1 sha256-state-buffer-size !
      arg1 4 return1-n
    ELSE
      arg3 arg0 + arg1 sha256-update-step
      arg1 sha256-state-total-size @ 64 + arg1 sha256-state-total-size !
      arg0 64 + set-arg0 drop-locals repeat-frame
    THEN
  THEN
end

' tail+1 defined? IF
def sha256-update ( byte-ptr length state -- state )
  0 ' sha256-update/4 tail+1
end
ELSE
def sha256-update ( byte-ptr length state -- state )
  arg2 arg1 arg0 0 sha256-update/4 arg0 3 return1-n
end
THEN

( todo be non-destructive )
def sha256-end ( state -- state )
  ( standard pads to 512 bits [64 bytes] with a leading 1 bit, zeros, and in the last 64 bits the message length )
  arg0 sha256-state-buffer-size @
  arg0 sha256-state-buffer
  local0 0 uint> IF
    arg0 sha256-state-total-size @ local0 + arg0 sha256-state-total-size !
    ( if anything is buffered: pad that and update )    
    local0 55 uint>= IF
      ( terminate buffer & update )
      arg0 sha256-pad-buffer-head
      local1 arg0 sha256-update-step
      ( update w/ zeros and bit length )
      local1 64 0 fill
      arg0 sha256-pad-buffer-tail
      local1 arg0 sha256-update-step
    ELSE
      arg0 sha256-pad-buffer
      local1 arg0 sha256-update-step
    THEN
  ELSE
    ( with no buffer make a padding block and update )
    arg0 sha256-pad-buffer
    local1 arg0 sha256-update-step
  THEN
  0 arg0 sha256-state-buffer-size !
end

( todo what's the standard's way of doing rounds with partial blocks? )
def sha256-update-rounds ( byte-ptr length rounds state -- state )
  arg1 0 uint> UNLESS arg0 4 return1-n THEN
  arg1 1 - set-arg1
  arg3 arg2 arg0 sha256-update
  repeat-frame
end

def sha256-hash ( state -- hash-values )
  arg0 sha256-state-hash 1 return1-n
end

( String conversion and IO: )

def sha256->string/3 ( ptr size sha256-state -- ptr real-size )
  8 arg2 arg1 arg0 sha256-state-hash 0 hexdigest/5 3 return2-n
end

def write-sha256
  0 64 stack-allot-zero set-local0
  local0 64 arg0 sha256->string/3 write-string/2
  1 return0-n
end

def sha256-hash-string/3 ( out-str str len -- out-str n )
  0 0
  make-sha256-state set-local0
  local0 sha256-begin
  arg1 arg0 local0 sha256-update
  local0 sha256-end
  arg2 128 local0 sha256->string/3 set-local1
  arg2 128 3 return2-n
end

def sha256-hash-string ( str len ++ out-str n )
  128 stack-allot-zero arg1 arg0 sha256-hash-string/3
  over cell-size 2 * - move exit-frame
end

