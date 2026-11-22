#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-or-later
import hashlib, os, stat, sys

def scan(root):
    out = {}
    for d, dirs, files in os.walk(root):
        for n in dirs + files:
            p = os.path.join(d, n)
            rel = os.path.relpath(p, root)
            st = os.lstat(p)
            xa = tuple(sorted((k, os.getxattr(p, k, follow_symlinks=False)) for k in os.listxattr(p, follow_symlinks=False)))
            if stat.S_ISLNK(st.st_mode):
                body = os.readlink(p)
            elif stat.S_ISREG(st.st_mode):
                h = hashlib.sha256()
                with open(p, 'rb') as f:
                    for b in iter(lambda: f.read(1 << 20), b''):
                        h.update(b)
                body = h.hexdigest()
            else:
                body = None
            out[rel] = (stat.S_IFMT(st.st_mode), stat.S_IMODE(st.st_mode), st.st_uid, st.st_gid, xa, body)
    return out

a, b = scan(sys.argv[1]), scan(sys.argv[2])
changed = sorted(k for k in a.keys() & b.keys() if a[k] != b[k])
for k in sorted(a.keys() - b.keys()):
    print('-', k)
for k in sorted(b.keys() - a.keys()):
    print('+', k)
for k in changed:
    fields = [n for n, x, y in zip(('type', 'mode', 'uid', 'gid', 'xattr', 'content'), a[k], b[k]) if x != y]
    print('~', k, ','.join(fields))
print(f'# {len(a)} vs {len(b)} entries, {len(changed)} changed', file=sys.stderr)
