-- =====================================================
-- SCRIPT DE CRÉATION BASE DE DONNÉES VENUS PHARMA SARL
-- Système ERP Pharmaceutique - PostgreSQL
-- Compatible avec Heroku, Railway, Supabase, Neon
-- =====================================================

-- Créer la base de données (à exécuter séparément si nécessaire)
-- CREATE DATABASE venus_pharma;

-- Extensions PostgreSQL utiles
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================
-- 1. TABLES DE BASE ET SÉCURITÉ
-- =====================================================

-- Table des rôles système
CREATE TABLE system_roles (
    id BIGSERIAL PRIMARY KEY,
    role_code VARCHAR(50) NOT NULL UNIQUE,
    role_name VARCHAR(100) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

-- Table des utilisateurs système
CREATE TABLE system_users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    employee_id VARCHAR(50),
    job_title VARCHAR(100),
    department VARCHAR(100),
    role_id BIGINT REFERENCES system_roles(id),
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED', 'SUSPENDED')),
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP,
    failed_login_attempts INTEGER DEFAULT 0,
    account_locked_until TIMESTAMP,
    hire_date DATE,
    salary DECIMAL(15,2),
    manager_id BIGINT REFERENCES system_users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 2. GESTION DES PRODUITS PHARMACEUTIQUES
-- =====================================================

-- Catégories de produits
CREATE TABLE product_categories (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    parent_id BIGINT REFERENCES product_categories(id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Fournisseurs
CREATE TABLE suppliers (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    contact_person VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(100),
    country VARCHAR(100),
    tax_number VARCHAR(50),
    payment_terms VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Produits pharmaceutiques
CREATE TABLE products (
    id BIGSERIAL PRIMARY KEY,
    product_code VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(200) NOT NULL,
    generic_name VARCHAR(200),
    description TEXT,
    dosage VARCHAR(100),
    form VARCHAR(20) CHECK (form IN ('TABLET', 'CAPSULE', 'SYRUP', 'INJECTION', 'CREAM', 'OINTMENT', 'DROPS', 'INHALER', 'SUPPOSITORY', 'POWDER', 'LIQUID', 'OTHER')),
    packaging VARCHAR(100),
    unit_of_measure VARCHAR(50) DEFAULT 'UNIT',
    requires_prescription BOOLEAN DEFAULT FALSE,
    storage_conditions VARCHAR(20) CHECK (storage_conditions IN ('AMBIENT', 'REFRIGERATED', 'FROZEN')),
    purchase_price DECIMAL(15,2) NOT NULL,
    selling_price DECIMAL(15,2) NOT NULL,
    tax_rate DECIMAL(5,2) DEFAULT 0.00,
    reorder_level INTEGER DEFAULT 10,
    reorder_quantity INTEGER DEFAULT 50,
    wholesale_price DECIMAL(15,2) DEFAULT 0.00,
    max_stock_level INTEGER DEFAULT 1000,
    manufacturer VARCHAR(200),
    country_of_origin VARCHAR(100),
    barcode VARCHAR(100),
    image_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    category_id BIGINT REFERENCES product_categories(id),
    supplier_id BIGINT REFERENCES suppliers(id),
    expiry_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 3. GESTION DES STOCKS ET INVENTAIRE
-- =====================================================

-- Zones de stockage
CREATE TABLE storage_zones (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    temperature_min DECIMAL(5,2),
    temperature_max DECIMAL(5,2),
    humidity_min DECIMAL(5,2),
    humidity_max DECIMAL(5,2),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Lots de produits
CREATE TABLE product_batches (
    id BIGSERIAL PRIMARY KEY,
    batch_number VARCHAR(100) NOT NULL,
    product_id BIGINT NOT NULL REFERENCES products(id),
    supplier_id BIGINT REFERENCES suppliers(id),
    manufacturing_date DATE,
    expiry_date DATE NOT NULL,
    quantity_received INTEGER NOT NULL,
    quantity_remaining INTEGER NOT NULL,
    purchase_price DECIMAL(15,2),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(batch_number, product_id)
);

-- Inventaire
CREATE TABLE inventory (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL REFERENCES products(id),
    storage_zone_id BIGINT REFERENCES storage_zones(id),
    quantity_in_stock INTEGER DEFAULT 0,
    quantity_available INTEGER DEFAULT 0,
    quantity_reserved INTEGER DEFAULT 0,
    minimum_stock INTEGER DEFAULT 10,
    maximum_stock INTEGER DEFAULT 1000,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(product_id, storage_zone_id)
);

-- Mouvements de stock
CREATE TABLE stock_movements (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL REFERENCES products(id),
    batch_id BIGINT REFERENCES product_batches(id),
    movement_type VARCHAR(20) NOT NULL CHECK (movement_type IN ('IN', 'OUT', 'ADJUSTMENT', 'TRANSFER')),
    quantity INTEGER NOT NULL,
    unit_cost DECIMAL(15,2),
    reference_type VARCHAR(20) CHECK (reference_type IN ('PURCHASE_ORDER', 'SALE_ORDER', 'ADJUSTMENT', 'TRANSFER', 'RETURN')),
    reference_id BIGINT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES system_users(id)
);

-- =====================================================
-- 4. GESTION DES CLIENTS
-- =====================================================

-- Clients
CREATE TABLE customers (
    id BIGSERIAL PRIMARY KEY,
    customer_code VARCHAR(50) UNIQUE,
    customer_type VARCHAR(20) NOT NULL CHECK (customer_type IN ('INDIVIDUAL', 'PHARMACY', 'HOSPITAL', 'CLINIC', 'DISTRIBUTOR')),
    name VARCHAR(200) NOT NULL,
    company_name VARCHAR(200),
    contact_person VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(100),
    region VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) DEFAULT 'Cameroun',
    tax_number VARCHAR(50),
    license_number VARCHAR(100),
    credit_limit DECIMAL(15,2) DEFAULT 0.00,
    payment_terms VARCHAR(100) DEFAULT 'NET_30',
    discount_rate DECIMAL(5,2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 5. GESTION DES COMMANDES
-- =====================================================

-- Commandes
CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    order_number VARCHAR(50) NOT NULL UNIQUE,
    customer_id BIGINT NOT NULL REFERENCES customers(id),
    order_date DATE NOT NULL,
    required_date DATE,
    status VARCHAR(20) DEFAULT 'DRAFT' CHECK (status IN ('DRAFT', 'PENDING', 'CONFIRMED', 'VALIDATED', 'PREPARED', 'SHIPPED', 'DELIVERED', 'CANCELLED')),
    payment_status VARCHAR(20) DEFAULT 'PENDING' CHECK (payment_status IN ('PENDING', 'PARTIAL', 'PAID', 'OVERDUE')),
    subtotal_amount DECIMAL(15,2) DEFAULT 0.00,
    discount_amount DECIMAL(15,2) DEFAULT 0.00,
    tax_amount DECIMAL(15,2) DEFAULT 0.00,
    total_amount DECIMAL(15,2) DEFAULT 0.00,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES system_users(id)
);

-- Détails des commandes
CREATE TABLE order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id BIGINT NOT NULL REFERENCES products(id),
    batch_id BIGINT REFERENCES product_batches(id),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(15,2) NOT NULL,
    discount_percent DECIMAL(5,2) DEFAULT 0.00,
    tax_rate DECIMAL(5,2) DEFAULT 0.00,
    line_total DECIMAL(15,2) NOT NULL,
    total_price DECIMAL(15,2)
);

-- =====================================================
-- 6. GESTION FINANCIÈRE ET COMPTABILITÉ
-- =====================================================

-- Plan comptable OHADA
CREATE TABLE chart_of_accounts (
    id BIGSERIAL PRIMARY KEY,
    account_code VARCHAR(10) NOT NULL UNIQUE,
    account_name VARCHAR(100) NOT NULL,
    account_type VARCHAR(20) NOT NULL CHECK (account_type IN ('ASSET', 'LIABILITY', 'EQUITY', 'REVENUE', 'EXPENSE', 'SPECIAL')),
    parent_account_code VARCHAR(10),
    is_active BOOLEAN DEFAULT TRUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

-- Écritures comptables
CREATE TABLE accounting_entries (
    id BIGSERIAL PRIMARY KEY,
    account_code VARCHAR(10) NOT NULL REFERENCES chart_of_accounts(account_code),
    account_name VARCHAR(100) NOT NULL,
    debit_amount DECIMAL(15,2) DEFAULT 0.00,
    credit_amount DECIMAL(15,2) DEFAULT 0.00,
    reference VARCHAR(50),
    description VARCHAR(255),
    entry_date TIMESTAMP NOT NULL,
    fiscal_year INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100)
);

-- Factures
CREATE TABLE invoices (
    id BIGSERIAL PRIMARY KEY,
    invoice_number VARCHAR(50) NOT NULL UNIQUE,
    order_id BIGINT REFERENCES orders(id),
    customer_id BIGINT NOT NULL REFERENCES customers(id),
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'DRAFT' CHECK (status IN ('DRAFT', 'SENT', 'PAID', 'OVERDUE', 'CANCELLED')),
    subtotal_amount DECIMAL(15,2) DEFAULT 0.00,
    discount_amount DECIMAL(15,2) DEFAULT 0.00,
    tax_amount DECIMAL(15,2) DEFAULT 0.00,
    total_amount DECIMAL(15,2) NOT NULL,
    amount_paid DECIMAL(15,2) DEFAULT 0.00,
    paid_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 7. TRIGGERS POUR UPDATED_AT
-- =====================================================

-- Fonction pour mettre à jour updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers pour updated_at
CREATE TRIGGER update_system_users_updated_at BEFORE UPDATE ON system_users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON customers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_chart_of_accounts_updated_at BEFORE UPDATE ON chart_of_accounts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_invoices_updated_at BEFORE UPDATE ON invoices FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 8. DONNÉES DE BASE VENUS PHARMA SARL
-- =====================================================

-- Insertion des rôles système
INSERT INTO system_roles (role_code, role_name, description) VALUES
('SUPER_ADMIN', 'Super Administrateur', 'Accès complet au système'),
('DIRECTOR_GENERAL', 'Directeur Général', 'Direction générale et stratégie'),
('FINANCIAL_DIRECTOR', 'Directeur Financier', 'Gestion financière et comptable'),
('ADMIN', 'Administrateur', 'Administration système'),
('COMMERCIAL_MANAGER', 'Responsable Commercial', 'Gestion commerciale et ventes'),
('MEDICAL_MANAGER', 'Responsable Médical', 'Affaires médicales et pharmaceutiques'),
('LOGISTICS_MANAGER', 'Responsable Logistique', 'Gestion des stocks et livraisons'),
('QUALITY_MANAGER', 'Responsable Qualité', 'Contrôle qualité et conformité'),
('SALES_REP', 'Délégué Commercial', 'Ventes et relation client'),
('PHARMACIST', 'Pharmacien', 'Validation pharmaceutique'),
('WAREHOUSE_STAFF', 'Magasinier', 'Gestion des stocks'),
('ACCOUNTANT', 'Comptable', 'Comptabilité et finances'),
('CUSTOMER_SERVICE', 'Service Client', 'Support et service client');

-- Création du super admin par défaut
INSERT INTO system_users (username, email, password_hash, first_name, last_name, role_id, status, is_active) 
SELECT 'superadmin', 'admin@venusphar.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lbdOIGmcyIlqZp.Lm', 'Super', 'Admin', id, 'APPROVED', TRUE
FROM system_roles WHERE role_code = 'SUPER_ADMIN';

-- Plan comptable OHADA de base
INSERT INTO chart_of_accounts (account_code, account_name, account_type, description) VALUES
-- Classe 1 - Comptes de ressources durables
('10', 'Capital', 'EQUITY', 'Capital social'),
('11', 'Réserves', 'EQUITY', 'Réserves'),
('12', 'Report à nouveau', 'EQUITY', 'Report à nouveau'),
('13', 'Résultat net', 'EQUITY', 'Résultat de l''exercice'),
('16', 'Emprunts', 'LIABILITY', 'Emprunts et dettes financières'),

-- Classe 2 - Comptes d'actif immobilisé
('21', 'Immobilisations incorporelles', 'ASSET', 'Brevets, licences, logiciels'),
('22', 'Terrains', 'ASSET', 'Terrains'),
('23', 'Bâtiments', 'ASSET', 'Constructions'),
('24', 'Matériel', 'ASSET', 'Matériel et outillage'),

-- Classe 3 - Comptes de stocks
('31', 'Matières premières', 'ASSET', 'Stocks de matières premières'),
('32', 'Autres approvisionnements', 'ASSET', 'Fournitures'),
('37', 'Stocks de marchandises', 'ASSET', 'Médicaments et produits pharmaceutiques'),

-- Classe 4 - Comptes de tiers
('40', 'Fournisseurs', 'LIABILITY', 'Dettes fournisseurs'),
('41', 'Clients', 'ASSET', 'Créances clients'),
('43', 'Personnel', 'LIABILITY', 'Dettes envers le personnel'),
('44', 'État', 'LIABILITY', 'Dettes fiscales et sociales'),

-- Classe 5 - Comptes de trésorerie
('52', 'Banques', 'ASSET', 'Comptes bancaires'),
('53', 'Établissements financiers', 'ASSET', 'Autres établissements financiers'),
('57', 'Caisse', 'ASSET', 'Espèces en caisse'),

-- Classe 6 - Comptes de charges
('60', 'Achats', 'EXPENSE', 'Achats de marchandises'),
('61', 'Services extérieurs', 'EXPENSE', 'Sous-traitance, locations'),
('62', 'Autres services extérieurs', 'EXPENSE', 'Rémunérations intermédiaires'),
('63', 'Impôts et taxes', 'EXPENSE', 'Impôts, taxes et versements assimilés'),
('64', 'Charges de personnel', 'EXPENSE', 'Salaires et charges sociales'),

-- Classe 7 - Comptes de produits
('70', 'Ventes', 'REVENUE', 'Ventes de marchandises'),
('71', 'Production vendue', 'REVENUE', 'Ventes de produits finis'),
('75', 'Autres produits', 'REVENUE', 'Autres produits d''exploitation'),
('77', 'Revenus financiers', 'REVENUE', 'Produits financiers');

-- Catégories de produits pharmaceutiques
INSERT INTO product_categories (name, description) VALUES
('Médicaments génériques', 'Médicaments génériques de qualité'),
('Médicaments de marque', 'Médicaments de marque originaux'),
('Antibiotiques', 'Médicaments antibiotiques'),
('Antalgiques', 'Médicaments contre la douleur'),
('Cardiovasculaires', 'Médicaments pour le cœur'),
('Diabète', 'Médicaments antidiabétiques'),
('Respiratoires', 'Médicaments pour les voies respiratoires'),
('Dermatologiques', 'Produits pour la peau'),
('Ophtalmologiques', 'Produits pour les yeux'),
('Pédiatriques', 'Médicaments pour enfants');

-- Zones de stockage
INSERT INTO storage_zones (name, description, temperature_min, temperature_max) VALUES
('Zone Ambiante', 'Stockage à température ambiante', 15.0, 25.0),
('Zone Réfrigérée', 'Stockage réfrigéré', 2.0, 8.0),
('Zone Congelée', 'Stockage congelé', -25.0, -15.0),
('Zone Sécurisée', 'Stockage sécurisé pour produits contrôlés', 15.0, 25.0);

-- Index pour optimiser les performances
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_supplier ON products(supplier_id);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_inventory_product ON inventory(product_id);
CREATE INDEX idx_stock_movements_product ON stock_movements(product_id);
CREATE INDEX idx_accounting_entries_date ON accounting_entries(entry_date);

-- Message de confirmation
SELECT 'Base de données Venus Pharma SARL créée avec succès sur PostgreSQL!' as message;
SELECT 'Utilisateur par défaut: superadmin / password: admin123' as login_info;
