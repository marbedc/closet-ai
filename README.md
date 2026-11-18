# ClosetAI

ClosetAI is a multimodal wardrobe and outfit recommendation assistant. Users can upload clothing photos, confirm or edit the detected clothing labels, and request outfit recommendations based on their wardrobe, preferences, occasion, and budget.

The project is being developed as a three-person capstone for CSC 603/803 Generative AI.

## Project goals

The prototype will:

- Create a digital wardrobe from uploaded clothing photos.
- Detect clothing attributes such as category, color, pattern, and formality.
- Allow users to correct labels before saving an item.
- Generate two or three outfit options for casual, class, interview, and party occasions.
- Use only valid wardrobe item IDs when recommending owned clothing.
- Provide optional shopping recommendations from a curated catalog.
- Evaluate the agent workflow against a single large-language-model response.
- Collect feedback from approximately five volunteers.

Virtual try-on and broad live retailer searches are outside the core prototype scope.

## Team responsibilities

| Team member | Primary responsibilities |
|---|---|
| Lylia Melahi | Image uploads, image labeling, wardrobe database, and data preparation |
| J.J. Gonzalez | Stylist Agent, LangGraph workflow, wardrobe tools, and output validation |
| Marbella Carrasco | React interface, Shopping Agent, product catalog, frontend-backend integration, documentation, and demonstration coordination |

All team members contribute to evaluation, debugging, code reviews, the final report, presentation slides, and the final demonstration.

## Technology stack

- **Frontend:** React with Vite
- **Backend:** Python FastAPI
- **Database:** SQLite
- **AI model:** Gemini multimodal API
- **Agent framework:** LangGraph
- **Version control:** Git and GitHub
- **Image storage:** Local files during development; SQLite stores image paths and metadata

## Project structure

```text
closet-ai/
├── backend/
│   ├── app/
│   │   ├── main.py
│   │   ├── database.py
│   │   ├── models.py
│   │   ├── schemas.py
│   │   └── routes/
│   └── tests/
├── frontend/
├── data/
│   ├── catalog.csv
│   └── README.md
├── docs/
│   ├── architecture.md
│   ├── api.md
│   └── test-cases.md
├── .env.example
├── .gitignore
└── README.md
```

## Requirements

Install the following before setting up the project:

- Git
- Python 3.11 or a compatible current Python version
- Node.js and npm
- A Gemini API key

## Clone the repository

```bash
git clone YOUR_GITHUB_REPOSITORY_URL
cd closet-ai
```

## Backend setup

From the project root, create and activate a Python virtual environment:

### Windows PowerShell

```powershell
cd backend
py -m venv .venv
.venv\Scripts\Activate.ps1
pip install "fastapi[standard]" python-multipart python-dotenv google-genai langgraph
```

### macOS or Linux

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install "fastapi[standard]" python-multipart python-dotenv google-genai langgraph
```

Start the backend development server:

```bash
fastapi dev app/main.py
```

The backend should be available at:

```text
http://127.0.0.1:8000
```

FastAPI automatically provides interactive API documentation at:

```text
http://127.0.0.1:8000/docs
```

## Frontend setup

Open a second terminal from the project root:

```bash
cd frontend
npm install
npm run dev
```

The frontend should be available at:

```text
http://localhost:5173
```

## Environment variables

Create a local `.env` file based on `.env.example`:

```text
GEMINI_API_KEY=your_api_key_here
GEMINI_MODEL=your_selected_model
```

Never commit `.env`, API keys, private clothing photos, or other sensitive information to GitHub.

The Gemini API key must be used by the backend only. It should not be placed in React code or exposed in the browser.

## Week 1 acceptance test

The first milestone is complete when the following workflow works:

1. The user selects one clothing image.
2. React sends the image to the FastAPI backend.
3. The backend assigns the image a unique item ID.
4. The backend saves the image separately from the database.
5. The backend returns basic clothing metadata.
6. React displays the uploaded item in the wardrobe gallery.

The initial health check is:

```text
GET /health
```

Expected response:

```json
{
  "status": "ok"
}
```

The initial upload endpoint is:

```text
POST /wardrobe/upload
```

## Planned API endpoints

```text
POST   /wardrobe/upload
GET    /wardrobe/items
GET    /wardrobe/items/{item_id}
PUT    /wardrobe/items/{item_id}
DELETE /wardrobe/items/{item_id}

POST   /recommendations/outfits
POST   /recommendations/shopping

POST   /outfits/{outfit_id}/rating
```

The backend must validate all returned wardrobe and catalog IDs. The application must not display an item or product that does not exist in the database or curated catalog.

## Database overview

The database will contain information for:

- Users and preferences
- Clothing items and AI-generated or user-corrected labels
- Outfit recommendations
- Saved outfits
- Catalog products
- Shopping recommendations
- User ratings and feedback

Images are stored as files or URLs. The database stores the related image path, item ID, and metadata rather than storing image data directly in SQLite.

## Product catalog format

Each catalog product should include:

```text
product_id
name
category
color
style
price
url
date_checked
```

Prices are recorded values. Users should verify current price and availability on the retailer's website.

## GitHub workflow

The `main` branch is the stable branch. Team members should not commit directly to `main`.

Create a feature branch for each task:

```bash
git checkout main
git pull origin main
git checkout -b feature/short-description
```

After completing the task:

```bash
git status
git add .
git commit -m "Describe the change"
git push -u origin feature/short-description
```

Then open a pull request into `main`.

Every pull request should include:

- A description of what changed
- Instructions for testing the change
- Any known limitations
- Confirmation that no API keys or private data were added
- At least one teammate review before merging

## GitHub milestones

1. **Foundation** - Repository, setup, architecture, and API connection
2. **Wardrobe** - Uploads, labels, database, editing, and gallery
3. **Stylist Agent** - LangGraph workflow, wardrobe tools, and outfit cards
4. **Shopping and Evaluation** - Product catalog, Shopping Agent, ratings, and baseline comparison
5. **Final Delivery** - Testing, report, slides, documentation, and demonstration

## Evaluation plan

The project will evaluate:

- Category and color-label accuracy against manual labels
- Whether displayed item references are valid
- Compliance with explicit preferences and budget constraints
- Response time
- API usage
- Volunteer ratings for occasion suitability and usefulness

The agent workflow will be compared with a single LLM call using the same wardrobe metadata, preferences, and product catalog.

## Safety and privacy

- Keep API keys on the backend.
- Do not commit `.env` files.
- Use clothing-only photos for volunteer testing.
- Obtain permission before using volunteer images.
- Allow participants to request deletion of their photos.
- Do not claim that prices or product availability are current unless they have been checked.
- Show API failures visibly instead of silently returning fabricated results.

## Development resources

- [React documentation](https://react.dev/)
- [Vite documentation](https://vite.dev/guide/)
- [FastAPI documentation](https://fastapi.tiangolo.com/)
- [Google Gemini API documentation](https://ai.google.dev/gemini-api/docs)
- [LangGraph documentation](https://docs.langchain.com/oss/python/langgraph/)
