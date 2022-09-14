def host-little-endian?
  0x12345678 here peek-byte 0x78 equals? return1
end
