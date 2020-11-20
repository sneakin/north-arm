( ARM control registers: )

def print-fpscr/1
  arg0 dup write-hex-uint
  nl s" Cond: " write-string/2
  dup 31 bit-set? IF s" N" ELSE s" _" THEN write-string/2
  dup 30 bit-set? IF s" Z" ELSE s" _" THEN write-string/2
  dup 29 bit-set? IF s" C" ELSE s" _" THEN write-string/2
  dup 28 bit-set? IF s" V" ELSE s" _" THEN write-string/2
  nl s" Flush to zero: " write-string/2
  dup 24 bit-set? IF s" FZ" ELSE s" _" THEN write-string/2 space
  nl s" Rounding: " write-string/2  
  dup 21 bsr 0x3 logand write-hex-uint space
  nl s" Vstride: " write-string/2  
  dup 19 bsr 0x3 logand write-hex-uint space
  nl s" Vlen: " write-string/2
  dup 16 bsr 0x7 logand write-hex-uint space
  nl s" Trap: " write-string/2
  dup 12 bit-set? IF s" IX " ELSE s" _" THEN write-string/2
  dup 11 bit-set? IF s" UF " ELSE s" _" THEN write-string/2
  dup 10 bit-set? IF s" OF " ELSE s" _" THEN write-string/2
  dup 9 bit-set? IF s" DZ " ELSE s" _" THEN write-string/2
  dup 8 bit-set? IF s" IO " ELSE s" _" THEN write-string/2
  nl s" Cumalative: " write-string/2
  dup 4 bit-set? IF s" IX " ELSE s" _" THEN write-string/2
  dup 3 bit-set? IF s" UF " ELSE s" _" THEN write-string/2
  dup 2 bit-set? IF s" OF " ELSE s" _" THEN write-string/2
  dup 1 bit-set? IF s" DZ " ELSE s" _" THEN write-string/2
  dup 0 bit-set? IF s" IO " ELSE s" _" THEN write-string/2
  nl
end

def print-fpscr
  vfpscr print-fpscr/1
end

( HWCAP print out: )

def print-bitfield-bit
  arg1 arg0 exec-abs bit-set? IF
    arg0 dict-entry-name peek cs + write-string space
  THEN
end

def print-hwcaps
  AT-HWCAP get-auxvec dup write-hex-uint space
  AT-HWCAP2 get-auxvec dup write-hex-uint nl
  local0 ' HWCAP-FP print-bitfield-bit
  local0 ' HWCAP-ASIMD print-bitfield-bit
  local0 ' HWCAP-EVTSTRM print-bitfield-bit
  local0 ' HWCAP-AES print-bitfield-bit
  local0 ' HWCAP-PMULL print-bitfield-bit
  local0 ' HWCAP-SHA1 print-bitfield-bit
  local0 ' HWCAP-SHA2 print-bitfield-bit
  local0 ' HWCAP-CRC32 print-bitfield-bit
  local0 ' HWCAP-ATOMICS print-bitfield-bit
  local0 ' HWCAP-FPHP print-bitfield-bit
  local0 ' HWCAP-ASIMDHP print-bitfield-bit
  local0 ' HWCAP-CPUID print-bitfield-bit
  local0 ' HWCAP-ASIMDRDM print-bitfield-bit
  local0 ' HWCAP-JSCVT print-bitfield-bit
  local0 ' HWCAP-FCMA print-bitfield-bit
  local0 ' HWCAP-LRCPC print-bitfield-bit
  local0 ' HWCAP-DCPOP print-bitfield-bit
  local0 ' HWCAP-SHA3 print-bitfield-bit
  local0 ' HWCAP-SM3 print-bitfield-bit
  local0 ' HWCAP-SM4 print-bitfield-bit
  local0 ' HWCAP-ASIMDDP print-bitfield-bit
  local0 ' HWCAP-SHA512 print-bitfield-bit
  local0 ' HWCAP-SVE print-bitfield-bit
  local0 ' HWCAP-ASIMDFHM print-bitfield-bit
  local0 ' HWCAP-DIT print-bitfield-bit
  local0 ' HWCAP-USCAT print-bitfield-bit
  local0 ' HWCAP-ILRCPC print-bitfield-bit
  local0 ' HWCAP-FLAGM print-bitfield-bit
  local0 ' HWCAP-SSBS print-bitfield-bit
  local0 ' HWCAP-SB print-bitfield-bit
  local0 ' HWCAP-PACA print-bitfield-bit
  local0 ' HWCAP-PACG print-bitfield-bit
  nl
  local1 ' HWCAP2-DCPODP print-bitfield-bit
  local1 ' HWCAP2-SVE2 print-bitfield-bit
  local1 ' HWCAP2-SVEAES print-bitfield-bit
  local1 ' HWCAP2-SVEPMULL print-bitfield-bit
  local1 ' HWCAP2-SVEBITPERM print-bitfield-bit
  local1 ' HWCAP2-SVESHA3 print-bitfield-bit
  local1 ' HWCAP2-SVESM4 print-bitfield-bit
  local1 ' HWCAP2-FLAGM2 print-bitfield-bit
  local1 ' HWCAP2-FRINT print-bitfield-bit
  nl
end
