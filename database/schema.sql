-- ============================================
-- VENUS - Schéma de Base de Données
-- Système de Gestion de Distribution Pharmaceutique
-- Yaoundé, Cameroun
-- ============================================

-- Suppression des tables existantes (ordre inverse des dépendances)
DROP TABLE IF EXISTS audit_logs CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS payment_transactions CASCADE;
DROP TABLE IF EXISTS delivery_tracking CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS product_batches CASCADE;
DROP TABLE IF EXISTS stock_movements CASCADE;
DROP TABLE IF EXISTS stock_alerts CASCADE;
DROP TABLE IF EXISTS inventory CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS product_categories CASCADE;
DROP TABLE IF EXISTS suppliers CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS roles CASCADE;

-- ============================================
-- TABLE: roles
-- Gestion des rôles utilisateurs
-- ============================================
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    permissions JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLE: users
-- Utilisateurs du système
-- ============================================
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    role_id INTEGER REFERENCES roles(id),
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLE: customers
-- Clients (Pharmacies, Hôpitaux, etc.)
-- ============================================
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    customer_code VARCHAR(50) UNIQUE NOT NULL,
    customer_type VARCHAR(50) NOT NULL, -- 'PHARMACY', 'HOSPITAL', 'CLINIC', 'OTHER'
    name VARCHAR(255) NOT NULL,
    contact_person VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(20) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(100) DEFAULT 'Yaoundé',
    region VARCHAR(100),
    tax_id VARCHAR(100),
    license_number VARCHAR(100),
    credit_limit DECIMAL(15,2) DEFAULT 0,
    payment_terms INTEGER DEFAULT 30, -- jours
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLE: suppliers
-- Fournisseurs (Laboratoires, Fabricants)
-- ============================================
CREATE TABLE suppliers (
    id SERIAL PRIMARY KEY,
    supplier_code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    supplier_type VARCHAR(50) NOT NULL, -- 'LABORATORY', 'MANUFACTURER', 'WHOLESALER'
    contact_person VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(20) NOT NULL,
    address TEXT,
    city VARCHAR(100),
    country VARCHAR(100) DEFAULT 'Cameroun',
    tax_id VARCHAR(100),
    payment_terms INTEGER DEFAULT 30,
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLE: product_categories
-- Catégories de produits pharmaceutiques
-- ============================================
CREATE TABLE product_categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    parent_id INTEGER REFERENCES product_categories(id),
    requires_prescription BOOLEAN DEFAULT FALSE,
    storage_conditions VARCHAR(100), -- 'AMBIENT', 'REFRIGERATED', 'FROZEN'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLE: products
-- Produits pharmaceutiques
-- ============================================
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    product_code VARCHAR(100) UNIQUE NOT NULL,
    category_id INTEGER REFERENCES product_categories(id),
    supplier_id INTEGER REFERENCES suppliers(id),
    name VARCHAR(255) NOT NULL,
    generic_name VARCHAR(255),
    description TEXT,
    dosage VARCHAR(100),
    form VARCHAR(100), -- 'TABLET', 'CAPSULE', 'SYRUP', 'INJECTION', etc.
    packaging VARCHAR(100),
    unit_of_measure VARCHAR(50) DEFAULT 'UNIT',
    requires_prescription BOOLEAN DEFAULT FALSE,
    storage_conditions VARCHAR(100),
    purchase_price DECIMAL(15,2) NOT NULL,
    selling_price DECIMAL(15,2) NOT NULL,
    tax_rate DECIMAL(5,2) DEFAULT 0,
    reorder_level INTEGER DEFAULT 10,
    reorder_quantity INTEGER DEFAULT 50,
    is_active BOOLEAN DEFAULT TRUE,
    image_url VARCHAR(500),
    barcode VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLE: inventory
-- Inventaire principal
-- ============================================
CREATE TABLE inventory (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id) UNIQUE,
    quantity_in_stock INTEGER DEFAULT 0,
    quantity_reserved INTEGER DEFAULT 0,
    quantity_available INTEGER GENERATED ALWAYS AS (quantity_in_stock - quantity_reserved) STORED,
    minimum_stock INTEGER DEFAULT 10,
    maximum_stock INTEGER DEFAULT 1000,
    last_restock_date TIMESTAMP,
    last_count_date TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLE: product_batches
-- Lots de produits (traçabilité)
-- ============================================
CREATE TABLE product_batches (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id),
    batch_number VARCHAR(100) NOT NULL,
    manufacturing_date DATE NOT NULL,
    expiry_date DATE NOT NULL,
    quantity_received INTEGER NOT NULL,
    quantity_remaining INTEGER NOT NULL,
    supplier_id INTEGER REFERENCES suppliers(id),
    purchase_price DECIMAL(15,2),
    storage_location VARCHAR(100),
    quality_status VARCHAR(50) DEFAULT 'APPROVED', -- 'APPROVED', 'QUARANTINE', 'REJECTED'
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(product_id, batch_number)
);

