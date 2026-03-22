---
name: homeglow_search
description: Search products from Chinese e-commerce platforms (Pinduoduo, Taobao) by keyword or by identifying items in an image. Use this when the user wants to find, compare, or buy products — especially home goods, decor, or anything visible in a photo.
homepage: https://huanxinjia.site
metadata: {"openclaw":{"emoji":"🛍️","requires":{"bins":["curl"]}}}
---

# HomeGlow Product Search

Search Chinese e-commerce products by keyword or by image.

Base URL: `https://huanxinjia.site/api/v1`

## When to Use

- User asks to find / buy / compare products
- User shares an image and wants to know where to buy what's in it
- User wants price info for Chinese e-commerce

## When NOT to Use

- User wants international (Amazon, eBay) products — this API covers CN platforms only
- User asks for inventory, order status, or seller info

---

## 1. Keyword Search

`POST /search/keyword`

Search by a text query. Returns products with prices and purchase links.

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
| `query` | ✅ | Main search string, e.g. `"白色简约地毯"` |
| `keywords` | ❌ | Extra keywords to improve matching |
| `category` | ❌ | Hint: `灯具` / `纺织品` / `绿植` / `收纳用品` / `墙面装饰` / `桌面摆件` |
| `limit` | ❌ | 1–20, default 5 |

**Response shape:**

```json
{
  "query": "北欧风落地灯",
  "total": 5,
  "products": [
    {
      "id": "abc123",
      "name": "北欧简约落地灯客厅卧室",
      "price": 129.0,
      "original_price": 299.0,
      "image_url": "https://...",
      "shop_name": "某某灯具旗舰店",
      "sales": 3200,
      "product_url": "https://...",
      "platform": "pdd"
    }
  ]
}
```

**Tips:**
- Use Chinese keywords for best results (the platforms are CN-only)
- Include style / color in `query` for more relevant results, e.g. `"白色北欧风收纳盒"`

---

## 2. Image-based Identify + Search

`POST /search/image`

Give it a publicly reachable image URL. The API uses a vision LLM to identify purchasable items, then searches products for each one.

```bash
curl -s -X POST https://huanxinjia.site/api/v1/search/image \
  -H "Content-Type: application/json" \
  -d '{
    "image_url": "https://example.com/room.jpg",
    "limit_per_item": 3
  }'
```

With before/after diff (only new items identified):

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
| `original_image_url` | ❌ | Before-photo; if set, only newly added items are identified |
| `limit_per_item` | ❌ | Products per item, 1–10, default 3 |

**Response shape:**

```json
{
  "total_items": 2,
  "items": [
    {
      "name": "编织地毯",
      "category": "纺织品",
      "description": "米色编织纹理，北欧风，适合客厅",
      "color": "米色",
      "style": "北欧",
      "price_estimate": "200-500元",
      "search_keywords": ["北欧地毯", "编织地毯", "客厅地毯"],
      "products": [
        {
          "id": "xyz789",
          "name": "北欧编织地毯客厅茶几毯",
          "price": 239.0,
          "image_url": "https://...",
          "product_url": "https://...",
          "platform": "pdd"
        }
      ]
    }
  ]
}
```

**Tips:**
- Image must be publicly accessible (not behind auth / WeChat / local paths)
- Works best on room photos with clearly visible furniture or decor items
- For single-item product images, `original_image_url` is not needed

---

## Presenting Results to Users

Always show:
1. Product name + price
2. `product_url` as the purchase link
3. Brief platform note: `pdd` = 拼多多, `taobao` = 淘宝

Example response to user:

> 找到以下商品：
>
> 1. **北欧编织地毯** — ¥239 [立即购买](product_url) (拼多多，3200+已售)
> 2. **简约棉麻地毯** — ¥189 [立即购买](product_url) (拼多多，1800+已售)

---

## Error Handling

| HTTP status | Meaning | What to do |
|-------------|---------|------------|
| 503 | E-commerce API not configured | Tell user platform search is unavailable |
| 500 | Vision API failed (image endpoint) | Ask user to try a different image |
| 400 | Bad request / image not reachable | Check image URL is public |

On 503/500, fall back to keyword search if possible.
