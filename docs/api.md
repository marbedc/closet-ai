# ClosetAI API

Base URL during local development:

```text
http://127.0.0.1:8000
```

The API currently supports the Week 1 prototype: checking that the backend is running, uploading a clothing item, and retrieving the items displayed in the wardrobe gallery.

## 1. Health check

```http
GET /health
```

Use this endpoint to verify that the FastAPI server is running.

### Response `200 OK`

```json
{
  "status": "ok"
}
```

## 2. Upload a clothing item

```http
POST /wardrobe
Content-Type: multipart/form-data
```

Uploads one clothing image and saves its basic metadata. The image field must be named `image`.

### Form fields

| Field | Type | Required | Description |
|---|---|---:|---|
| `image` | file | Yes | Clothing image, such as a JPG, JPEG, or PNG file. |
| `name` | string | No | User-provided name for the item. |
| `category` | string | No | Basic category, such as `shirt`, `pants`, `dress`, or `shoes`. |
| `color` | string | No | Main color of the item. |

### Example request

```bash
curl -X POST "http://127.0.0.1:8000/wardrobe" \
  -F "image=@shirt.jpg" \
  -F "name=Blue shirt" \
  -F "category=shirt" \
  -F "color=blue"
```

### Response `201 Created`

```json
{
  "id": "generated-item-id",
  "name": "Blue shirt",
  "category": "shirt",
  "color": "blue",
  "image_url": "/uploads/generated-file-name.jpg"
}
```

### Possible errors

| Status | Meaning |
|---:|---|
| `400` | The request is missing required information or the file type is unsupported. |
| `413` | The uploaded image is larger than the allowed file size. |
| `500` | The server could not save the item. |

## 3. List wardrobe items

```http
GET /wardrobe
```

Returns all clothing items saved in the current wardrobe. The frontend uses this endpoint to populate the wardrobe gallery.

### Response `200 OK`

```json
[
  {
    "id": "generated-item-id",
    "name": "Blue shirt",
    "category": "shirt",
    "color": "blue",
    "image_url": "/uploads/generated-file-name.jpg"
  }
]
```

If no items have been uploaded, the endpoint returns an empty array:

```json
[]
```

## Frontend integration

The React frontend should use the API base URL from an environment variable rather than repeating the URL throughout the code.

Example frontend environment file:

```text
VITE_API_URL=http://127.0.0.1:8000
```

Example requests from `frontend/src/services/api.js`:

```javascript
const API_URL = import.meta.env.VITE_API_URL;

export async function getWardrobeItems() {
  const response = await fetch(`${API_URL}/wardrobe`);

  if (!response.ok) {
    throw new Error("Could not load wardrobe items");
  }

  return response.json();
}

export async function uploadWardrobeItem(formData) {
  const response = await fetch(`${API_URL}/wardrobe`, {
    method: "POST",
    body: formData,
  });

  if (!response.ok) {
    throw new Error("Could not upload wardrobe item");
  }

  return response.json();
}
```

Do not manually set the `Content-Type` header when sending `FormData`; the browser adds the correct multipart boundary automatically.

## CORS

During local development, the backend must allow requests from the Vite development server:

```text
http://localhost:5173
```

The allowed frontend origin should be restricted to the real deployed frontend URL before production deployment.

## Week 1 acceptance criteria

- `GET /health` returns `{ "status": "ok" }`.
- A user can upload one clothing image from the React interface.
- The backend returns the newly created item with an ID and image URL.
- `GET /wardrobe` returns the saved items.
- The wardrobe gallery can display the returned item data.
- API keys and other secrets are not included in requests, source code, or GitHub commits.

