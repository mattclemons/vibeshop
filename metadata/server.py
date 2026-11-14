#!/usr/bin/env python3
"""Tiny EC2-ish metadata mock. Binds the aliased link-local address on the host.

Reports the source IP it saw so a test can prove the server made the request.
"""
import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

BIND = ("169.254.169.254", 80)

ROLE = "vibeshop-app"
CREDS = {
    "Code": "Success",
    "LastUpdated": "2026-01-01T00:00:00Z",
    "Type": "AWS-HMAC",
    "AccessKeyId": "AKIAJUNKJUNKJUNKJUNK",
    "SecretAccessKey": "junksecretjunksecretjunksecretjunksecret",
    "Token": "junk-session-token",
    "Expiration": "2030-01-01T00:00:00Z",
}

PATHS = {
    "/latest/meta-data/": "\n".join([
        "ami-id", "hostname", "instance-id", "instance-type", "local-ipv4",
    ]) + "\n",
    "/latest/meta-data/hostname": "vibeshop-prod.internal\n",
    "/latest/meta-data/instance-id": "i-0junk1234567890\n",
    "/latest/meta-data/local-ipv4": "10.3.10.137\n",
    "/latest/meta-data/iam/security-credentials/": ROLE + "\n",
    "/latest/meta-data/iam/security-credentials/" + ROLE: json.dumps(CREDS, indent=2) + "\n",
    "/latest/meta-data/iam/info": json.dumps(
        {"InstanceProfileArn": "arn:aws:iam::000000000000:instance-profile/vibeshop"}),
    "/latest/user-data": "#!/bin/sh\necho vibeshop\n",
}

class H(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def _send(self, code, body, ctype="text/plain"):
        raw = body.encode()
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(raw)))
        self.send_header("X-Seen-From", self.client_address[0])
        self.end_headers()
        self.wfile.write(raw)

    def do_GET(self):
        p = self.path.split("?")[0]
        if p == "/latest/meta-data/seen-from":
            return self._send(200, self.client_address[0] + "\n")
        if p in PATHS:
            return self._send(200, PATHS[p])
        if p == "/":
            return self._send(200, "metadata-mock\n")
        self._send(404, "not found\n")

    def log_message(self, fmt, *args):
        print("metadata %s %s" % (self.client_address[0], self.path), flush=True)

if __name__ == "__main__":
    print("metadata mock on %s:%d" % BIND, flush=True)
    ThreadingHTTPServer(BIND, H).serve_forever()
