#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-or-later
import hashlib, json, os, sys

layout, disk, out = sys.argv[1:4]
os.makedirs(out, exist_ok=True)
with open(layout) as f:
    parts = json.load(f)['system_disk']['partitions']
with open(disk, 'rb') as d:
    for p in parts:
        d.seek(p['start_bytes'])
        left, h = p['image_bytes'], hashlib.sha256()
        with open(os.path.join(out, p['name'] + '.img'), 'wb') as o:
            while left:
                b = d.read(min(left, 1 << 22))
                h.update(b)
                o.write(b)
                left -= len(b)
        if h.hexdigest() != p['sha256']:
            sys.exit(f"{p['name']}: sha256 mismatch")
        print(f"{p['name']}: {p['image_bytes']} bytes ok")