-- ============================================
-- TABLE: stock_movements
-- Mouvements de stock
-- ============================================
CREATE TABLE stock_movements (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id),
    batch_id INTEGER REFERENCES product_batches(id),
    movement_type VARCHAR(50) NOT NULL, -- 'IN', 'OUT', 'ADJUSTMENT', 'RETURN', 'EXPIRED'
    quantity INTEGER NOT NULL,
    reference_type VARCHAR(50), -- 'ORDER', 'PURCHASE', 'ADJUSTMENT', 'RETURN'
    reference_id INTEGER,
    user_id INTEGER REFERENCES users(id),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLE: stock_alerts
-- Alertes de stock
-- ============================================
CREATE TABLE stock_alerts (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id),
    alert_type VARCHAR(50) NOT NULL, -- 'LOW_STOCK', 'OUT_OF_STOCK', 'EXPIRING_SOON', 'EXPIRED'
    severity VARCHAR(20) DEFAULT 'MEDIUM', -- 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL'
    message TEXT NOT NULL,
    is_resolved BOOLEAN DEFAULT FALSE,
    resolved_by INTEGER REFERENCES users(id),
    resolved_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLE: orders
-- Commandes clients
-- ============================================
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id INTEGER REFERENCES customers(id),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    required_date DATE,
    status VARCHAR(50) DEFAULT 'PENDING', -- 'PENDING', 'CONFIRMED', 'PROCESSING', 'SHIPPED', 'DELIVERED', 'CANCELLED'
    priority VARCHAR(20) DEFAULT 'NORMAL', -- 'LOW', 'NORMAL', 'HIGH', 'URGENT'
    subtotal DECIMAL(15,2) DEFAULT 0,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    shipping_cost DECIMAL(15,2) DEFAULT 0,
    total_amount DECIMAL(15,2) DEFAULT 0,
    payment_status VARCHAR(50) DEFAULT 'PENDING', -- 'PENDING', 'PARTIAL', 'PAID', 'OVERDUE'
    payment_method VARCHAR(50), -- 'CASH', 'BANK_TRANSFER', 'MOBILE_MONEY', 'CREDIT'
    delivery_address TEXT,
    delivery_instructions TEXT,
    created_by INTEGER REFERENCES users(id),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLE: order_items
-- Détails des commandes
-- ============================================
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(id),
    batch_id INTEGER REFERENCES product_batches(id),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(15,2) NOT NULL,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    tax_rate DECIMAL(5,2) DEFAULT 0,
    line_total DECIMAL(15,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLE: delivery_tracking
-- Suivi des livraisons
-- ============================================
CREATE TABLE delivery_tracking (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id),
    status VARCHAR(50) NOT NULL, -- 'PREPARING', 'IN_TRANSIT', 'DELIVERED', 'FAILED'
    driver_name VARCHAR(255),
    vehicle_number VARCHAR(50),
    departure_time TIMESTAMP,
    arrival_time TIMESTAMP,
    recipient_name VARCHAR(255),
    recipient_signature TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLE: payment_transactions
-- Transactions de paiement
-- ============================================
CREATE TABLE payment_transactions (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id),
    transaction_number VARCHAR(100) UNIQUE NOT NULL,
    payment_method VARCHAR(50) NOT NULL, -- 'CASH', 'BANK_TRANSFER', 'MTN_MOMO', 'ORANGE_MONEY'
    amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'XAF',
    status VARCHAR(50) DEFAULT 'PENDING', -- 'PENDING', 'COMPLETED', 'FAILED', 'REFUNDED'
    reference_number VARCHAR(255),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLE: notifications
-- Notifications système
-- ============================================
CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    type VARCHAR(50) NOT NULL, -- 'ALERT', 'INFO', 'WARNING', 'ERROR'
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    link VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLE: audit_logs
-- Logs d'audit
-- ============================================
CREATE TABLE audit_logs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    table_name VARCHAR(100),
    record_id INTEGER,
    old_values JSONB,
    new_values JSONB,
    ip_address VARCHAR(50),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- INDEXES pour optimisation
-- ============================================
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_customers_code ON customers(customer_code);
CREATE INDEX idx_customers_type ON customers(customer_type);
CREATE INDEX idx_products_code ON products(product_code);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_batches_expiry ON product_batches(expiry_date);
CREATE INDEX idx_batches_product ON product_batches(product_id);
CREATE INDEX idx_orders_number ON orders(order_number);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_stock_movements_product ON stock_movements(product_id);
CREATE INDEX idx_stock_movements_date ON stock_movements(created_at);
CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_date ON audit_logs(created_at);

-- ============================================
-- FIN DU SCHÉMA
-- ============================================

