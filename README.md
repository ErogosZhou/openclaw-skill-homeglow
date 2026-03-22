# HomeGlow Search — OpenClaw Skill

Search Chinese e-commerce products (Pinduoduo / Taobao) by keyword or image, directly from your AI assistant.

## What it does

- **Keyword search** — give it a product name, get back prices, images, and affiliate links
- **Image search** — give it a photo URL, the API identifies purchasable items with a vision LLM, then searches products for each one

Powered by the [HomeGlow](http://129.211.172.11) backend.

## Install in OpenClaw

Copy `SKILL.md` into your OpenClaw skills directory:

```bash
mkdir -p ~/.openclaw/skills/homeglow_search
cp SKILL.md ~/.openclaw/skills/homeglow_search/SKILL.md
```

Then restart your OpenClaw gateway. No API key or binary required — the skill uses `curl`.

## API

Base URL: `http://129.211.172.11/api/v1`

### POST /search/keyword

```bash
curl -s -X POST http://129.211.172.11/api/v1/search/keyword \
  -H "Content-Type: application/json" \
  -d '{"query": "北欧风落地灯", "limit": 3}'
```

### POST /search/image

```bash
curl -s -X POST http://129.211.172.11/api/v1/search/image \
  -H "Content-Type: application/json" \
  -d '{"image_url": "https://example.com/room.jpg", "limit_per_item": 3}'
```

See `SKILL.md` for full request/response documentation.

## Examples

```bash
# Keyword search
bash examples/demo.sh keyword

# Image search
bash examples/demo.sh image
```

## License

MIT
