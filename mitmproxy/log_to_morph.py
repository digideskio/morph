# Run this with dotenv mitmdump -q -s mitmproxy/log_to_morph.py

import urllib
import os
from libmproxy.script import concurrent

@concurrent
def response(context, flow):
  url = os.environ['MORPH_URL'] + "/connection_logs"
  params = urllib.urlencode({
  	'ip_address': flow.request.client_conn.address[0],
  	'method': flow.request.method,
  	'scheme': flow.request.scheme,
    'host': flow.request.host,
    'path': flow.request.path,
    'request_size': len(flow.request.content),
    'response_size': len(flow.response.content),
    'key': os.environ['MITMPROXY_SECRET']
  })
  try:
    urllib.urlopen(url, params)
  # If we can't contact the morph server still handle this request.
  # If we let this exception pass up the chain the request would get dropped
  except IOError, e:
    print "Error contacting Morph server:", e