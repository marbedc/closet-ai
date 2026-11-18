PRAGMA foreign_keys = ON;

-- =========================================
-- USERS
-- =========================================

CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    email TEXT UNIQUE,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =========================================
-- USER PREFERENCES
-- =========================================

CREATE TABLE IF NOT EXISTS user_preferences (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL UNIQUE,

    preferred_styles TEXT,
    preferred_colors TEXT,
    disliked_colors TEXT,
    preferred_brands TEXT,
    preferred_fit TEXT,
    default_formality INTEGER CHECK (
        default_formality IS NULL OR
        default_formality BETWEEN 1 AND 5
    ),

    budget_min REAL CHECK (budget_min IS NULL OR budget_min >= 0),
    budget_max REAL CHECK (budget_max IS NULL OR budget_max >= budget_min),

    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);

-- =========================================
-- LOOKUP TABLES
-- =========================================

CREATE TABLE IF NOT EXISTS categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS colors (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS patterns (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS seasons (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS occasions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
);

-- =========================================
-- CLOTHING ITEMS / USER WARDROBE
-- =========================================

CREATE TABLE IF NOT EXISTS clothing_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,

    name TEXT NOT NULL,
    description TEXT,

    image_path TEXT NOT NULL,
    image_url TEXT,

    category_id INTEGER,
    color_id INTEGER,
    pattern_id INTEGER,

    material TEXT,
    brand TEXT,
    size TEXT,

    formality_level INTEGER CHECK (
        formality_level IS NULL OR
        formality_level BETWEEN 1 AND 5
    ),

    condition TEXT NOT NULL DEFAULT 'good'
        CHECK (condition IN ('new', 'good', 'worn', 'damaged')),

    status TEXT NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'archived', 'deleted')),

    -- AI-generated metadata
    ai_category TEXT,
    ai_color TEXT,
    ai_pattern TEXT,
    ai_formality_level INTEGER CHECK (
        ai_formality_level IS NULL OR
        ai_formality_level BETWEEN 1 AND 5
    ),
    ai_description TEXT,
    ai_confidence REAL CHECK (
        ai_confidence IS NULL OR
        ai_confidence BETWEEN 0 AND 1
    ),

    -- Tracks whether the user accepted or corrected AI results
    metadata_source TEXT NOT NULL DEFAULT 'manual'
        CHECK (metadata_source IN ('manual', 'ai', 'user_corrected')),

    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    FOREIGN KEY (category_id)
        REFERENCES categories(id)
        ON DELETE SET NULL,

    FOREIGN KEY (color_id)
        REFERENCES colors(id)
        ON DELETE SET NULL,

    FOREIGN KEY (pattern_id)
        REFERENCES patterns(id)
        ON DELETE SET NULL
);

-- =========================================
-- CLOTHING ITEM RELATIONSHIPS
-- =========================================

