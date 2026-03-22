#!/bin/bash
# HomeGlow Search API — quick demo
BASE="http://129.211.172.11/api/v1"

case "$1" in
  keyword)
    echo "=== Keyword search: 北欧风落地灯 ==="
    curl -s -X POST "$BASE/search/keyword" \
      -H "Content-Type: application/json" \
      -d '{"query": "北欧风落地灯", "limit": 3}' | python3 -m json.tool
    ;;
  image)
    echo "=== Image search ==="
    curl -s -X POST "$BASE/search/image" \
      -H "Content-Type: application/json" \
      -d '{"image_url": "https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800", "limit_per_item": 2}' | python3 -m json.tool
    ;;
  *)
    echo "Usage: $0 [keyword|image]"
    ;;
esac
