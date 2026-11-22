#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-or-later
import datetime, json, os, sys

rel = sys.argv[1]
env = os.environ

path = os.path.join(rel, 'release-manifest.json')
m = json.load(open(path))
base = {'release_id': m['release_id'], 'build_number': m['android']['build_number']}
m['release_id'] = env['RELEASE_ID']
m['directory_name'] = env['DIRECTORY_NAME']
m['product_family'] = env['PRODUCT_FAMILY']
m['android']['build_number'] = int(env['BUILD_NUMBER'])
m['published_at_utc'] = datetime.datetime.now(datetime.timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
for entry in m['inventory']:
    entry['size'] = os.path.getsize(os.path.join(rel, entry['path']))
json.dump(m, open(path, 'w'), indent=2)
open(path, 'a').write('\n')

layout = json.load(open(os.path.join(rel, 'guest/partition-layout.json')))
prov = {
    'derived_from': {'release_id': base['release_id'], 'build_number': base['build_number'], 'kernarium_tag': env['KERNARIUM_TAG'], 'sha256': env['BASE_SHA256']},
    'rebuilt_partitions': env['REBUILD_PARTITIONS'].split(),
    'jit': env['KGOS_JIT'],
    'microg': {'gms': env['MICROG_GMS'], 'vending': env['MICROG_VENDING']},
    'system_disk_sha256': layout['system_disk']['sha256'],
}
json.dump(prov, open(os.path.join(rel, 'kgos-provenance.json'), 'w'), indent=2)
print(f"{m['release_id']} build {m['android']['build_number']} system disk {layout['system_disk']['size_bytes']} bytes")