CREATE TABLE IF NOT EXISTS clothing_item_seasons (
    clothing_item_id INTEGER NOT NULL,
    season_id INTEGER NOT NULL,

    PRIMARY KEY (clothing_item_id, season_id),

    FOREIGN KEY (clothing_item_id)
        REFERENCES clothing_items(id)
        ON DELETE CASCADE,

    FOREIGN KEY (season_id)
        REFERENCES seasons(id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS clothing_item_occasions (
    clothing_item_id INTEGER NOT NULL,
    occasion_id INTEGER NOT NULL,

    PRIMARY KEY (clothing_item_id, occasion_id),

    FOREIGN KEY (clothing_item_id)
        REFERENCES clothing_items(id)
        ON DELETE CASCADE,

    FOREIGN KEY (occasion_id)
        REFERENCES occasions(id)
        ON DELETE CASCADE
);

-- =========================================
-- SAVED OUTFITS
-- =========================================

CREATE TABLE IF NOT EXISTS outfits (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,

    name TEXT NOT NULL,
    description TEXT,
    occasion TEXT,
    weather TEXT,
    formality_level INTEGER CHECK (
        formality_level IS NULL OR
        formality_level BETWEEN 1 AND 5
    ),

    is_favorite INTEGER NOT NULL DEFAULT 0
        CHECK (is_favorite IN (0, 1)),

    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS outfit_items (
    outfit_id INTEGER NOT NULL,
    clothing_item_id INTEGER NOT NULL,

    -- Examples: top, bottom, shoes, accessory, outerwear
    item_role TEXT NOT NULL,

    display_order INTEGER NOT NULL DEFAULT 0,

    PRIMARY KEY (outfit_id, clothing_item_id),

    FOREIGN KEY (outfit_id)
        REFERENCES outfits(id)
        ON DELETE CASCADE,

    FOREIGN KEY (clothing_item_id)
        REFERENCES clothing_items(id)
        ON DELETE CASCADE
);

-- =========================================
-- OUTFIT RECOMMENDATION REQUESTS
-- =========================================

CREATE TABLE IF NOT EXISTS recommendation_requests (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,

    occasion TEXT,
    weather TEXT,
    requested_style TEXT,
    requested_colors TEXT,
    requested_formality INTEGER CHECK (
        requested_formality IS NULL OR
        requested_formality BETWEEN 1 AND 5
    ),

    user_prompt TEXT,
    agent_name TEXT NOT NULL DEFAULT 'stylist_agent',
    agent_version TEXT,

    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);

-- =========================================
-- GENERATED OUTFIT RECOMMENDATIONS
-- =========================================

CREATE TABLE IF NOT EXISTS outfit_recommendations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    request_id INTEGER NOT NULL,

    title TEXT NOT NULL,
    explanation TEXT,
    confidence REAL CHECK (
        confidence IS NULL OR
        confidence BETWEEN 0 AND 1
    ),

    is_selected INTEGER NOT NULL DEFAULT 0
        CHECK (is_selected IN (0, 1)),

    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (request_id)
        REFERENCES recommendation_requests(id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS recommendation_items (
    recommendation_id INTEGER NOT NULL,
    clothing_item_id INTEGER,

    item_role TEXT NOT NULL,

    PRIMARY KEY (recommendation_id, clothing_item_id, item_role),

    FOREIGN KEY (recommendation_id)
        REFERENCES outfit_recommendations(id)
        ON DELETE CASCADE,

    FOREIGN KEY (clothing_item_id)
        REFERENCES clothing_items(id)
        ON DELETE CASCADE
);

-- =========================================
-- SHOPPING CATALOG
-- =========================================

CREATE TABLE IF NOT EXISTS catalog_products (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    external_product_id TEXT UNIQUE,
    name TEXT NOT NULL,
    description TEXT,

    brand TEXT,
    category TEXT,
    color TEXT,
    style TEXT,
    gender TEXT,

    price REAL NOT NULL CHECK (price >= 0),
    currency TEXT NOT NULL DEFAULT 'USD',

    product_url TEXT NOT NULL,
    image_url TEXT,

    availability TEXT NOT NULL DEFAULT 'available'
        CHECK (availability IN ('available', 'out_of_stock', 'discontinued')),

    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =========================================
-- SHOPPING RECOMMENDATIONS
-- =========================================

CREATE TABLE IF NOT EXISTS shopping_recommendations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    request_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,

    reason TEXT,
    match_score REAL CHECK (
        match_score IS NULL OR
        match_score BETWEEN 0 AND 1
    ),

    is_saved INTEGER NOT NULL DEFAULT 0
        CHECK (is_saved IN (0, 1)),

    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (request_id)
        REFERENCES recommendation_requests(id)
        ON DELETE CASCADE,

    FOREIGN KEY (product_id)
        REFERENCES catalog_products(id)
        ON DELETE CASCADE,

    UNIQUE (request_id, product_id)
);

-- =========================================
-- USER FEEDBACK
-- =========================================

CREATE TABLE IF NOT EXISTS recommendation_feedback (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    recommendation_id INTEGER,

    rating INTEGER CHECK (rating IS NULL OR rating BETWEEN 1 AND 5),
    was_accepted INTEGER CHECK (
        was_accepted IS NULL OR
        was_accepted IN (0, 1)
    ),
    comment TEXT,

    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    FOREIGN KEY (recommendation_id)
        REFERENCES outfit_recommendations(id)
        ON DELETE CASCADE
);

------------------------------------------
--INITIAL DATA INSERTS
-----------------------------------------

INSERT OR IGNORE INTO categories (name) VALUES
    ('shirt'),
    ('t-shirt'),
    ('blouse'),
    ('sweater'),
    ('jacket'),
    ('coat'),
    ('dress'),
    ('skirt'),
    ('pants'),
    ('jeans'),
    ('shorts'),
    ('shoes'),
    ('boots'),
    ('sneakers'),
    ('accessory'),
    ('bag'),
    ('hat');

INSERT OR IGNORE INTO colors (name) VALUES
    ('black'),
    ('white'),
    ('gray'),
    ('brown'),
    ('beige'),
    ('blue'),
    ('navy'),
    ('red'),
    ('pink'),
    ('purple'),
    ('green'),
    ('yellow'),
    ('orange'),
    ('multicolor'),
    ('unknown');

INSERT OR IGNORE INTO patterns (name) VALUES
    ('solid'),
    ('striped'),
    ('plaid'),
    ('floral'),
    ('polka_dot'),
    ('graphic'),
    ('animal_print'),
    ('unknown');

INSERT OR IGNORE INTO seasons (name) VALUES
    ('spring'),
    ('summer'),
    ('fall'),
    ('winter'),
    ('all_season');

INSERT OR IGNORE INTO occasions (name) VALUES
    ('casual'),
    ('formal'),
    ('business'),
    ('party'),
    ('date'),
    ('school'),
    ('workout'),
    ('outdoor'),
    ('travel');

---------------------------------
--INDEXES
---------------------------------
CREATE INDEX IF NOT EXISTS idx_clothing_user
ON clothing_items(user_id);

CREATE INDEX IF NOT EXISTS idx_clothing_category
ON clothing_items(category_id);

CREATE INDEX IF NOT EXISTS idx_clothing_color
ON clothing_items(color_id);

CREATE INDEX IF NOT EXISTS idx_clothing_status
ON clothing_items(status);

CREATE INDEX IF NOT EXISTS idx_outfits_user
ON outfits(user_id);

CREATE INDEX IF NOT EXISTS idx_requests_user
ON recommendation_requests(user_id);

CREATE INDEX IF NOT EXISTS idx_recommendations_request
ON outfit_recommendations(request_id);

CREATE INDEX IF NOT EXISTS idx_products_category
ON catalog_products(category);

CREATE INDEX IF NOT EXISTS idx_products_availability
ON catalog_products(availability);