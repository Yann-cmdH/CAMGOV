-- =====================================================
-- SCRIPT DE CRÉATION BASE DE DONNÉES VENUS PHARMA SARL
-- Système ERP Pharmaceutique Complet
-- =====================================================

-- Créer la base de données
DROP DATABASE IF EXISTS venus_pharma;
CREATE DATABASE venus_pharma 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE venus_pharma;

-- =====================================================
-- 1. TABLES DE BASE ET SÉCURITÉ
-- =====================================================

-- Table des rôles système
CREATE TABLE system_roles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    role_code VARCHAR(50) NOT NULL UNIQUE,
    role_name VARCHAR(100) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

-- Table des utilisateurs système
CREATE TABLE system_users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
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
    role_id BIGINT,
    status ENUM('PENDING', 'APPROVED', 'REJECTED', 'SUSPENDED') DEFAULT 'PENDING',
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP NULL,
    failed_login_attempts INT DEFAULT 0,
    account_locked_until TIMESTAMP NULL,
    hire_date DATE,
    salary DECIMAL(15,2),
    manager_id BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES system_roles(id),
    FOREIGN KEY (manager_id) REFERENCES system_users(id)
);

-- =====================================================
-- 2. GESTION DES PRODUITS PHARMACEUTIQUES
-- =====================================================

-- Catégories de produits
CREATE TABLE product_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    parent_id BIGINT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES product_categories(id)
);

-- Fournisseurs
CREATE TABLE suppliers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
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
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_code VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(200) NOT NULL,
    generic_name VARCHAR(200),
    description TEXT,
    dosage VARCHAR(100),
    form ENUM('TABLET', 'CAPSULE', 'SYRUP', 'INJECTION', 'CREAM', 'OINTMENT', 'DROPS', 'INHALER', 'SUPPOSITORY', 'POWDER', 'LIQUID', 'OTHER'),
    packaging VARCHAR(100),
    unit_of_measure VARCHAR(50) DEFAULT 'UNIT',
    requires_prescription BOOLEAN DEFAULT FALSE,
    storage_conditions ENUM('AMBIENT', 'REFRIGERATED', 'FROZEN'),
    purchase_price DECIMAL(15,2) NOT NULL,
    selling_price DECIMAL(15,2) NOT NULL,
    tax_rate DECIMAL(5,2) DEFAULT 0.00,
    reorder_level INT DEFAULT 10,
    reorder_quantity INT DEFAULT 50,
    wholesale_price DECIMAL(15,2) DEFAULT 0.00,
    max_stock_level INT DEFAULT 1000,
    manufacturer VARCHAR(200),
    country_of_origin VARCHAR(100),
    barcode VARCHAR(100),
    image_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    category_id BIGINT,
    supplier_id BIGINT,
    expiry_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES product_categories(id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
);

-- =====================================================
-- 3. GESTION DES STOCKS ET INVENTAIRE
-- =====================================================

-- Zones de stockage
CREATE TABLE storage_zones (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
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
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    batch_number VARCHAR(100) NOT NULL,
    product_id BIGINT NOT NULL,
    supplier_id BIGINT,
    manufacturing_date DATE,
    expiry_date DATE NOT NULL,
    quantity_received INT NOT NULL,
    quantity_remaining INT NOT NULL,
    purchase_price DECIMAL(15,2),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    UNIQUE KEY unique_batch_product (batch_number, product_id)
);

-- Inventaire
CREATE TABLE inventory (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    storage_zone_id BIGINT,
    quantity_in_stock INT DEFAULT 0,
    quantity_available INT DEFAULT 0,
    quantity_reserved INT DEFAULT 0,
    minimum_stock INT DEFAULT 10,
    maximum_stock INT DEFAULT 1000,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (storage_zone_id) REFERENCES storage_zones(id),
    UNIQUE KEY unique_product_zone (product_id, storage_zone_id)
);

-- Mouvements de stock
CREATE TABLE stock_movements (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    batch_id BIGINT,
    movement_type ENUM('IN', 'OUT', 'ADJUSTMENT', 'TRANSFER') NOT NULL,
    quantity INT NOT NULL,
    unit_cost DECIMAL(15,2),
    reference_type ENUM('PURCHASE_ORDER', 'SALE_ORDER', 'ADJUSTMENT', 'TRANSFER', 'RETURN'),
    reference_id BIGINT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (batch_id) REFERENCES product_batches(id),
    FOREIGN KEY (created_by) REFERENCES system_users(id)
);

