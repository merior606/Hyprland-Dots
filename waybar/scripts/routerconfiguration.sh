#!/bin/bash

gateway_ip=$(ip route | awk '/default/{print $3}')
arp_scan=$(arp-scan --localnet | tail -n +3 | head -n -3)

html_file="/tmp/arp_scan.html"

cat > "$html_file" <<EOF
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>ARP Scan</title>
<style>
body {
  background: #1e1e2e;
  color: #cdd6f4;
  font-family: monospace;
  padding: 1em;
}
pre {
  white-space: pre-wrap;
}
</style>
</head>
<body>
<h2>Gateway: $gateway_ip</h2>
<pre>
$arp_scan
</pre>
</body>
</html>
EOF

firefox $gateway_ip &&
firefox "file://$html_file" 