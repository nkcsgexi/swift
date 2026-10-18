#!/usr/bin/env python3

# Overwrite the uint32 length prefix of the first occurrence of a brief
# comment string in a .swiftdoc file with an out of range value.

import struct
import sys

(_, path, text) = sys.argv
text = text.encode('utf-8')

with open(path, 'rb') as f:
    data = bytearray(f.read())

index = data.find(text)
assert index >= 4, 'brief comment not found'
(length,) = struct.unpack_from('<I', data, index - 4)
assert length == len(text), 'unexpected length prefix'
struct.pack_into('<I', data, index - 4, 0xFFFFFFF0)

with open(path, 'wb') as f:
    f.write(data)