-- =====================================================
-- 4. GESTION DES CLIENTS
-- =====================================================

-- Clients
CREATE TABLE customers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_code VARCHAR(50) UNIQUE,
    customer_type ENUM('INDIVIDUAL', 'PHARMACY', 'HOSPITAL', 'CLINIC', 'DISTRIBUTOR') NOT NULL,
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
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =====================================================
-- 5. GESTION DES COMMANDES
-- =====================================================

-- Commandes
CREATE TABLE orders (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(50) NOT NULL UNIQUE,
    customer_id BIGINT NOT NULL,
    order_date DATE NOT NULL,
    required_date DATE,
    status ENUM('DRAFT', 'PENDING', 'CONFIRMED', 'VALIDATED', 'PREPARED', 'SHIPPED', 'DELIVERED', 'CANCELLED') DEFAULT 'DRAFT',
    payment_status ENUM('PENDING', 'PARTIAL', 'PAID', 'OVERDUE') DEFAULT 'PENDING',
    subtotal_amount DECIMAL(15,2) DEFAULT 0.00,
    discount_amount DECIMAL(15,2) DEFAULT 0.00,
    tax_amount DECIMAL(15,2) DEFAULT 0.00,
    total_amount DECIMAL(15,2) DEFAULT 0.00,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by BIGINT,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (created_by) REFERENCES system_users(id)
);

-- Détails des commandes
CREATE TABLE order_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    batch_id BIGINT,
    quantity INT NOT NULL,
    unit_price DECIMAL(15,2) NOT NULL,
    discount_percent DECIMAL(5,2) DEFAULT 0.00,
    tax_rate DECIMAL(5,2) DEFAULT 0.00,
    line_total DECIMAL(15,2) NOT NULL,
    total_price DECIMAL(15,2),
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (batch_id) REFERENCES product_batches(id)
);

-- =====================================================
-- 6. GESTION FINANCIÈRE ET COMPTABILITÉ
-- =====================================================

-- Plan comptable OHADA
CREATE TABLE chart_of_accounts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    account_code VARCHAR(10) NOT NULL UNIQUE,
    account_name VARCHAR(100) NOT NULL,
    account_type ENUM('ASSET', 'LIABILITY', 'EQUITY', 'REVENUE', 'EXPENSE', 'SPECIAL') NOT NULL,
    parent_account_code VARCHAR(10),
    is_active BOOLEAN DEFAULT TRUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

-- Écritures comptables
CREATE TABLE accounting_entries (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    account_code VARCHAR(10) NOT NULL,
    account_name VARCHAR(100) NOT NULL,
    debit_amount DECIMAL(15,2) DEFAULT 0.00,
    credit_amount DECIMAL(15,2) DEFAULT 0.00,
    reference VARCHAR(50),
    description VARCHAR(255),
    entry_date DATETIME NOT NULL,
    fiscal_year INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    FOREIGN KEY (account_code) REFERENCES chart_of_accounts(account_code)
);

-- Factures
CREATE TABLE invoices (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    invoice_number VARCHAR(50) NOT NULL UNIQUE,
    order_id BIGINT,
    customer_id BIGINT NOT NULL,
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    status ENUM('DRAFT', 'SENT', 'PAID', 'OVERDUE', 'CANCELLED') DEFAULT 'DRAFT',
    subtotal_amount DECIMAL(15,2) DEFAULT 0.00,
    discount_amount DECIMAL(15,2) DEFAULT 0.00,
    tax_amount DECIMAL(15,2) DEFAULT 0.00,
    total_amount DECIMAL(15,2) NOT NULL,
    amount_paid DECIMAL(15,2) DEFAULT 0.00,
    paid_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

-- =====================================================
-- 7. DONNÉES DE BASE VENUS PHARMA SARL
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

-- Message de confirmation
SELECT 'Base de données Venus Pharma SARL créée avec succès!' as message;
SELECT 'Utilisateur par défaut: superadmin / password: admin123' as login_info;
