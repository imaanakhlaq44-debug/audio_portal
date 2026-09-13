"""Local dev helper: serves ./build/web (or the repo root) on :5060 with CORS
and framing headers relaxed, so a `flutter build web` output can be previewed
inside an iframe.

DEVELOPMENT ONLY -- these headers disable clickjacking protection and the
server binds 0.0.0.0. Do not use it to host anything publicly.

    python tools/dev_server.py
"""

import http.server, socketserver
class H(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('X-Frame-Options', 'ALLOWALL')
        self.send_header('Content-Security-Policy', 'frame-ancestors *')
        self.send_header('Cache-Control', 'no-cache')
        super().end_headers()
    def log_message(self, *a): pass
socketserver.TCPServer.allow_reuse_address = True
with socketserver.TCPServer(('0.0.0.0', 5060), H) as httpd:
    httpd.serve_forever()
