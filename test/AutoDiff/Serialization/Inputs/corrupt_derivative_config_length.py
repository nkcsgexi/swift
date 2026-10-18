#!/usr/bin/env python3

# Overwrite the int32 parameter indices length of the first derivative
# function configuration recorded for a mangled name in a .swiftmodule file
# with an out of range value.

import struct
import sys

(_, path, key) = sys.argv
key = key.encode('utf-8')

with open(path, 'rb') as f:
    data = bytearray(f.read())

# Hash table entry layout: [uint16 keyLength][uint16 dataLength][key]
# followed by records of [uint32 genSigID][int32 length][length bytes].
index = data.find(key)
while index != -1:
    (keyLength, dataLength) = struct.unpack_from('<HH', data, index - 4)
    if keyLength == len(key) and dataLength >= 8:
        break
    index = data.find(key, index + 1)
assert index != -1, 'derivative function configuration not found'
offset = index + len(key) + 4
(length,) = struct.unpack_from('<i', data, offset)
assert 0 < length <= dataLength - 8, 'unexpected length'
struct.pack_into('<i', data, offset, 0x7FFFFFF0)

with open(path, 'wb') as f:
    f.write(data)
