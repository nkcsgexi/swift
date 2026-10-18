#!/usr/bin/env python3

# Overwrite the uint32 owner name length of the first Objective-C method
# recorded for a selector in a .swiftmodule file with an out of range value.

import struct
import sys

(_, path, key) = sys.argv
key = key.encode('utf-8')

with open(path, 'rb') as f:
    data = bytearray(f.read())

# Hash table entry layout: [uint16 keyLength][uint32 dataLength][key]
# followed by records of [uint32 ownerLen][uint8 isInstanceMethod]
# [uint32 methodID][ownerLen bytes].
index = data.find(key)
while index != -1:
    (keyLength, dataLength) = struct.unpack_from('<HI', data, index - 6)
    if keyLength == len(key) and dataLength >= 9:
        break
    index = data.find(key, index + 1)
assert index != -1, 'objc method table entry not found'
offset = index + len(key)
(ownerLen,) = struct.unpack_from('<I', data, offset)
assert 0 < ownerLen <= dataLength - 9, 'unexpected owner name length'
struct.pack_into('<I', data, offset, 0xFFFFFFF0)

with open(path, 'wb') as f:
    f.write(data)
