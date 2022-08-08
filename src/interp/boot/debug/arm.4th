( ARM control registers: )

def print-fpscr-bit ( reg-value bit name-str name-len -- )
  arg3 arg2 bit-set? IF arg1 arg0 ELSE s" _" THEN write-string/2
  4 return0-n
end

def print-fpscr/1
  arg0 dup write-hex-uint
  nl s" Cond: " write-string/2
  dup 31 s" N" print-fpscr-bit
  dup 30 s" Z" print-fpscr-bit
  dup 29 s" C" print-fpscr-bit
  dup 28 s" V" print-fpscr-bit
  nl s" Flush to zero: " write-string/2
  dup 24 s" FZ" print-fpscr-bit space
  nl s" Rounding: " write-string/2  
  dup 21 bsr 0x3 logand write-hex-uint space
  nl s" Vstride: " write-string/2  
  dup 19 bsr 0x3 logand write-hex-uint space
  nl s" Vlen: " write-string/2
  dup 16 bsr 0x7 logand write-hex-uint space
  nl s" Trap: " write-string/2
  dup 12 s" IX " print-fpscr-bit
  dup 11 s" UF " print-fpscr-bit
  dup 10 s" OF " print-fpscr-bit
  dup 9 s" DZ " print-fpscr-bit
  dup 8 s" IO " print-fpscr-bit
  nl s" Cumalative: " write-string/2
  dup 4 s" IX " print-fpscr-bit
  dup 3 s" UF " print-fpscr-bit
  dup 2 s" OF " print-fpscr-bit
  dup 1 s" DZ " print-fpscr-bit
  dup 0 s" IO " print-fpscr-bit
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
