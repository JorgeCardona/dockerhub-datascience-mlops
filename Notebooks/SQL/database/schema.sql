-- Enable Foreign Key constraints enforcement in SQLite
PRAGMA foreign_keys = ON;

-- ============================================================================
-- 0. DROP TABLES (In reverse dependency order)
-- ============================================================================

DROP TABLE IF EXISTS activity_logs;
DROP TABLE IF EXISTS user_subscriptions;
DROP TABLE IF EXISTS subscription_statuses;
DROP TABLE IF EXISTS plan_prices;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS subscription_plans;
DROP TABLE IF EXISTS billing_cycles;
DROP TABLE IF EXISTS order_statuses;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS payment_methods;
DROP TABLE IF EXISTS client_types;

-- ============================================================================
-- 1. LOOKUP / MASTER TABLES
-- ============================================================================

CREATE TABLE IF NOT EXISTS client_types (
    client_type_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    discount_rate REAL NOT NULL DEFAULT 0.0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS payment_methods (
    payment_method_id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT NOT NULL UNIQUE,
    display_name TEXT NOT NULL,
    is_active INTEGER NOT NULL DEFAULT 1
);

CREATE TABLE IF NOT EXISTS categories (
    category_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE IF NOT EXISTS order_statuses (
    status_id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE IF NOT EXISTS billing_cycles (
    billing_cycle_id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT NOT NULL UNIQUE,
    display_name TEXT NOT NULL,
    duration_months INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS subscription_plans (
    plan_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    is_active INTEGER NOT NULL DEFAULT 1
);

-- ============================================================================
-- 2. CORE & TRANSACTIONAL TABLES
-- ============================================================================

CREATE TABLE IF NOT EXISTS users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    country TEXT NOT NULL,
    client_type_id INTEGER NOT NULL DEFAULT 1,
    referrer_id INTEGER,
    profile_data TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_users_client_type FOREIGN KEY (client_type_id) REFERENCES client_types (client_type_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_users_referrer FOREIGN KEY (referrer_id) REFERENCES users (user_id) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS products (
    product_id INTEGER PRIMARY KEY AUTOINCREMENT,
    sku TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    category_id INTEGER NOT NULL,
    price REAL NOT NULL CHECK (price >= 0),
    stock INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES categories (category_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS orders (
    order_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    status_id INTEGER NOT NULL DEFAULT 1,
    payment_method_id INTEGER NOT NULL,
    subtotal REAL NOT NULL CHECK (subtotal >= 0),
    discount_amount REAL NOT NULL DEFAULT 0.0 CHECK (discount_amount >= 0),
    total_amount REAL NOT NULL CHECK (total_amount >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_orders_user FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_orders_status FOREIGN KEY (status_id) REFERENCES order_statuses (status_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_orders_payment_method FOREIGN KEY (payment_method_id) REFERENCES payment_methods (payment_method_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS order_items (
    order_item_id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price REAL NOT NULL CHECK (unit_price >= 0),
    CONSTRAINT fk_items_order FOREIGN KEY (order_id) REFERENCES orders (order_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_items_product FOREIGN KEY (product_id) REFERENCES products (product_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS plan_prices (
    price_id INTEGER PRIMARY KEY AUTOINCREMENT,
    plan_id INTEGER NOT NULL,
    billing_cycle_id INTEGER NOT NULL,
    price REAL NOT NULL CHECK (price >= 0),
    CONSTRAINT fk_prices_plan FOREIGN KEY (plan_id) REFERENCES subscription_plans (plan_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_prices_cycle FOREIGN KEY (billing_cycle_id) REFERENCES billing_cycles (billing_cycle_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT uq_plan_cycle UNIQUE (plan_id, billing_cycle_id)
);

-- Catalog table for subscription statuses
CREATE TABLE IF NOT EXISTS subscription_statuses (
    status_id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT NOT NULL UNIQUE,                  -- e.g., 'ACTIVE', 'PAUSED', 'CANCELLED', 'EXPIRED'
    display_name TEXT NOT NULL,
    description TEXT
);

-- Updated user subscriptions table
CREATE TABLE IF NOT EXISTS user_subscriptions (
    subscription_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    price_id INTEGER NOT NULL,
    status_id INTEGER NOT NULL DEFAULT 1,       -- FK pointing to subscription_statuses
    start_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    end_date DATE,                              -- NULL = Indefinite / Ongoing subscription
    auto_renew INTEGER NOT NULL DEFAULT 1 CHECK (auto_renew IN (0, 1)),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- FOREIGN KEYS
    CONSTRAINT fk_subscriptions_user 
        FOREIGN KEY (user_id) 
        REFERENCES users (user_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
        
    CONSTRAINT fk_subscriptions_price 
        FOREIGN KEY (price_id) 
        REFERENCES plan_prices (price_id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,

    CONSTRAINT fk_subscriptions_status 
        FOREIGN KEY (status_id) 
        REFERENCES subscription_statuses (status_id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS activity_logs (
    log_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    action TEXT NOT NULL,
    metadata TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_logs_user FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE SET NULL ON UPDATE CASCADE
);

-- ============================================================================
-- 3. SEED DATA FOR LOOKUP TABLES
-- ============================================================================
INSERT OR REPLACE INTO client_types (client_type_id, name, discount_rate) VALUES
(1, 'Regular', 0.00),
(2, 'VIP', 0.15),
(3, 'Wholesale', 0.25),
(4, 'Premium', 0.10),
(5, 'Student', 0.05),
(6, 'Non-Profit', 0.20),
(7, 'Government', 0.30),
(8, 'Corporate', 0.12),
(9, 'Startup', 0.08),
(10, 'Enterprise', 0.18);

INSERT OR REPLACE INTO payment_methods (payment_method_id, code, display_name) VALUES
(1, 'CREDIT_CARD', 'Credit Card'),
(2, 'DEBIT_CARD', 'Debit Card'),
(3, 'PAYPAL', 'PayPal'),
(4, 'BANK_TRANSFER', 'Bank Transfer'),
(5, 'CASH_ON_DELIVERY', 'Cash on Delivery'),    
(6, 'APPLE_PAY', 'Apple Pay'),
(7, 'GOOGLE_PAY', 'Google Pay'),
(8, 'BITCOIN', 'Bitcoin'),
(9, 'ETHEREUM', 'Ethereum'),
(10, 'STRIPE', 'Stripe');

INSERT OR REPLACE INTO order_statuses (status_id, code, description) VALUES
(1, 'PENDING', 'Order created, awaiting payment'),
(2, 'PAID', 'Payment confirmed'),
(3, 'SHIPPED', 'Order dispatched to customer'),
(4, 'COMPLETED', 'Order delivered successfully'),
(5, 'CANCELLED', 'Order cancelled'),
(6, 'REFUNDED', 'Order refunded to customer'),
(7, 'FAILED', 'Payment failed or order could not be processed');

INSERT OR REPLACE INTO categories (category_id, name, description) VALUES
(1, 'Electronics', 'Electronic devices and gadgets'),
(2, 'Software', 'Digital software and applications'),
(3, 'Furniture', 'Home and office furniture'),
(4, 'Accessories', 'Accessories and supplements'),
(5, 'Sports', 'Sports equipment and gear'),
(6, 'Toys & Games', 'Toys, games, and entertainment products'),
(7, 'Books & Stationery', 'Books and stationery items'),
(8, 'Home & Kitchen', 'Home and kitchen products'),
(9, 'Beauty & Personal Care', 'Beauty and personal care items'),
(10, 'Automotive', 'Automotive parts and accessories'),
(11, 'Pet Supplies', 'Pet food and supplies'),
(12, 'Health & Wellness', 'Health and wellness products'),
(13, 'Clothing & Apparel', 'Clothing and apparel items'),
(14, 'Outdoor & Garden', 'Outdoor and garden products'),
(15, 'Music & Instruments', 'Musical instruments and accessories'),
(16, 'Art & Crafts', 'Art supplies and craft materials'),
(17, 'Baby Products', 'Products for babies and toddlers'),
(18, 'Travel & Luggage', 'Travel gear and luggage items'),
(19, 'Food & Beverages', 'Food and beverage products'),
(20, 'Jewelry & Watches', 'Jewelry and watches'),
(21, 'Industrial & Scientific', 'Heavy machinery and industrial manufacturing equipment'),
(22, 'Laboratory Supplies', 'Precision laboratory instruments and research tools'),
(23, 'Medical Equipment', 'Medical devices and sterilization equipment');

INSERT OR REPLACE INTO billing_cycles (billing_cycle_id, code, display_name, duration_months) VALUES
(1, 'WEEKLY', 'Weekly', 0),
(2, 'MONTHLY', 'Monthly', 1),
(3, 'BIMONTHLY', 'Bimonthly', 2),
(4, 'QUARTERLY', 'Quarterly', 3),
(5, 'SEMESTRAL', 'Semestral', 6),
(6, 'ANNUAL', 'Annual', 12),
(7, 'INDEFINITE', 'Indefinite / Ongoing', 0);

INSERT OR REPLACE INTO subscription_plans (plan_id, name, description) VALUES
(1, 'Free', 'Basic free tier'),
(2, 'Pro', 'Advanced tier for professionals'),
(3, 'Enterprise', 'Unlimited tier for enterprises');

INSERT OR REPLACE INTO plan_prices (plan_id, billing_cycle_id, price) VALUES
(1, 7, 0.00),
(2, 1, 4.99),
(2, 2, 14.99),
(2, 3, 28.99),
(2, 4, 39.99),
(2, 5, 75.99),
(2, 6, 139.99),
(2, 7, 19.99),
(3, 2, 49.99),
(3, 6, 499.99),
(3, 7, 59.99);

INSERT OR REPLACE INTO subscription_statuses (status_id, code, display_name, description) VALUES
(1, 'ACTIVE', 'Active', 'Subscription is currently active and valid'),
(2, 'PAUSED', 'Paused', 'Subscription is temporarily paused by user'),
(3, 'CANCELLED', 'Cancelled', 'Subscription was cancelled and will not renew'),
(4, 'EXPIRED', 'Expired', 'Subscription period ended without renewal'),
(5, 'PENDING', 'Pending', 'Subscription is pending activation or payment');

-- ==============================================================================
-- 2. USERS (100 Registros)
-- ==============================================================================
INSERT OR REPLACE INTO users (user_id, first_name, last_name, email, country, client_type_id, referrer_id, profile_data, created_at) VALUES
(1, 'Carlos', 'Mendoza', 'carlos@email.com', 'ES', 1, NULL, '{"age": 34, "preferences": {"theme": "dark", "newsletter": true}, "tags": ["vip", "tech"]}', '2025-01-15 00:00:00'),
(2, 'Ana', 'Gómez', 'ana@email.com', 'MX', 1, 1, '{"age": 28, "preferences": {"theme": "light", "newsletter": false}, "tags": ["casual"]}', '2025-02-01 00:00:00'),
(3, 'Luis', 'Fernández', 'luis@email.com', 'AR', 1, 1, '{"age": 42, "preferences": {"theme": "dark"}, "tags": ["tech", "b2b"]}', '2025-02-10 00:00:00'),
(4, 'Sofia', 'Silva', 'sofia@email.com', 'CL', 1, 2, '{"age": 22, "preferences": {"theme": "light", "newsletter": true}, "tags": []}', '2025-03-05 00:00:00'),
(5, 'Mateo', 'Rossi', 'mateo@email.com', 'ES', 1, 4, '{"age": 50, "preferences": {"newsletter": true}, "tags": ["vip"]}', '2025-03-20 00:00:00'),
(6, 'Elena', 'Rostova', 'elena@email.com', 'MX', 1, NULL, '{"age": 31, "preferences": {"theme": "dark"}, "tags": ["b2b"]}', '2025-04-12 00:00:00'),
(7, 'David', 'Kim', 'david@email.com', 'US', 1, 3, '{"age": 29, "preferences": {"theme": "dark"}, "tags": ["tech"]}', '2025-05-01 00:00:00'),
(8, 'Lucía', 'Morales', 'lucia@email.com', 'CO', 1, NULL, '{"age": 37, "preferences": {"theme": "light"}, "tags": ["casual"]}', '2025-06-15 00:00:00'),
(9, 'Alejandro', 'Torres', 'ale@email.com', 'ES', 1, 1, '{"age": 45, "preferences": {"theme": "dark", "newsletter": true}, "tags": ["vip"]}', '2025-06-18 00:00:00'),
(10, 'Valeria', 'Ríos', 'valeria@email.com', 'PE', 1, 2, '{"age": 26, "preferences": {"theme": "light"}, "tags": ["tech"]}', '2025-07-02 00:00:00'),
(11, 'Gabriel', 'Castro', 'gabriel@email.com', 'MX', 1, NULL, '{"age": 33, "preferences": {"theme": "dark"}, "tags": []}', '2025-07-10 00:00:00'),
(12, 'Camila', 'Vargas', 'camila@email.com', 'CO', 1, 5, '{"age": 29, "preferences": {"newsletter": false}, "tags": ["casual"]}', '2025-07-15 00:00:00'),
(13, 'Javier', 'López', 'javier@email.com', 'AR', 1, NULL, '{"age": 39, "preferences": {"theme": "light", "newsletter": true}, "tags": ["b2b"]}', '2025-07-22 00:00:00'),
(14, 'Mariana', 'Ortiz', 'mariana@email.com', 'ES', 1, 3, '{"age": 31, "preferences": {"theme": "dark"}, "tags": ["tech", "vip"]}', '2025-08-01 00:00:00'),
(15, 'Diego', 'Navarro', 'diego@email.com', 'CL', 1, NULL, '{"age": 24, "preferences": {"theme": "light"}, "tags": []}', '2025-08-05 00:00:00'),
(16, 'Isabel', 'Blanco', 'isabel@email.com', 'US', 1, 7, '{"age": 52, "preferences": {"theme": "dark", "newsletter": true}, "tags": ["b2b"]}', '2025-08-12 00:00:00'),
(17, 'Tomas', 'Herrera', 'tomas@email.com', 'MX', 1, 2, '{"age": 27, "preferences": {"theme": "light"}, "tags": ["casual"]}', '2025-08-20 00:00:00'),
(18, 'Paula', 'Domínguez', 'paula@email.com', 'ES', 1, NULL, '{"age": 36, "preferences": {"theme": "dark"}, "tags": ["tech"]}', '2025-09-01 00:00:00'),
(19, 'Martin', 'Delgado', 'martin@email.com', 'AR', 1, 9, '{"age": 41, "preferences": {"newsletter": true}, "tags": ["vip"]}', '2025-09-08 00:00:00'),
(20, 'Natalia', 'Peña', 'natalia@email.com', 'PE', 1, NULL, '{"age": 30, "preferences": {"theme": "light"}, "tags": []}', '2025-09-15 00:00:00'),
(21, 'Andrés', 'Ruiz', 'andres@email.com', 'CO', 1, 12, '{"age": 28, "preferences": {"theme": "dark"}, "tags": ["tech"]}', '2025-09-22 00:00:00'),
(22, 'Daniela', 'Guerrero', 'daniela@email.com', 'MX', 1, NULL, '{"age": 35, "preferences": {"theme": "light", "newsletter": true}, "tags": ["b2b"]}', '2025-10-01 00:00:00'),
(23, 'Hugo', 'Medina', 'hugo@email.com', 'ES', 1, 1, '{"age": 48, "preferences": {"theme": "dark"}, "tags": ["vip"]}', '2025-10-05 00:00:00'),
(24, 'Sara', 'Aguilar', 'sara@email.com', 'CL', 1, NULL, '{"age": 23, "preferences": {"theme": "light"}, "tags": ["casual"]}', '2025-10-12 00:00:00'),
(25, 'Fernando', 'Vega', 'fernando@email.com', 'AR', 1, 13, '{"age": 44, "preferences": {"newsletter": false}, "tags": ["b2b"]}', '2025-10-18 00:00:00'),
(26, 'Claudia', 'Benítez', 'claudia@email.com', 'US', 1, NULL, '{"age": 38, "preferences": {"theme": "dark"}, "tags": ["tech"]}', '2025-10-25 00:00:00'),
(27, 'Ricardo', 'Parra', 'ricardo@email.com', 'MX', 1, 6, '{"age": 32, "preferences": {"theme": "light"}, "tags": []}', '2025-11-01 00:00:00'),
(28, 'Patricia', 'Lara', 'patricia@email.com', 'ES', 1, NULL, '{"age": 40, "preferences": {"theme": "dark", "newsletter": true}, "tags": ["vip"]}', '2025-11-08 00:00:00'),
(29, 'Manuel', 'Bravo', 'manuel@email.com', 'CO', 1, 21, '{"age": 27, "preferences": {"theme": "light"}, "tags": ["casual"]}', '2025-11-15 00:00:00'),
(30, 'Carmen', 'Fuentes', 'carmen@email.com', 'PE', 1, NULL, '{"age": 29, "preferences": {"theme": "dark"}, "tags": ["tech"]}', '2025-11-22 00:00:00'),
(31, 'Esteban', 'Molina', 'esteban@email.com', 'CL', 1, 4, '{"age": 34, "preferences": {"newsletter": true}, "tags": []}', '2025-12-01 00:00:00'),
(32, 'Monica', 'Campos', 'monica@email.com', 'AR', 1, NULL, '{"age": 46, "preferences": {"theme": "light"}, "tags": ["b2b"]}', '2025-12-05 00:00:00'),
(33, 'Francisco', 'Reyes', 'francisco@email.com', 'MX', 1, 11, '{"age": 31, "preferences": {"theme": "dark"}, "tags": ["tech", "vip"]}', '2025-12-10 00:00:00'),
(34, 'Beatriz', 'Santamaría', 'beatriz@email.com', 'ES', 1, NULL, '{"age": 53, "preferences": {"theme": "light"}, "tags": []}', '2025-12-15 00:00:00'),
(35, 'Gonzalo', 'Ibáñez', 'gonzalo@email.com', 'US', 1, 16, '{"age": 26, "preferences": {"newsletter": false}, "tags": ["casual"]}', '2025-12-20 00:00:00'),
(36, 'Raquel', 'Cortés', 'raquel@email.com', 'CO', 1, NULL, '{"age": 37, "preferences": {"theme": "dark"}, "tags": ["b2b"]}', '2026-01-05 00:00:00'),
(37, 'Adrián', 'Gallego', 'adrian@email.com', 'ES', 1, 28, '{"age": 30, "preferences": {"theme": "light"}, "tags": ["tech"]}', '2026-01-12 00:00:00'),
(38, 'Sonia', 'Marin', 'sonia@email.com', 'MX', 1, NULL, '{"age": 42, "preferences": {"theme": "dark", "newsletter": true}, "tags": ["vip"]}', '2026-01-18 00:00:00'),
(39, 'Marcos', 'Garrido', 'marcos@email.com', 'AR', 1, 19, '{"age": 25, "preferences": {"theme": "light"}, "tags": []}', '2026-01-25 00:00:00'),
(40, 'Alicia', 'Vidal', 'alicia@email.com', 'CL', 1, NULL, '{"age": 33, "preferences": {"theme": "dark"}, "tags": ["casual"]}', '2026-02-01 00:00:00'),
(41, 'Emilio', 'Santos', 'emilio@email.com', 'PE', 1, 30, '{"age": 47, "preferences": {"newsletter": true}, "tags": ["b2b"]}', '2026-02-08 00:00:00'),
(42, 'Gloria', 'Calvo', 'gloria@email.com', 'ES', 1, NULL, '{"age": 39, "preferences": {"theme": "light"}, "tags": ["tech"]}', '2026-02-14 00:00:00'),
(43, 'Guillermo', 'Cano', 'guillermo@email.com', 'US', 1, 26, '{"age": 28, "preferences": {"theme": "dark"}, "tags": ["vip"]}', '2026-02-20 00:00:00'),
(44, 'Inés', 'Crespo', 'ines@email.com', 'MX', 1, NULL, '{"age": 32, "preferences": {"theme": "light"}, "tags": []}', '2026-03-01 00:00:00'),
(45, 'Jaime', 'Pastor', 'jaime@email.com', 'CO', 1, 29, '{"age": 36, "preferences": {"newsletter": false}, "tags": ["casual"]}', '2026-03-08 00:00:00'),
(46, 'Lorena', 'Sainz', 'lorena@email.com', 'AR', 1, NULL, '{"age": 41, "preferences": {"theme": "dark"}, "tags": ["tech", "b2b"]}', '2026-03-15 00:00:00'),
(47, 'Xavier', 'Soler', 'xavier@email.com', 'ES', 1, 37, '{"age": 29, "preferences": {"theme": "light"}, "tags": []}', '2026-03-22 00:00:00'),
(48, 'Verónica', 'Esteban', 'veronica@email.com', 'CL', 1, NULL, '{"age": 35, "preferences": {"theme": "dark", "newsletter": true}, "tags": ["vip"]}', '2026-04-01 00:00:00'),
(49, 'Samuel', 'Márquez', 'samuel@email.com', 'MX', 1, 33, '{"age": 27, "preferences": {"theme": "light"}, "tags": ["tech"]}', '2026-04-10 00:00:00'),
(50, 'Nuria', 'Polo', 'nuria@email.com', 'PE', 1, NULL, '{"age": 44, "preferences": {"theme": "dark"}, "tags": ["casual"]}', '2026-04-18 00:00:00'),
(51, 'John', 'Smith', 'john.smith@email.com', 'US', 2, 7, '{"age": 36, "preferences": {"theme": "dark", "newsletter": true}, "tags": ["vip", "tech"]}', '2026-04-20 00:00:00'),
(52, 'Emily', 'Johnson', 'emily.j@email.com', 'CA', 1, NULL, '{"age": 29, "preferences": {"theme": "light"}, "tags": ["casual"]}', '2026-04-22 00:00:00'),
(53, 'Michael', 'Brown', 'mbrown@email.com', 'US', 3, 51, '{"age": 45, "preferences": {"newsletter": true}, "tags": ["b2b"]}', '2026-04-25 00:00:00'),
(54, 'Sophie', 'Dubois', 'sophie.d@email.com', 'FR', 1, NULL, '{"age": 31, "preferences": {"theme": "dark"}, "tags": ["tech"]}', '2026-04-28 00:00:00'),
(55, 'Lukas', 'Weber', 'l.weber@email.com', 'DE', 2, 54, '{"age": 40, "preferences": {"theme": "light", "newsletter": true}, "tags": ["vip"]}', '2026-05-02 00:00:00'),
(56, 'Oliver', 'Taylor', 'oliver.t@email.com', 'GB', 1, 16, '{"age": 27, "preferences": {"theme": "dark"}, "tags": []}', '2026-05-05 00:00:00'),
(57, 'Kenji', 'Sato', 'kenji.sato@email.com', 'JP', 4, NULL, '{"age": 38, "preferences": {"theme": "dark", "newsletter": false}, "tags": ["tech", "vip"]}', '2026-05-08 00:00:00'),
(58, 'Min-jun', 'Kim', 'minjun.kim@email.com', 'KR', 1, 57, '{"age": 25, "preferences": {"theme": "light"}, "tags": ["tech"]}', '2026-05-12 00:00:00'),
(59, 'Wei', 'Zhang', 'wei.zhang@email.com', 'CN', 3, NULL, '{"age": 42, "preferences": {"newsletter": true}, "tags": ["b2b"]}', '2026-05-15 00:00:00'),
(60, 'Aarav', 'Sharma', 'aarav.s@email.com', 'IN', 1, 58, '{"age": 30, "preferences": {"theme": "dark"}, "tags": ["casual"]}', '2026-05-18 00:00:00'),
(61, 'Liam', 'Wilson', 'liam.w@email.com', 'CA', 1, NULL, '{"age": 33, "preferences": {"theme": "light"}, "tags": []}', '2026-05-20 00:00:00'),
(62, 'Emma', 'Davis', 'edavis@email.com', 'US', 2, 51, '{"age": 35, "preferences": {"theme": "dark", "newsletter": true}, "tags": ["vip"]}', '2026-05-22 00:00:00'),
(63, 'Lucas', 'Bernard', 'lucas.b@email.com', 'FR', 1, NULL, '{"age": 28, "preferences": {"theme": "light"}, "tags": ["casual"]}', '2026-05-25 00:00:00'),
(64, 'Mia', 'Müller', 'm.muller@email.com', 'DE', 1, 55, '{"age": 26, "preferences": {"theme": "dark"}, "tags": ["tech"]}', '2026-05-29 00:00:00'),
(65, 'James', 'Evans', 'james.e@email.com', 'GB', 3, NULL, '{"age": 49, "preferences": {"newsletter": false}, "tags": ["b2b"]}', '2026-06-01 00:00:00'),
(66, 'Yui', 'Takahashi', 'yui.t@email.com', 'JP', 1, 57, '{"age": 24, "preferences": {"theme": "light", "newsletter": true}, "tags": []}', '2026-06-04 00:00:00'),
(67, 'Ji-woo', 'Park', 'jiwoo.p@email.com', 'KR', 2, NULL, '{"age": 31, "preferences": {"theme": "dark"}, "tags": ["vip"]}', '2026-06-08 00:00:00'),
(68, 'Li', 'Wang', 'li.wang@email.com', 'CN', 1, 59, '{"age": 37, "preferences": {"theme": "light"}, "tags": ["tech"]}', '2026-06-11 00:00:00'),
(69, 'Priya', 'Patel', 'ppatel@email.com', 'IN', 1, NULL, '{"age": 29, "preferences": {"newsletter": true}, "tags": ["casual"]}', '2026-06-15 00:00:00'),
(70, 'Noah', 'Miller', 'noahm@email.com', 'US', 1, 62, '{"age": 32, "preferences": {"theme": "dark"}, "tags": []}', '2026-06-18 00:00:00'),
(71, 'Olivia', 'Tremblay', 'olivia.t@email.com', 'CA', 4, NULL, '{"age": 44, "preferences": {"theme": "light"}, "tags": ["vip"]}', '2026-06-22 00:00:00'),
(72, 'Antoine', 'Moreau', 'a.moreau@email.com', 'FR', 1, 63, '{"age": 39, "preferences": {"theme": "dark", "newsletter": true}, "tags": ["b2b"]}', '2026-06-25 00:00:00'),
(73, 'Hannah', 'Schneider', 'h.schneider@email.com', 'DE', 1, NULL, '{"age": 27, "preferences": {"theme": "light"}, "tags": ["tech"]}', '2026-06-28 00:00:00'),
(74, 'Alexander', 'Wright', 'alex.w@email.com', 'GB', 2, 56, '{"age": 34, "preferences": {"theme": "dark"}, "tags": ["vip", "tech"]}', '2026-07-01 00:00:00'),
(75, 'Ren', 'Tanaka', 'ren.t@email.com', 'JP', 1, NULL, '{"age": 41, "preferences": {"newsletter": false}, "tags": []}', '2026-07-04 00:00:00'),
(76, 'Seo-jun', 'Lee', 'seojun.l@email.com', 'KR', 3, 67, '{"age": 46, "preferences": {"theme": "dark"}, "tags": ["b2b"]}', '2026-07-08 00:00:00'),
(77, 'Hao', 'Liu', 'hao.liu@email.com', 'CN', 1, NULL, '{"age": 30, "preferences": {"theme": "light"}, "tags": ["casual"]}', '2026-07-11 00:00:00'),
(78, 'Ananya', 'Rao', 'ananya.r@email.com', 'IN', 1, 60, '{"age": 26, "preferences": {"theme": "dark", "newsletter": true}, "tags": ["tech"]}', '2026-07-15 00:00:00'),
(79, 'Ethan', 'Anderson', 'e.anderson@email.com', 'US', 1, NULL, '{"age": 37, "preferences": {"theme": "light"}, "tags": []}', '2026-07-18 00:00:00'),
(80, 'Charlotte', 'Roy', 'charlotte.r@email.com', 'CA', 2, 71, '{"age": 33, "preferences": {"theme": "dark"}, "tags": ["vip"]}', '2026-07-22 00:00:00'),
(81, 'Camille', 'Girard', 'c.girard@email.com', 'FR', 1, NULL, '{"age": 30, "preferences": {"newsletter": true}, "tags": ["casual"]}', '2026-07-25 00:00:00'),
(82, 'Finn', 'Fischer', 'f.fischer@email.com', 'DE', 1, 73, '{"age": 23, "preferences": {"theme": "light"}, "tags": ["tech"]}', '2026-07-29 00:00:00'),
(83, 'Charlotte', 'Green', 'c.green@email.com', 'GB', 1, NULL, '{"age": 38, "preferences": {"theme": "dark"}, "tags": []}', '2026-08-01 00:00:00'),
(84, 'Haruto', 'Watanabe', 'h.watanabe@email.com', 'JP', 2, 75, '{"age": 29, "preferences": {"theme": "light", "newsletter": true}, "tags": ["vip"]}', '2026-08-05 00:00:00'),
(85, 'Do-yun', 'Choi', 'doyun.c@email.com', 'KR', 1, NULL, '{"age": 35, "preferences": {"theme": "dark"}, "tags": ["casual"]}', '2026-08-08 00:00:00'),
(86, 'Ming', 'Chen', 'ming.chen@email.com', 'CN', 1, 77, '{"age": 28, "preferences": {"theme": "light"}, "tags": ["tech"]}', '2026-08-12 00:00:00'),
(87, 'Rohan', 'Gupta', 'rohan.g@email.com', 'IN', 3, NULL, '{"age": 43, "preferences": {"newsletter": false}, "tags": ["b2b"]}', '2026-08-15 00:00:00'),
(88, 'Benjamin', 'Thomas', 'ben.t@email.com', 'US', 1, 79, '{"age": 31, "preferences": {"theme": "dark"}, "tags": []}', '2026-08-18 00:00:00'),
(89, 'Amelia', 'Gagnon', 'a.gagnon@email.com', 'CA', 1, NULL, '{"age": 27, "preferences": {"theme": "light", "newsletter": true}, "tags": ["casual"]}', '2026-08-22 00:00:00'),
(90, 'Louis', 'Roux', 'louis.roux@email.com', 'FR', 2, 81, '{"age": 36, "preferences": {"theme": "dark"}, "tags": ["vip"]}', '2026-08-25 00:00:00'),
(91, 'Jonas', 'Meyer', 'j.meyer@email.com', 'DE', 1, NULL, '{"age": 41, "preferences": {"theme": "light"}, "tags": ["b2b"]}', '2026-08-29 00:00:00'),
(92, 'Amelia', 'Baker', 'a.baker@email.com', 'GB', 1, 83, '{"age": 25, "preferences": {"newsletter": true}, "tags": ["tech"]}', '2026-09-02 00:00:00'),
(93, 'Mei', 'Ito', 'mei.ito@email.com', 'JP', 1, NULL, '{"age": 33, "preferences": {"theme": "dark"}, "tags": []}', '2026-09-05 00:00:00'),
(94, 'Ha-jun', 'Jung', 'hajun.j@email.com', 'KR', 1, 85, '{"age": 30, "preferences": {"theme": "light"}, "tags": ["tech"]}', '2026-09-08 00:00:00'),
(95, 'Yang', 'Yang', 'yang.yang@email.com', 'CN', 2, NULL, '{"age": 39, "preferences": {"theme": "dark", "newsletter": true}, "tags": ["vip"]}', '2026-09-12 00:00:00'),
(96, 'Vihaan', 'Nair', 'vihaan.n@email.com', 'IN', 1, 87, '{"age": 28, "preferences": {"theme": "light"}, "tags": ["casual"]}', '2026-09-15 00:00:00'),
(97, 'Lucas', 'White', 'lwhite@email.com', 'US', 1, NULL, '{"age": 34, "preferences": {"theme": "dark"}, "tags": ["tech"]}', '2026-09-18 00:00:00'),
(98, 'Ella', 'Côté', 'ella.cote@email.com', 'CA', 1, 89, '{"age": 22, "preferences": {"newsletter": false}, "tags": []}', '2026-09-22 00:00:00'),
(99, 'Gabriel', 'David', 'g.david@email.com', 'FR', 3, NULL, '{"age": 48, "preferences": {"theme": "light"}, "tags": ["b2b"]}', '2026-09-25 00:00:00'),
(100, 'Mia', 'Hoffmann', 'm.hoffmann@email.com', 'DE', 1, 91, '{"age": 29, "preferences": {"theme": "dark", "newsletter": true}, "tags": ["casual"]}', '2026-09-28 00:00:00');

-- ==============================================================================
-- PRODUCTS (300 Items: 20 per Category)
-- ==============================================================================

INSERT OR REPLACE INTO products (product_id, sku, name, category_id, price, stock, created_at) VALUES
-- Category 1: Electronics
(1, 'ELE-001', 'Wireless Noise-Canceling Headphones', 1, 199.99, 45, '2025-01-10 10:00:00'),
(2, 'ELE-002', 'Ultra HD Smart TV 55 Inch', 1, 499.99, 15, '2025-01-12 11:30:00'),
(3, 'ELE-003', 'Bluetooth Portable Speaker', 1, 39.99, 120, '2025-01-15 09:15:00'),
(4, 'ELE-004', '4K Action Camera', 1, 129.50, 30, '2025-01-18 14:20:00'),
(5, 'ELE-005', 'Smartwatch Series 5', 1, 249.00, 60, '2025-01-20 16:45:00'),
(6, 'ELE-006', 'Gaming Monitor 27-inch 144Hz', 1, 289.99, 25, '2025-01-22 08:00:00'),
(7, 'ELE-007', 'Wireless Charging Pad', 1, 19.99, 200, '2025-01-25 13:10:00'),
(8, 'ELE-008', 'Mechanical Gaming Keyboard', 1, 79.99, 85, '2025-01-28 15:30:00'),
(9, 'ELE-009', 'Ergonomic Wireless Mouse', 1, 29.99, 110, '2025-02-01 10:00:00'),
(10, 'ELE-010', '1080p Web Camera with Mic', 1, 49.95, 90, '2025-02-03 12:00:00'),
(11, 'ELE-011', 'Tablet 10-inch 64GB', 1, 179.99, 40, '2025-02-05 17:25:00'),
(12, 'ELE-012', 'E-Reader Waterproof', 1, 119.99, 50, '2025-02-08 11:15:00'),
(13, 'ELE-013', 'External SSD 1TB', 1, 99.99, 75, '2025-02-10 09:40:00'),
(14, 'ELE-014', 'USB-C Hub Multiport Adapter', 1, 34.99, 150, '2025-02-12 14:00:00'),
(15, 'ELE-015', 'VR Headset All-in-One', 1, 399.00, 18, '2025-02-15 16:10:00'),
(16, 'ELE-016', 'Wi-Fi 6 Mesh Router System', 1, 159.99, 35, '2025-02-18 10:50:00'),
(17, 'ELE-017', 'Drone with 4K Camera', 1, 299.99, 22, '2025-02-20 13:30:00'),
(18, 'ELE-018', 'Soundbar with Subwoofer', 1, 149.95, 28, '2025-02-22 15:00:00'),
(19, 'ELE-019', 'Smart Home Security Camera', 1, 59.99, 95, '2025-02-25 11:20:00'),
(20, 'ELE-020', 'Noise Isolating Earbuds', 1, 24.99, 180, '2025-02-28 08:45:00'),

-- Category 2: Software
(21, 'SOFT-001', 'Antivirus Security Suite 1-Year', 2, 39.99, 999, '2025-01-10 10:00:00'),
(22, 'SOFT-002', 'Office Productivity Suite License', 2, 149.99, 999, '2025-01-12 11:30:00'),
(23, 'SOFT-003', 'Video Editing Software Pro', 2, 299.00, 999, '2025-01-15 09:15:00'),
(24, 'SOFT-004', 'Photo Editing Software Suite', 2, 99.99, 999, '2025-01-18 14:20:00'),
(25, 'SOFT-005', 'Graphic Design Vector Editor', 2, 199.99, 999, '2025-01-20 16:45:00'),
(26, 'SOFT-006', 'Accounting & Invoicing Pro', 2, 119.50, 999, '2025-01-22 08:00:00'),
(27, 'SOFT-007', 'VPN Subscription 2-Year', 2, 79.99, 999, '2025-01-25 13:10:00'),
(28, 'SOFT-008', '3D Modeling & Animation Tool', 2, 499.00, 999, '2025-01-28 15:30:00'),
(29, 'SOFT-009', 'Password Manager Premium', 2, 29.99, 999, '2025-02-01 10:00:00'),
(30, 'SOFT-010', 'Audio Workstation DAW Software', 2, 199.00, 999, '2025-02-03 12:00:00'),
(31, 'SOFT-011', 'Cloud Storage 1TB Annual Plan', 2, 59.99, 999, '2025-02-05 17:25:00'),
(32, 'SOFT-012', 'Project Management Desktop App', 2, 89.99, 999, '2025-02-08 11:15:00'),
(33, 'SOFT-013', 'Database Management Studio', 2, 249.99, 999, '2025-02-10 09:40:00'),
(34, 'SOFT-014', 'IDE Code Editor Enterprise', 2, 129.00, 999, '2025-02-12 14:00:00'),
(35, 'SOFT-015', 'Language Learning Software', 2, 69.99, 999, '2025-02-15 16:10:00'),
(36, 'SOFT-016', 'PDF Editor & Converter Pro', 2, 49.99, 999, '2025-02-18 10:50:00'),
(37, 'SOFT-017', 'System Cleaner & Optimizer', 2, 19.99, 999, '2025-02-20 13:30:00'),
(38, 'SOFT-018', 'Screen Recorder & Streamer', 2, 39.95, 999, '2025-02-22 15:00:00'),
(39, 'SOFT-019', 'CAD Architectural Design Software', 2, 899.00, 999, '2025-02-25 11:20:00'),
(40, 'SOFT-020', 'Data Recovery Wizard', 2, 69.95, 999, '2025-02-28 08:45:00'),

-- Category 3: Furniture
(41, 'FUR-001', 'Ergonomic Mesh Office Chair', 3, 189.99, 30, '2025-01-10 10:00:00'),
(42, 'FUR-002', 'Adjustable Standing Desk', 3, 299.99, 20, '2025-01-12 11:30:00'),
(43, 'FUR-003', '3-Seater Fabric Sofa', 3, 549.00, 10, '2025-01-15 09:15:00'),
(44, 'FUR-004', 'Wooden Coffee Table', 3, 89.99, 45, '2025-01-18 14:20:00'),
(45, 'FUR-005', 'Bookshelf 5-Tier Industrial', 3, 119.99, 25, '2025-01-20 16:45:00'),
(46, 'FUR-006', 'Queen Size Bed Frame', 3, 249.50, 15, '2025-01-22 08:00:00'),
(47, 'FUR-007', 'Nightstand with Drawers', 3, 59.99, 60, '2025-01-25 13:10:00'),
(48, 'FUR-008', 'Dining Table Set for 4', 3, 349.99, 12, '2025-01-28 15:30:00'),
(49, 'FUR-009', 'Leather Reclining Armchair', 3, 279.00, 18, '2025-02-01 10:00:00'),
(50, 'FUR-010', 'TV Stand Console Unit', 3, 139.99, 35, '2025-02-03 12:00:00'),
(51, 'FUR-011', 'Bar Stool Adjustable Set of 2', 3, 99.99, 40, '2025-02-05 17:25:00'),
(52, 'FUR-012', 'Storage Ottoman Bench', 3, 49.99, 50, '2025-02-08 11:15:00'),
(53, 'FUR-013', 'Wardrobe Armoire Closet', 3, 399.99, 8, '2025-02-10 09:40:00'),
(54, 'FUR-014', 'Computer Desk with Shelves', 3, 109.99, 30, '2025-02-12 14:00:00'),
(55, 'FUR-015', 'Accent Lounge Chair', 3, 159.00, 22, '2025-02-15 16:10:00'),
(56, 'FUR-016', 'Filing Cabinet 3-Drawer', 3, 79.99, 35, '2025-02-18 10:50:00'),
(57, 'FUR-017', 'Entryway Shoe Rack Bench', 3, 45.99, 65, '2025-02-20 13:30:00'),
(58, 'FUR-018', 'Futon Convertible Sofa Bed', 3, 219.99, 14, '2025-02-22 15:00:00'),
(59, 'FUR-019', 'Vanity Table with Mirror', 3, 169.95, 18, '2025-02-25 11:20:00'),
(60, 'FUR-020', 'Patio Outdoor Dining Chair', 3, 69.99, 50, '2025-02-28 08:45:00'),

-- Category 4: Accessories
(61, 'ACC-001', 'Polarized Sunglasses', 4, 29.99, 100, '2025-01-10 10:00:00'),
(62, 'ACC-002', 'Genuine Leather Wallet', 4, 34.50, 120, '2025-01-12 11:30:00'),
(63, 'ACC-003', 'Stainless Steel Wristwatch', 4, 89.99, 60, '2025-01-15 09:15:00'),
(64, 'ACC-004', 'Travel Backpack 30L', 4, 49.99, 80, '2025-01-18 14:20:00'),
(65, 'ACC-005', 'Canvas Messenger Bag', 4, 39.99, 70, '2025-01-20 16:45:00'),
(66, 'ACC-006', 'Leather Dress Belt', 4, 24.99, 150, '2025-01-22 08:00:00'),
(67, 'ACC-007', 'Winter Beanie & Scarf Set', 4, 19.99, 200, '2025-01-25 13:10:00'),
(68, 'ACC-008', 'RFID Blocking Card Holder', 4, 14.99, 250, '2025-01-28 15:30:00'),
(69, 'ACC-009', 'Fashion Tote Bag', 4, 44.99, 90, '2025-02-01 10:00:00'),
(70, 'ACC-010', 'Baseball Cap Cotton', 4, 15.99, 180, '2025-02-03 12:00:00'),
(71, 'ACC-011', 'Silk Necktie Set', 4, 22.99, 110, '2025-02-05 17:25:00'),
(72, 'ACC-012', 'Compact Travel Umbrella', 4, 16.50, 140, '2025-02-08 11:15:00'),
(73, 'ACC-013', 'Keychain Leather Strap', 4, 9.99, 300, '2025-02-10 09:40:00'),
(74, 'ACC-014', 'Laptop Sleeve 15-inch', 4, 21.99, 130, '2025-02-12 14:00:00'),
(75, 'ACC-015', 'Travel Duffle Bag', 4, 59.99, 45, '2025-02-15 16:10:00'),
(76, 'ACC-016', 'Touchscreen Winter Gloves', 4, 18.99, 160, '2025-02-18 10:50:00'),
(77, 'ACC-017', 'Jewelry Organizer Case', 4, 27.99, 85, '2025-02-20 13:30:00'),
(78, 'ACC-018', 'Classic Aviator Sunglasses', 4, 32.00, 95, '2025-02-22 15:00:00'),
(79, 'ACC-019', 'Crossbody Phone Purse', 4, 25.99, 115, '2025-02-25 11:20:00'),
(80, 'ACC-020', 'Cufflinks Silver Plated', 4, 19.50, 90, '2025-02-28 08:45:00'),

-- Category 5: Sports
(81, 'SPO-001', 'Yoga Mat Non-Slip 6mm', 5, 24.99, 150, '2025-01-10 10:00:00'),
(82, 'SPO-002', 'Dumbbell Set 20 lbs Adjustable', 5, 49.99, 60, '2025-01-12 11:30:00'),
(83, 'SPO-003', 'Resistance Bands Set of 5', 5, 15.99, 200, '2025-01-15 09:15:00'),
(84, 'SPO-004', 'Soccer Ball Match Size 5', 5, 22.50, 110, '2025-01-18 14:20:00'),
(85, 'SPO-005', 'Basketball Official Size', 5, 29.99, 90, '2025-01-20 16:45:00'),
(86, 'SPO-006', 'Tennis Racket Graphite', 5, 79.99, 40, '2025-01-22 08:00:00'),
(87, 'SPO-007', 'Running Shoes Lightweight', 5, 69.99, 75, '2025-01-25 13:10:00'),
(88, 'SPO-008', 'Fitness Activity Tracker', 5, 39.99, 130, '2025-01-28 15:30:00'),
(89, 'SPO-009', 'Jump Rope High Speed', 5, 9.99, 250, '2025-02-01 10:00:00'),
(90, 'SPO-010', 'Foam Roller Muscle Recovery', 5, 19.99, 100, '2025-02-03 12:00:00'),
(91, 'SPO-011', 'Cycling Helmet Breathable', 5, 34.99, 65, '2025-02-05 17:25:00'),
(92, 'SPO-012', 'Insulated Sports Water Bottle', 5, 18.50, 180, '2025-02-08 11:15:00'),
(93, 'SPO-013', 'Swimming Goggles Anti-Fog', 5, 14.99, 140, '2025-02-10 09:40:00'),
(94, 'SPO-014', 'Pull-Up Bar Doorway', 5, 29.95, 55, '2025-02-12 14:00:00'),
(95, 'SPO-015', 'Kettlebell 15 lbs', 5, 32.99, 70, '2025-02-15 16:10:00'),
(96, 'SPO-016', 'Boxing Gloves 12oz', 5, 39.99, 50, '2025-02-18 10:50:00'),
(97, 'SPO-017', 'Golf Balls Pack of 12', 5, 24.99, 120, '2025-02-20 13:30:00'),
(98, 'SPO-018', 'Badminton Set with Net', 5, 44.99, 35, '2025-02-22 15:00:00'),
(99, 'SPO-019', 'Exercise Ball 65cm', 5, 16.99, 115, '2025-02-25 11:20:00'),
(100, 'SPO-020', 'Gym Gloves Wrist Support', 5, 12.99, 160, '2025-02-28 08:45:00'),

-- Category 6: Toys & Games
(101, 'TOY-001', 'Building Blocks Set 500 Pcs', 6, 34.99, 90, '2025-01-10 10:00:00'),
(102, 'TOY-002', 'Remote Control Racing Car', 6, 29.99, 75, '2025-01-12 11:30:00'),
(103, 'TOY-003', 'Strategy Board Game Strategy', 6, 39.99, 50, '2025-01-15 09:15:00'),
(104, 'TOY-004', 'Jigsaw Puzzle 1000 Pieces', 6, 16.99, 120, '2025-01-18 14:20:00'),
(105, 'TOY-005', 'Teddy Bear Plush Toy 18 Inch', 6, 19.99, 110, '2025-01-20 16:45:00'),
(106, 'TOY-006', 'Wooden Chess Set Classic', 6, 24.99, 65, '2025-01-22 08:00:00'),
(107, 'TOY-007', 'Educational STEM Robot Kit', 6, 49.99, 40, '2025-01-25 13:10:00'),
(108, 'TOY-008', 'Card Game Family Edition', 6, 12.99, 200, '2025-01-28 15:30:00'),
(109, 'TOY-009', 'Dollhouse with Furniture', 6, 89.99, 25, '2025-02-01 10:00:00'),
(110, 'TOY-010', 'Play-Doh Clay Set 10-Pack', 6, 11.99, 180, '2025-02-03 12:00:00'),
(111, 'TOY-011', 'Die-Cast Toy Cars Pack of 5', 6, 9.99, 150, '2025-02-05 17:25:00'),
(112, 'TOY-012', 'Interactive Electronic Pet', 6, 22.99, 85, '2025-02-08 11:15:00'),
(113, 'TOY-013', 'Action Figure Superhero 12 inch', 6, 14.99, 130, '2025-02-10 09:40:00'),
(114, 'TOY-014', 'Kids Musical Keyboard Toy', 6, 27.50, 60, '2025-02-12 14:00:00'),
(115, 'TOY-015', 'Walkie Talkies for Kids Pair', 6, 25.99, 95, '2025-02-15 16:10:00'),
(116, 'TOY-016', 'Magnetic Tiles 60 Pcs Set', 6, 39.95, 70, '2025-02-18 10:50:00'),
(117, 'TOY-017', 'Drone Mini Indoor Toy', 6, 31.99, 55, '2025-02-20 13:30:00'),
(118, 'TOY-018', 'Water Blaster Soaker Gun', 6, 15.99, 140, '2025-02-22 15:00:00'),
(119, 'TOY-019', 'Kite Large Easy Fly', 6, 13.50, 110, '2025-02-25 11:20:00'),
(120, 'TOY-020', 'Rubik''s Speed Cube 3x3', 6, 8.99, 220, '2025-02-28 08:45:00'),

-- Category 7: Books & Stationery
(121, 'BKS-001', 'Hardcover Journal Notebook A5', 7, 12.99, 200, '2025-01-10 10:00:00'),
(122, 'BKS-002', 'Gel Pen Set 12 Colors', 7, 8.99, 300, '2025-01-12 11:30:00'),
(123, 'BKS-003', 'Sci-Fi Hardcover Novel Best-Seller', 7, 24.95, 80, '2025-01-15 09:15:00'),
(124, 'BKS-004', 'Self-Help Paperback Book', 7, 14.99, 120, '2025-01-18 14:20:00'),
(125, 'BKS-005', 'Fountain Pen Fine Nib', 7, 19.99, 90, '2025-01-20 16:45:00'),
(126, 'BKS-006', 'Weekly Planner Undated', 7, 11.50, 150, '2025-01-22 08:00:00'),
(127, 'BKS-007', 'Sticky Notes Pastel 12 Pads', 7, 6.99, 400, '2025-01-25 13:10:00'),
(128, 'BKS-008', 'Highlighters Chisel Tip 6 Pack', 7, 5.99, 350, '2025-01-28 15:30:00'),
(129, 'BKS-009', 'Cookbook Easy Recipes', 7, 21.99, 70, '2025-02-01 10:00:00'),
(130, 'BKS-010', 'World Atlas Hardcover', 7, 29.99, 40, '2025-02-03 12:00:00'),
(131, 'BKS-011', 'Colored Pencils 48 Pack', 7, 13.99, 160, '2025-02-05 17:25:00'),
(132, 'BKS-012', 'Desk Organizer Mesh Steel', 7, 15.99, 110, '2025-02-08 11:15:00'),
(133, 'BKS-013', 'Heavy Duty Stapler with Staples', 7, 10.99, 130, '2025-02-10 09:40:00'),
(134, 'BKS-014', 'Pencil Case Zipper Pouch', 7, 7.99, 220, '2025-02-12 14:00:00'),
(135, 'BKS-015', 'History Biography Paperback', 7, 16.50, 85, '2025-02-15 16:10:00'),
(136, 'BKS-016', 'Watercolor Paint Set 24 Colors', 7, 18.99, 95, '2025-02-18 10:50:00'),
(137, 'BKS-017', 'Correction Tape 6 Pack', 7, 4.99, 280, '2025-02-20 13:30:00'),
(138, 'BKS-018', 'Clipboard Storage Box', 7, 9.99, 140, '2025-02-22 15:00:00'),
(139, 'BKS-019', 'Calligraphy Set for Beginners', 7, 17.99, 75, '2025-02-25 11:20:00'),
(140, 'BKS-020', 'Adult Coloring Book Stress Relief', 7, 9.50, 190, '2025-02-28 08:45:00'),

-- Category 8: Home & Kitchen
(141, 'HAK-001', 'Stainless Steel Cookware Set 10-Piece', 8, 129.99, 30, '2025-01-10 10:00:00'),
(142, 'HAK-002', 'Programmable Coffee Maker 12-Cup', 8, 49.99, 65, '2025-01-12 11:30:00'),
(143, 'HAK-003', 'Digital Air Fryer 5-Quart', 8, 79.99, 50, '2025-01-15 09:15:00'),
(144, 'HAK-004', 'High-Speed Countertop Blender', 8, 59.95, 40, '2025-01-18 14:20:00'),
(145, 'HAK-005', 'Electric Kitchen Scale', 8, 14.99, 150, '2025-01-20 16:45:00'),
(146, 'HAK-006', 'Chef Knife 8-inch German Steel', 8, 34.99, 85, '2025-01-22 08:00:00'),
(147, 'HAK-007', 'Non-Stick Frying Pan 10-inch', 8, 24.99, 110, '2025-01-25 13:10:00'),
(148, 'HAK-008', 'Electric Kettle 1.7L', 8, 29.99, 90, '2025-01-28 15:30:00'),
(149, 'HAK-009', 'Food Storage Containers 20-Piece', 8, 26.99, 130, '2025-02-01 10:00:00'),
(150, 'HAK-010', 'Memory Foam Bath Mat', 8, 16.99, 140, '2025-02-03 12:00:00'),
(151, 'HAK-011', 'Microfiber Sheets Queen Set', 8, 22.99, 100, '2025-02-05 17:25:00'),
(152, 'HAK-012', 'Handheld Garment Steamer', 8, 32.50, 70, '2025-02-08 11:15:00'),
(153, 'HAK-013', 'Robot Vacuum Cleaner', 8, 189.99, 25, '2025-02-10 09:40:00'),
(154, 'HAK-014', 'Bamboo Cutting Board Set of 3', 8, 19.99, 120, '2025-02-12 14:00:00'),
(155, 'HAK-015', 'Silicone Cooking Utensils Set', 8, 21.99, 105, '2025-02-15 16:10:00'),
(156, 'HAK-016', 'Cast Iron Dutch Oven 5-Quart', 8, 54.99, 35, '2025-02-18 10:50:00'),
(157, 'HAK-017', 'Bed Pillow Cooling Gel Pair', 8, 39.99, 80, '2025-02-20 13:30:00'),
(158, 'HAK-018', 'Dish Drying Rack Stainless', 8, 27.99, 95, '2025-02-22 15:00:00'),
(159, 'HAK-019', 'Manual Can Opener Smooth Edge', 8, 9.99, 200, '2025-02-25 11:20:00'),
(160, 'HAK-020', 'French Press Coffee Maker 34oz', 8, 19.95, 115, '2025-02-28 08:45:00'),

-- Category 9: Beauty & Personal Care
(161, 'BPC-001', 'Ionic Hair Dryer 1875W', 9, 39.99, 75, '2025-01-10 10:00:00'),
(162, 'BPC-002', 'Electric Hair Straightener', 9, 29.99, 85, '2025-01-12 11:30:00'),
(163, 'BPC-003', 'Hydrating Face Moisturizer 50ml', 9, 18.50, 140, '2025-01-15 09:15:00'),
(164, 'BPC-004', 'Gentle Facial Cleanser 200ml', 9, 12.99, 180, '2025-01-18 14:20:00'),
(165, 'BPC-005', 'Electric Toothbrush Rechargeable', 9, 49.99, 60, '2025-01-20 16:45:00'),
(166, 'BPC-006', 'Beard Trimmer & Grooming Kit', 9, 34.99, 90, '2025-01-22 08:00:00'),
(167, 'BPC-007', 'Vitamin C Serum for Face', 9, 15.99, 160, '2025-01-25 13:10:00'),
(168, 'BPC-008', 'Makeup Brush Set 12 Pcs', 9, 16.99, 130, '2025-01-28 15:30:00'),
(169, 'BPC-009', 'Sunscreen SPF 50 Broad Spectrum', 9, 14.50, 190, '2025-02-01 10:00:00'),
(170, 'BPC-010', 'EAU De Parfum Spray 100ml', 9, 65.00, 45, '2025-02-03 12:00:00'),
(171, 'BPC-011', 'Exfoliating Body Scrub 300g', 9, 11.99, 125, '2025-02-05 17:25:00'),
(172, 'BPC-012', 'Argan Oil Hair Mask', 9, 13.99, 110, '2025-02-08 11:15:00'),
(173, 'BPC-013', 'Manicure & Pedicure Set', 9, 9.99, 210, '2025-02-10 09:40:00'),
(174, 'BPC-014', 'LED Makeup Mirror Lighted', 9, 24.99, 80, '2025-02-12 14:00:00'),
(175, 'BPC-015', 'Lip Balm Pack of 4', 9, 7.99, 300, '2025-02-15 16:10:00'),
(176, 'BPC-016', 'Hair Curling Wand', 9, 27.99, 65, '2025-02-18 10:50:00'),
(177, 'BPC-017', 'Deep Cleansing Clay Mask', 9, 14.99, 105, '2025-02-20 13:30:00'),
(178, 'BPC-018', 'Men''s Aftershave Lotion', 9, 16.00, 95, '2025-02-22 15:00:00'),
(179, 'BPC-019', 'Water Flosser Cordless', 9, 38.99, 70, '2025-02-25 11:20:00'),
(180, 'BPC-020', 'Organic Body Wash 500ml', 9, 10.99, 150, '2025-02-28 08:45:00'),

-- Category 10: Automotive
(181, 'AUTO-001', 'OBD2 Scanner Diagnostic Tool', 10, 35.99, 80, '2025-01-10 10:00:00'),
(182, 'AUTO-002', 'Portable Car Tire Inflator 12V', 10, 29.99, 100, '2025-01-12 11:30:00'),
(183, 'AUTO-003', 'Car Dash Cam 1080p Front', 10, 49.99, 65, '2025-01-15 09:15:00'),
(184, 'AUTO-004', 'Car Phone Mount Air Vent', 10, 11.99, 250, '2025-01-18 14:20:00'),
(185, 'AUTO-005', 'Microfiber Car Cleaning Towels', 10, 14.99, 200, '2025-01-20 16:45:00'),
(186, 'AUTO-006', 'Car Battery Jump Starter Pack', 10, 69.99, 45, '2025-01-22 08:00:00'),
(187, 'AUTO-007', 'All-Weather Car Floor Mats', 10, 39.99, 60, '2025-01-25 13:10:00'),
(188, 'AUTO-008', 'Car Vacuum Cleaner Handheld', 10, 25.99, 110, '2025-01-28 15:30:00'),
(189, 'AUTO-009', 'Windshield Wiper Blades Pair', 10, 19.99, 140, '2025-02-01 10:00:00'),
(190, 'AUTO-010', 'LED Headlight Bulbs Conversion Kit', 10, 42.50, 75, '2025-02-03 12:00:00'),
(191, 'AUTO-011', 'Trunk Cargo Organizer Storage', 10, 22.99, 90, '2025-02-05 17:25:00'),
(192, 'AUTO-012', 'Leather Steering Wheel Cover', 10, 15.99, 130, '2025-02-08 11:15:00'),
(193, 'AUTO-013', 'Car Wash Soap & Wax 64oz', 10, 12.50, 120, '2025-02-10 09:40:00'),
(194, 'AUTO-014', 'Bluetooth FM Transmitter for Car', 10, 16.99, 170, '2025-02-12 14:00:00'),
(195, 'AUTO-015', 'Tire Pressure Gauge Digital', 10, 9.99, 220, '2025-02-15 16:10:00'),
(196, 'AUTO-016', 'Car Cover Waterproof Outdoor', 10, 45.99, 35, '2025-02-18 10:50:00'),
(197, 'AUTO-017', 'Seat Cushion Memory Foam', 10, 27.99, 85, '2025-02-20 13:30:00'),
(198, 'AUTO-018', 'Emergency Roadside Assistance Kit', 10, 34.99, 50, '2025-02-22 15:00:00'),
(199, 'AUTO-019', 'Car Scratch Remover Polish', 10, 13.99, 160, '2025-02-25 11:20:00'),
(200, 'AUTO-020', 'Windshield Sun Shade Foldable', 10, 12.99, 180, '2025-02-28 08:45:00'),

-- Category 11: Pet Supplies
(201, 'PET-001', 'Orthopedic Dog Bed Large', 11, 49.99, 45, '2025-01-10 10:00:00'),
(202, 'PET-002', 'Interactive Cat Tree Tower', 11, 59.99, 35, '2025-01-12 11:30:00'),
(203, 'PET-003', 'me Dry Dog Food Grain-Free 15lbs', 11, 38.99, 70, '2025-01-15 09:15:00'),
(204, 'PET-004', 'Automatic Pet Water Fountain 2.5L', 11, 25.99, 90, '2025-01-18 14:20:00'),
(205, 'PET-005', 'Retractable Dog Leash 16ft', 11, 15.99, 130, '2025-01-20 16:45:00'),
(206, 'PET-006', 'Dog Chew Toys Pack of 5', 11, 12.99, 180, '2025-01-22 08:00:00'),
(207, 'PET-007', 'Cat Litter Box Hooded', 11, 29.99, 50, '2025-01-25 13:10:00'),
(208, 'PET-008', 'Pet Grooming Brush Deshedding', 11, 14.99, 140, '2025-01-28 15:30:00'),
(209, 'PET-009', 'Dog Harness No-Pull Medium', 11, 19.99, 100, '2025-02-01 10:00:00'),
(210, 'PET-010', 'Cat Feather Wand Toy Set', 11, 8.99, 210, '2025-02-03 12:00:00'),
(211, 'PET-011', 'Stainless Steel Pet Bowls Pair', 11, 11.50, 160, '2025-02-05 17:25:00'),
(212, 'PET-012', 'Pet Carrier Airline Approved', 11, 32.99, 60, '2025-02-08 11:15:00'),
(213, 'PET-013', 'Dog Training Pads 100-Count', 11, 24.99, 110, '2025-02-10 09:40:00'),
(214, 'PET-014', 'Cat Scratcher Lounge Board', 11, 16.99, 95, '2025-02-12 14:00:00'),
(215, 'PET-015', 'Dog Nail Clipper with Guard', 11, 9.99, 170, '2025-02-15 16:10:00'),
(216, 'PET-016', 'Pet Odor Stain Remover Spray', 11, 13.99, 125, '2025-02-18 10:50:00'),
(217, 'PET-017', 'Dog Dental Chews Treats 30-Pack', 11, 17.50, 135, '2025-02-20 13:30:00'),
(218, 'PET-018', 'Cat Soft Bed Donut Cuddler', 11, 22.99, 75, '2025-02-22 15:00:00'),
(219, 'PET-019', 'Pet Heating Pad Adjustable', 11, 27.99, 40, '2025-02-25 11:20:00'),
(220, 'PET-020', 'Dog Raincoat Waterproof', 11, 14.50, 85, '2025-02-28 08:45:00'),

-- Category 12: Health & Wellness
(221, 'HLT-001', 'Multivitamin Daily Supplements 120 Tablets', 12, 19.99, 150, '2025-01-10 10:00:00'),
(222, 'HLT-002', 'Whey Protein Powder Chocolate 2lbs', 12, 34.99, 80, '2025-01-12 11:30:00'),
(223, 'HLT-003', 'Digital Upper Arm Blood Pressure Monitor', 12, 39.99, 65, '2025-01-15 09:15:00'),
(224, 'HLT-004', 'Pulse Oximeter Fingertip Oxygen Sensor', 12, 17.99, 110, '2025-01-18 14:20:00'),
(225, 'HLT-005', 'Infrared Forehead Thermometer', 12, 24.99, 90, '2025-01-20 16:45:00'),
(226, 'HLT-006', 'Omega 3 Fish Oil 1000mg Softgels', 12, 16.50, 130, '2025-01-22 08:00:00'),
(227, 'HLT-007', 'Probiotics 50 Billion CFU', 12, 22.99, 100, '2025-01-25 13:10:00'),
(228, 'HLT-008', 'Massage Gun Muscle Deep Tissue', 12, 69.99, 45, '2025-01-28 15:30:00'),
(229, 'HLT-009', 'Electric Heating Pad for Back Pain', 12, 26.99, 85, '2025-02-01 10:00:00'),
(230, 'HLT-010', 'First Aid Kit 100 Pieces', 12, 15.99, 140, '2025-02-03 12:00:00'),
(231, 'HLT-011', 'Posture Corrector Adjustable Brace', 12, 18.99, 120, '2025-02-05 17:25:00'),
(232, 'HLT-012', 'Essential Oil Diffuser Ultrasonic 300ml', 12, 21.99, 95, '2025-02-08 11:15:00'),
(233, 'HLT-013', 'Aromatherapy Lavender Essential Oil', 12, 9.99, 200, '2025-02-10 09:40:00'),
(234, 'HLT-014', 'Melatonin Sleep Aid 5mg 100 Gummies', 12, 12.99, 160, '2025-02-12 14:00:00'),
(235, 'HLT-015', 'Vitamin D3 5000 IU Softgels', 12, 11.50, 175, '2025-02-15 16:10:00'),
(236, 'HLT-016', 'Smart Body Fat Scale Bluetooth', 12, 29.99, 70, '2025-02-18 10:50:00'),
(237, 'HLT-017', 'Compression Knee Sleeve Pair', 12, 14.99, 130, '2025-02-20 13:30:00'),
(238, 'HLT-018', 'Collagen Peptides Powder Unflavored', 12, 27.99, 75, '2025-02-22 15:00:00'),
(239, 'HLT-019', 'Neck & Back Massager with Heat', 12, 44.99, 50, '2025-02-25 11:20:00'),
(240, 'HLT-020', 'Weekly Pill Organizer 7 Day', 12, 6.99, 250, '2025-02-28 08:45:00'),

-- Category 13: Clothing & Apparel
(241, 'CLO-001', 'Men''s Classic Crewneck T-Shirt Pack of 3', 13, 22.99, 150, '2025-01-10 10:00:00'),
(242, 'CLO-002', 'Women''s High Waisted Leggings', 13, 19.99, 180, '2025-01-12 11:30:00'),
(243, 'CLO-003', 'Unisex Fleece Pullover Hoodie', 13, 34.99, 95, '2025-01-15 09:15:00'),
(244, 'CLO-004', 'Men''s Slim Fit Denim Jeans', 13, 44.50, 80, '2025-01-18 14:20:00'),
(245, 'CLO-005', 'Women''s Casual Denim Jacket', 13, 49.99, 65, '2025-01-20 16:45:00'),
(246, 'CLO-006', 'Cotton Ankle Socks Pack of 6', 13, 12.99, 300, '2025-01-22 08:00:00'),
(247, 'CLO-007', 'Men''s Button Down Oxford Shirt', 13, 29.99, 90, '2025-01-25 13:10:00'),
(248, 'CLO-008', 'Women''s V-Neck Summer Dress', 13, 32.99, 70, '2025-01-28 15:30:00'),
(249, 'CLO-009', 'Waterproof Winter Coat Hooded', 13, 89.99, 40, '2025-02-01 10:00:00'),
(250, 'CLO-010', 'Men''s Athletic Sweatpants', 13, 27.99, 110, '2025-02-03 12:00:00'),
(251, 'CLO-011', 'Thermal Underwear Set Top & Bottom', 13, 24.99, 85, '2025-02-05 17:25:00'),
(252, 'CLO-012', 'Women''s Knit Cardigan Sweater', 13, 36.50, 75, '2025-02-08 11:15:00'),
(253, 'CLO-013', 'Men''s Polo Shirt Short Sleeve', 13, 21.99, 130, '2025-02-10 09:40:00'),
(254, 'CLO-014', 'Sports Bra High Impact', 13, 18.99, 140, '2025-02-12 14:00:00'),
(255, 'CLO-015', 'Leather Dress Shoes Classic', 13, 69.99, 50, '2025-02-15 16:10:00'),
(256, 'CLO-016', 'Casual Slip-On Canvas Shoes', 13, 29.99, 100, '2025-02-18 10:50:00'),
(257, 'CLO-017', 'Mens Swimming Trunks Quick Dry', 13, 17.99, 120, '2025-02-20 13:30:00'),
(258, 'CLO-018', 'Women''s Trench Coat Double Breasted', 13, 74.99, 35, '2025-02-22 15:00:00'),
(259, 'CLO-019', 'Pajama Set Soft Viscose', 13, 26.99, 90, '2025-02-25 11:20:00'),
(260, 'CLO-020', 'Rain Jacket Windbreaker Light', 13, 39.95, 60, '2025-02-28 08:45:00'),

-- Category 14: Outdoor & Garden
(261, 'OUT-001', 'Camping Tent 4-Person Waterproof', 14, 99.99, 30, '2025-01-10 10:00:00'),
(262, 'OUT-002', 'Sleeping Bag 3-Season', 14, 39.99, 60, '2025-01-12 11:30:00'),
(263, 'OUT-003', 'Portable Camping Stove Propane', 14, 27.50, 75, '2025-01-15 09:15:00'),
(264, 'OUT-004', 'LED Camping Lantern Rechargeable', 14, 18.99, 120, '2025-01-18 14:20:00'),
(265, 'OUT-005', 'Folding Camp Chair Lightweight', 14, 24.99, 90, '2025-01-20 16:45:00'),
(266, 'OUT-006', 'Stainless Steel BBQ Grill Tool Set', 14, 32.99, 65, '2025-01-22 08:00:00'),
(267, 'OUT-007', 'Garden Hose Expandable 50ft', 14, 29.99, 85, '2025-01-25 13:10:00'),
(268, 'OUT-008', 'Gardening Tool Set 7-Piece', 14, 22.99, 100, '2025-01-28 15:30:00'),
(269, 'OUT-009', 'Solar Pathway Lights Outdoor 8-Pack', 14, 25.99, 110, '2025-02-01 10:00:00'),
(270, 'OUT-010', 'Double Camping Hammock with Straps', 14, 21.99, 130, '2025-02-03 12:00:00'),
(271, 'OUT-011', 'Trekking Hiking Poles Pair', 14, 28.50, 80, '2025-02-05 17:25:00'),
(272, 'OUT-012', 'Outdoor Patio Umbrella 9ft', 14, 59.99, 40, '2025-02-08 11:15:00'),
(273, 'OUT-013', 'Heavy Duty Fire Pit 30 Inch', 14, 119.99, 20, '2025-02-10 09:40:00'),
(274, 'OUT-014', 'Electric Pressure Washer 2000 PSI', 14, 149.00, 25, '2025-02-12 14:00:00'),
(275, 'OUT-015', 'Pruning Shears Garden Pruner', 14, 12.99, 160, '2025-02-15 16:10:00'),
(276, 'OUT-016', 'Cooler Box 30-Quart Portable', 14, 44.99, 50, '2025-02-18 10:50:00'),
(277, 'OUT-017', 'Bug Zapper Outdoor Electric', 14, 31.99, 70, '2025-02-20 13:30:00'),
(278, 'OUT-018', 'Plant Waterer Self-Globe Set of 4', 14, 14.50, 140, '2025-02-22 15:00:00'),
(279, 'OUT-019', 'Picnic Blanket Waterproof Large', 14, 19.99, 105, '2025-02-25 11:20:00'),
(280, 'OUT-020', 'Outdoor String Lights 50ft', 14, 35.99, 95, '2025-02-28 08:45:00'),

-- Category 15: Music & Instruments
(281, 'MUS-001', 'Acoustic Guitar 41-Inch Cutaway', 15, 149.99, 25, '2025-01-10 10:00:00'),
(282, 'MUS-002', 'Digital Piano 61 Key Keyboard', 15, 119.99, 35, '2025-01-12 11:30:00'),
(283, 'MUS-003', 'Electric Guitar Starter Kit', 15, 189.99, 20, '2025-01-15 09:15:00'),
(284, 'MUS-004', 'Soprano Ukulele Mahogany', 15, 42.50, 60, '2025-01-18 14:20:00'),
(285, 'MUS-005', 'Guitar Clip-On Digital Tuner', 15, 9.99, 250, '2025-01-20 16:45:00'),
(286, 'MUS-006', 'Adjustable Guitar Stand', 15, 16.99, 120, '2025-01-22 08:00:00'),
(287, 'MUS-007', 'Dynamic Vocal Microphone XLR', 15, 39.99, 75, '2025-01-25 13:10:00'),
(288, 'MUS-008', 'USB Studio Condenser Microphone', 15, 59.99, 50, '2025-01-28 15:30:00'),
(289, 'MUS-009', 'Over-Ear Studio Monitor Headphones', 15, 79.99, 45, '2025-02-01 10:00:00'),
(290, 'MUS-010', 'Acoustic Guitar Strings Light Gauge', 15, 6.99, 300, '2025-02-03 12:00:00'),
(291, 'MUS-011', 'Folding Music Stand with Bag', 15, 18.99, 110, '2025-02-05 17:25:00'),
(292, 'MUS-012', 'Electronic Drum Pad Practice Set', 15, 69.99, 30, '2025-02-08 11:15:00'),
(293, 'MUS-013', 'Violin Full Size 4/4 Starter Outfit', 15, 129.00, 18, '2025-02-10 09:40:00'),
(294, 'MUS-014', 'Harmonica Key of C 10-Hole', 15, 12.99, 160, '2025-02-12 14:00:00'),
(295, 'MUS-015', 'Guitar Capo Quick Change', 15, 7.99, 220, '2025-02-15 16:10:00'),
(296, 'MUS-016', 'Guitar Strap Woven Vintage', 15, 11.99, 140, '2025-02-18 10:50:00'),
(297, 'MUS-017', 'Guitar Picks Variety Pack of 24', 15, 5.99, 400, '2025-02-20 13:30:00'),
(298, 'MUS-018', 'Keyboard Bench X-Style Adjustable', 15, 29.99, 55, '2025-02-22 15:00:00'),
(299, 'MUS-019', 'Piano Sustain Pedal Universal', 15, 15.50, 90, '2025-02-25 11:20:00'),
(300, 'MUS-020', 'Compact 2-Channel Audio Interface', 15, 99.99, 40, '2025-02-28 08:45:00'),
(301, 'SKU-IND-001', 'Industrial 150A CNC Plasma Cutter', 21, 3450.00, 5, '2026-05-10 09:00:00'),
(302, 'SKU-IND-002', 'Heavy Duty Hydraulic Press 50-Ton', 21, 2800.00, 4, '2026-05-10 10:15:00'),
(303, 'SKU-IND-003', 'Automated Rotary Metal Lathe Machine', 21, 4200.00, 3, '2026-05-10 11:30:00'),
(304, 'SKU-IND-004', '3D Industrial Metal Printer Pro', 21, 8500.00, 2, '2026-05-10 12:45:00'),
(305, 'SKU-IND-005', 'High Precision Fiber Laser Welder', 21, 5100.00, 6, '2026-05-10 14:00:00'),
(306, 'SKU-IND-006', 'Pneumatic Conveyor Belt System 10m', 21, 1950.00, 8, '2026-05-10 15:15:00'),
(307, 'SKU-IND-007', 'Industrial Dust Collector Extractor 3KW', 21, 1250.00, 10, '2026-05-10 16:30:00'),
(308, 'SKU-IND-008', 'Automated Pallet Wrapping Machine', 21, 3100.00, 5, '2026-05-10 17:45:00'),
(309, 'SKU-IND-009', 'Heavy Industrial Screw Air Compressor', 21, 2600.00, 7, '2026-05-10 19:00:00'),
(310, 'SKU-IND-010', 'Motorized Material Handling Stacker 1.5T', 21, 2200.00, 6, '2026-05-10 20:15:00'),
(311, 'SKU-LAB-001', 'Desktop Scanning Electron Microscope', 22, 12800.00, 2, '2026-05-12 11:30:00'),
(312, 'SKU-LAB-002', 'High-Speed Refrigerated Centrifuge', 22, 3100.00, 6, '2026-05-12 12:45:00'),
(313, 'SKU-LAB-003', 'Analytical Precision Balance Scale 0.0001g', 22, 1450.00, 12, '2026-05-12 14:00:00'),
(314, 'SKU-LAB-004', 'Ultrapure Water Purification System', 22, 2900.00, 4, '2026-05-12 15:15:00'),
(315, 'SKU-LAB-005', 'UV-Vis Double Beam Spectrophotometer', 22, 4300.00, 3, '2026-05-12 16:30:00'),
(316, 'SKU-LAB-006', 'Microplate Reader & Washer Combo', 22, 5200.00, 5, '2026-05-12 17:45:00'),
(317, 'SKU-LAB-007', 'Orbital Shaker Incubator Constant Temp', 22, 1850.00, 7, '2026-05-12 19:00:00'),
(318, 'SKU-LAB-008', 'Rotary Evaporator Distillation Unit 5L', 22, 2400.00, 5, '2026-05-12 20:15:00'),
(319, 'SKU-LAB-009', 'Digital Ultrasonic Cleaner Sonicator 30L', 22, 980.00, 15, '2026-05-12 21:30:00'),
(320, 'SKU-LAB-010', 'Biological Safety Cabinet Class II A2', 22, 3800.00, 4, '2026-05-12 22:45:00'),
(321, 'SKU-MED-001', '24L Tabletop Steam Sterilizer Autoclave', 23, 890.00, 12, '2026-05-15 14:20:00'),
(322, 'SKU-MED-002', 'Multi-Parameter Patient Monitor 12-Inch', 23, 1650.00, 8, '2026-05-15 15:30:00'),
(323, 'SKU-MED-003', 'Portable Color Doppler Ultrasound Scanner', 23, 6400.00, 3, '2026-05-15 16:45:00'),
(324, 'SKU-MED-004', 'Automatic External Defibrillator AED', 23, 1200.00, 10, '2026-05-15 18:00:00'),
(325, 'SKU-MED-005', 'Hospital Hydraulic Operating Table', 23, 4100.00, 4, '2026-05-15 19:15:00'),
(326, 'SKU-MED-006', 'LED Shadowless Surgical Operation Light', 23, 2750.00, 6, '2026-05-15 20:30:00'),
(327, 'SKU-MED-007', 'Infusion Pump Volumetric Smart Touch', 23, 750.00, 20, '2026-05-15 21:45:00'),
(328, 'SKU-MED-008', 'Medical Grade Oxygen Concentrator 10L', 23, 920.00, 15, '2026-05-15 22:00:00'),
(329, 'SKU-MED-009', 'Electric Medical ICU Hospital Bed 5-Function', 23, 1850.00, 7, '2026-05-15 22:30:00'),
(330, 'SKU-MED-010', 'Digital ECG Machine 12-Lead Channel', 23, 1100.00, 9, '2026-05-15 23:00:00');
-- ==============================================================================
-- SCRIPT 1: GENERACIÓN DE ÓRDENES CON CONFIGURACIÓN Y DESCUENTOS DINÁMICOS
-- ==============================================================================
-- ==============================================================================
-- GENERACIÓN DE ÓRDENES (CONFIGURABLE Y BASADO EN DDL REAL)
-- ==============================================================================

INSERT INTO orders (user_id, status_id, payment_method_id, subtotal, discount_amount, total_amount, created_at)
WITH RECURSIVE 
Config AS (
    SELECT 2000 AS total_orders -- <--- CANTIDAD DE ÓRDENES A GENERAR
),
OrderIDs AS (
    SELECT 1 AS o_id, total_orders FROM Config
    UNION ALL
    SELECT o_id + 1, total_orders FROM OrderIDs WHERE o_id < total_orders
),
-- Selecciona de forma aleatoria registros reales de usuarios, estados y métodos de pago
RandomOrders AS (
    SELECT 
        o.o_id,
        (SELECT user_id FROM users ORDER BY RANDOM() LIMIT 1) AS user_id,
        (SELECT status_id FROM order_statuses ORDER BY RANDOM() LIMIT 1) AS status_id,
        (SELECT payment_method_id FROM payment_methods WHERE is_active = 1 ORDER BY RANDOM() LIMIT 1) AS payment_method_id,
        ROUND(CAST(((ABS(RANDOM()) % 92000) + 8000) AS FLOAT) / 100.0, 2) AS subtotal,
        DATETIME('2025-01-01 08:00:00', '+' || (ABS(RANDOM()) % 500) || ' days', '+' || (ABS(RANDOM()) % 86400) || ' seconds') AS created_at
    FROM OrderIDs o
),
-- Lee la columna discount_rate real conectando users con client_types
CalculatedOrders AS (
    SELECT 
        ro.user_id,
        ro.status_id,
        ro.payment_method_id,
        ro.subtotal,
        COALESCE(ct.discount_rate, 0.0) AS discount_rate,
        ro.created_at
    FROM RandomOrders ro
    INNER JOIN users u ON ro.user_id = u.user_id
    INNER JOIN client_types ct ON u.client_type_id = ct.client_type_id
)
SELECT 
    user_id,
    status_id,
    payment_method_id,
    subtotal,
    ROUND(subtotal * discount_rate, 2) AS discount_amount,
    ROUND(subtotal * (1.00 - discount_rate), 2) AS total_amount,
    created_at
FROM CalculatedOrders;

-- ==============================================================================
-- GENERACIÓN DE ORDER_ITEMS (SIN DUPLICADOS DE PRODUCTO POR ORDEN)
-- ==============================================================================

INSERT INTO order_items (order_id, product_id, quantity, unit_price)
WITH 
Config AS (
    SELECT 
        1 AS min_items, -- <--- MINIMUM ITEMS PER ORDER
        10 AS max_items -- <--- MAXIMUM ITEMS PER ORDER
),
-- Generates the desired target item count per order
OrderTarget AS (
    SELECT 
        o.order_id,
        CAST(
            (ABS(RANDOM()) % ((SELECT max_items FROM Config) - (SELECT min_items FROM Config) + 1)) 
            + (SELECT min_items FROM Config) AS INT
        ) AS target_items
    FROM orders o
),
-- Cross joins with products while excluding specific product IDs
ShuffledProducts AS (
    SELECT 
        t.order_id,
        t.target_items,
        p.product_id,
        p.price AS current_price,
        ROW_NUMBER() OVER (PARTITION BY t.order_id ORDER BY RANDOM()) AS item_rank
    FROM OrderTarget t
    CROSS JOIN (
        -- EXCLUSION FILTER HERE
        SELECT product_id, price 
        FROM products 
        WHERE product_id NOT IN (301, 311, 323) -- <--- ADD / REMOVE EXCLUDED IDs HERE
    ) p
)
-- Assigns unique products up to the target limit
SELECT 
    order_id,
    product_id,
    CAST((ABS(RANDOM()) % 5) + 1 AS INT) AS quantity,
    current_price AS unit_price
FROM ShuffledProducts
WHERE item_rank <= target_items;

-- ==============================================================================
-- PASO 1: GENERAR LOS 5,000 LOGS BASE EN LA TABLA
-- ==============================================================================

INSERT INTO activity_logs (user_id, action, metadata, created_at)
WITH RECURSIVE 
Config AS (
    SELECT 5000 AS total_logs
),
EventTypes AS (
    SELECT 1 AS id, 'LOGIN' AS action, '{"ip":"192.168.1.10","device":"mobile"}' AS meta UNION ALL
    SELECT 2, 'LOGOUT', '{"session_duration_sec":1240}' UNION ALL
    SELECT 3, 'VIEW_PRODUCT', '{"product_id":15,"source":"search"}' UNION ALL
    SELECT 4, 'ADD_TO_CART', '{"product_id":15,"quantity":2}' UNION ALL
    SELECT 5, 'REMOVE_FROM_CART', '{"product_id":15}' UNION ALL
    SELECT 6, 'CHECKOUT_START', '{"cart_total":150.50}' UNION ALL
    SELECT 7, 'PURCHASE_COMPLETE', '{"order_id":102,"payment_status":"SUCCESS"}' UNION ALL
    SELECT 8, 'PASSWORD_RESET', '{"method":"email"}' UNION ALL
    SELECT 9, 'PROFILE_UPDATE', '{"updated_fields":["country"]}'
),
LogIDs AS (
    SELECT 1 AS l_id, total_logs FROM Config
    UNION ALL
    SELECT l_id + 1, total_logs FROM LogIDs WHERE l_id < total_logs
)
SELECT 
    (SELECT user_id FROM users ORDER BY RANDOM() LIMIT 1) AS user_id,
    e.action,
    e.meta AS metadata,
    DATETIME('2025-01-01 08:00:00', '+' || (ABS(RANDOM()) % 500) || ' days', '+' || (ABS(RANDOM()) % 86400) || ' seconds') AS created_at
FROM LogIDs l
JOIN EventTypes e ON e.id = (ABS(RANDOM()) % 9) + 1;


-- ==============================================================================
-- PASO 2: CLONAR EXACTAMENTE 5 REGISTROS YA GUARDADOS EN LA TABLA
-- ==============================================================================

INSERT INTO activity_logs (user_id, action, metadata, created_at)
SELECT user_id, action, metadata, created_at
FROM activity_logs
ORDER BY RANDOM()
LIMIT 5;