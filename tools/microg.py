#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-or-later
import argparse, hashlib, sys, zipfile

from loguru import logger
logger.remove()
from androguard.core.apk import APK

PRIVILEGED = 0x10

ap = argparse.ArgumentParser()
ap.add_argument('--ref', required=True)
ap.add_argument('--cert-sha256', required=True)
ap.add_argument('--privapp-xml', required=True)
ap.add_argument('apks', nargs='+')
args = ap.parse_args()

services = zipfile.ZipFile(f'{args.ref}/services.jar')
dex = b''.join(services.read(n) for n in services.namelist() if n.endswith('.dex'))

levels = {}
for res in ('framework-res.apk', 'org.lineageos.platform-res.apk'):
    for name, d in APK(f'{args.ref}/{res}').get_declared_permissions_details().items():
        try:
            levels[name] = int(d.get('protectionLevel') or '0', 16)
        except ValueError:
            levels[name] = 0

lines = ['<?xml version="1.0" encoding="utf-8"?>', '<!-- SPDX-License-Identifier: Apache-2.0 -->', '<permissions>']
for path in args.apks:
    apk = APK(path)
    certs = apk.get_certificates()
    if len(certs) != 1 or hashlib.sha256(certs[0].dump()).hexdigest() != args.cert_sha256:
        sys.exit(f'{path}: not signed with the microG release key')
    if certs[0].dump().hex().encode() not in dex:
        sys.exit(f'{path}: services.jar does not trust this certificate for signature spoofing')
    perms = sorted(p for p in set(apk.get_permissions()) if levels.get(p, 0) & PRIVILEGED)
    lines.append(f'    <privapp-permissions package="{apk.get_package()}">')
    lines += [f'        <permission name="{p}" />' for p in perms]
    lines.append('    </privapp-permissions>')
    print(f'{apk.get_package()} {apk.get_androidversion_name()}: {len(perms)} privileged permissions')
lines.append('</permissions>')
with open(args.privapp_xml, 'w') as f:
    f.write('\n'.join(lines) + '\n')
