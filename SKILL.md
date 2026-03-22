---
name: homeglow_search
description: Search products from Chinese e-commerce platforms (Pinduoduo, Taobao) by keyword or by identifying items in an image. Use this when the user wants to find, compare, or buy products — especially home goods, decor, or anything visible in a photo.
homepage: https://huanxinjia.site
metadata: {"openclaw":{"emoji":"🛍️","requires":{"bins":["curl"]}}}
---

# HomeGlow Product Search

Search Chinese e-commerce products by keyword or image, then generate a shareable card image the user can scan to buy.

Base URL: `https://huanxinjia.site/api/v1`

## When to Use

- User asks to find / buy / compare products
- User shares an image and wants to know where to buy what's in it
- User wants product recommendations on Chinese e-commerce platforms

## When NOT to Use

- User wants international (Amazon, eBay) products — CN platforms only
- User asks for order status or seller info

---

## Workflow: always two steps

**Step 1 — search** to get a product list
**Step 2 — generate a card** for the best match and send the image to the user

Never skip Step 2. In WeChat and similar environments plain URLs don't work — always send the card image.

---

## Step 1: Keyword Search

`POST /search/keyword`

```bash
curl -s -X POST https://huanxinjia.site/api/v1/search/keyword \
  -H "Content-Type: application/json" \
  -d '{
    "query": "北欧风落地灯",
    "keywords": ["落地灯", "客厅灯"],
    "category": "灯具",
    "limit": 5
  }'
```

**Request fields:**

| Field | Required | Description |
|-------|----------|-------------|
| `query` | ✅ | Main search string — use Chinese for best results |
| `keywords` | ❌ | Extra keywords to improve matching |
| `category` | ❌ | `灯具` / `纺织品` / `绿植` / `收纳用品` / `墙面装饰` / `桌面摆件` |
| `limit` | ❌ | 1–20, default 5 |

**Response — pick the best product, then go to Step 2:**

```json
{
  "query": "北欧风落地灯",
  "total": 5,
  "products": [
    {
      "id": "E9X2_xxx",
      "name": "氛围灯落地灯简约北欧立式台灯",
      "price": 13.49,
      "original_price": 199.0,
      "image_url": "https://img.pddpic.com/...",
      "shop_name": "某某灯具店",
      "sales": 35000,
      "platform": "pdd"
    }
  ]
}
```

---

## Step 1 (alternative): Image Identify + Search

`POST /search/image`

Give it a room photo; the API identifies purchasable items and searches products for each.

```bash
curl -s -X POST https://huanxinjia.site/api/v1/search/image \
  -H "Content-Type: application/json" \
  -d '{
    "image_url": "https://example.com/room.jpg",
    "limit_per_item": 3
  }'
```

With before/after comparison (only newly added items identified):

```bash
curl -s -X POST https://huanxinjia.site/api/v1/search/image \
  -H "Content-Type: application/json" \
  -d '{
    "image_url": "https://example.com/after.jpg",
    "original_image_url": "https://example.com/before.jpg",
    "limit_per_item": 3
  }'
```

**Request fields:**

| Field | Required | Description |
|-------|----------|-------------|
| `image_url` | ✅ | Publicly reachable JPEG / PNG / WebP URL |
| `original_image_url` | ❌ | Before-photo for diff; only new items are identified |
| `limit_per_item` | ❌ | Products per item, 1–10, default 3 |

Response has the same product structure as keyword search, nested under each identified item.

---

## Step 2: Generate Product Card

`POST /search/card`

Takes one product from the search results, generates a card image (product photo + price + QR code).
Returns a `card_url` — **send this image URL directly to the user**.

```bash
curl -s -X POST https://huanxinjia.site/api/v1/search/card \
  -H "Content-Type: application/json" \
  -d '{
    "goods_sign": "<product.id from Step 1>",
    "product_name": "<product.name>",
    "price": 13.49,
    "original_price": 199.0,
    "image_url": "<product.image_url>",
    "platform": "pdd"
  }'
```

**Request fields — all come from a product in Step 1:**

| Field | Required | Source |
|-------|----------|--------|
| `goods_sign` | ✅ | `product.id` |
| `product_name` | ✅ | `product.name` |
| `price` | ✅ | `product.price` |
| `original_price` | ❌ | `product.original_price` |
| `image_url` | ✅ | `product.image_url` |
| `platform` | ❌ | `product.platform` (default `pdd`) |

**Response:**

```json
{
  "card_url": "https://huanxinjia.site/uploads/card_abc123.jpg"
}
```

**Send this to the user:**

> 为您找到这款商品，扫描图中二维码即可购买：
> [card_url image]

---

## Error Handling

| HTTP status | Meaning | What to do |
|-------------|---------|------------|
| 503 | E-commerce API not configured | Tell user search is unavailable |
| 500 | Vision or card generation failed | Try keyword search instead |
| 400 | Image URL not reachable | Ask user for a public image URL |
