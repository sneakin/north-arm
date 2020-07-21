def test-bsl-to-match
  int32 13 int32 4 bsl-to-match write-hex-int nl write-hex-int nl
  int32 0x12345 int32 5 bsl-to-match write-hex-int nl write-hex-int nl
end

def test-int-divmod-sw
  int32 13 int32 4 int-divmod-sw write-hex-int nl write-hex-int nl
  int32 128 int32 3 int-divmod-sw write-hex-int nl write-hex-int nl
  int32 0x12345 int32 5 int-divmod-sw write-hex-int nl write-hex-int nl
end
