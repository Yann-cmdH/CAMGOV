-- ============================================
-- VENUS - BASE DE DONNÉES COMPLÈTE MYSQL
-- Système de Gestion de Distribution Pharmaceutique
-- Entreprise: VENUS - Yaoundé, Cameroun
-- ============================================
-- Date: Janvier 2025
-- Version: 1.0 PRODUCTION
-- ============================================

-- ÉTAPE 1: Créer la base de données
DROP DATABASE IF EXISTS venus_db;
CREATE DATABASE venus_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE venus_db;

-- ============================================
-- MODULE 1: GESTION DES UTILISATEURS & SÉCURITÉ
-- ============================================

-- Table: roles (Rôles utilisateurs)
CREATE TABLE roles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL COMMENT 'Code unique du rôle',
    name VARCHAR(100) NOT NULL COMMENT 'Nom du rôle',
    description TEXT COMMENT 'Description du rôle',
    permissions JSON COMMENT 'Permissions JSON',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_role_code (code)
) ENGINE=InnoDB COMMENT='Rôles utilisateurs du système';

-- Table: users (Utilisateurs du système)
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    role_id BIGINT NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL COMMENT 'Hash BCrypt du mot de passe',
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    photo_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    is_locked BOOLEAN DEFAULT FALSE COMMENT 'Compte verrouillé',
    failed_login_attempts INT DEFAULT 0,
    last_login TIMESTAMP NULL,
    last_password_change TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(id),
    INDEX idx_user_email (email),
    INDEX idx_user_username (username),
    INDEX idx_user_active (is_active)
) ENGINE=InnoDB COMMENT='Utilisateurs du système VENUS';

-- ============================================
-- MODULE 2: GESTION DES PARTENAIRES
-- ============================================

-- Table: customers (Clients B2B)
CREATE TABLE customers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_code VARCHAR(50) UNIQUE NOT NULL COMMENT 'Code client unique',
    customer_type ENUM('PHARMACY', 'HOSPITAL', 'CLINIC', 'WHOLESALER', 'OTHER') NOT NULL,
    company_name VARCHAR(255) NOT NULL COMMENT 'Nom de l\'établissement',
    contact_person VARCHAR(255) COMMENT 'Personne de contact',
    email VARCHAR(255),
    phone VARCHAR(20) NOT NULL,
    phone_secondary VARCHAR(20),
    address TEXT NOT NULL,
    city VARCHAR(100) DEFAULT 'Yaoundé',
    region VARCHAR(100),
    country VARCHAR(100) DEFAULT 'Cameroun',
    postal_code VARCHAR(20),
    tax_id VARCHAR(100) COMMENT 'Numéro contribuable',
    license_number VARCHAR(100) COMMENT 'Numéro licence pharmaceutique',
    credit_limit DECIMAL(15,2) DEFAULT 0 COMMENT 'Limite de crédit en FCFA',
    current_balance DECIMAL(15,2) DEFAULT 0 COMMENT 'Solde actuel',
    payment_terms INT DEFAULT 30 COMMENT 'Délai de paiement en jours',
    discount_rate DECIMAL(5,2) DEFAULT 0 COMMENT 'Taux de remise %',
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE COMMENT 'Client vérifié',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_customer_code (customer_code),
    INDEX idx_customer_type (customer_type),
    INDEX idx_customer_active (is_active),
    INDEX idx_customer_city (city)
) ENGINE=InnoDB COMMENT='Clients B2B (Pharmacies, Hôpitaux, Cliniques)';

-- Table: suppliers (Fournisseurs/Laboratoires)
CREATE TABLE suppliers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    supplier_code VARCHAR(50) UNIQUE NOT NULL,
    supplier_type ENUM('LABORATORY', 'MANUFACTURER', 'WHOLESALER', 'IMPORTER') NOT NULL,
    company_name VARCHAR(255) NOT NULL,
    contact_person VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(20) NOT NULL,
    address TEXT,
    city VARCHAR(100),
    country VARCHAR(100) DEFAULT 'Cameroun',
    tax_id VARCHAR(100),
    payment_terms INT DEFAULT 30,
    is_active BOOLEAN DEFAULT TRUE,
    rating DECIMAL(3,2) DEFAULT 0 COMMENT 'Note fournisseur 0-5',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_supplier_code (supplier_code),
    INDEX idx_supplier_type (supplier_type),
    INDEX idx_supplier_active (is_active)
) ENGINE=InnoDB COMMENT='Fournisseurs et Laboratoires pharmaceutiques';

-- ============================================
-- MODULE 3: GESTION DU CATALOGUE PRODUITS
-- ============================================

-- Table: product_categories (Catégories de produits)
CREATE TABLE product_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    parent_id BIGINT COMMENT 'Catégorie parente pour hiérarchie',
    requires_prescription BOOLEAN DEFAULT FALSE,
    storage_conditions ENUM('AMBIENT', 'REFRIGERATED', 'FROZEN', 'CONTROLLED') DEFAULT 'AMBIENT',
    image_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES product_categories(id),
    INDEX idx_category_code (code),
    INDEX idx_category_active (is_active)
) ENGINE=InnoDB COMMENT='Catégories de produits pharmaceutiques';

-- Table: products (Produits pharmaceutiques)
CREATE TABLE products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_code VARCHAR(100) UNIQUE NOT NULL COMMENT 'Code produit unique',
    category_id BIGINT NOT NULL,
    supplier_id BIGINT,
    name VARCHAR(255) NOT NULL COMMENT 'Nom commercial',
    generic_name VARCHAR(255) COMMENT 'Dénomination commune internationale (DCI)',
    description TEXT,
    dosage VARCHAR(100) COMMENT 'Ex: 500mg, 10mg/ml',
    form ENUM('TABLET', 'CAPSULE', 'SYRUP', 'INJECTION', 'CREAM', 'OINTMENT', 'DROPS', 'INHALER', 'SUPPOSITORY', 'POWDER', 'SOLUTION', 'OTHER') NOT NULL,
    packaging VARCHAR(100) COMMENT 'Ex: Boîte de 20, Flacon 100ml',
    unit_of_measure VARCHAR(50) DEFAULT 'UNIT' COMMENT 'Unité de mesure',
    requires_prescription BOOLEAN DEFAULT FALSE,
    storage_conditions ENUM('AMBIENT', 'REFRIGERATED', 'FROZEN', 'CONTROLLED') DEFAULT 'AMBIENT',
    purchase_price DECIMAL(15,2) NOT NULL COMMENT 'Prix d\'achat HT',
    selling_price DECIMAL(15,2) NOT NULL COMMENT 'Prix de vente HT',
    wholesale_price DECIMAL(15,2) COMMENT 'Prix de gros',
    tax_rate DECIMAL(5,2) DEFAULT 19.00 COMMENT 'TVA %',
    reorder_level INT DEFAULT 10 COMMENT 'Seuil de réapprovisionnement',
    reorder_quantity INT DEFAULT 50 COMMENT 'Quantité de réapprovisionnement',
    max_stock_level INT DEFAULT 1000,
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE COMMENT 'Produit vedette',
    image_url VARCHAR(500),
    barcode VARCHAR(100) UNIQUE COMMENT 'Code-barres EAN13',
    manufacturer VARCHAR(255) COMMENT 'Fabricant',
    country_of_origin VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES product_categories(id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    INDEX idx_product_code (product_code),
    INDEX idx_product_name (name),
    INDEX idx_product_category (category_id),
    INDEX idx_product_barcode (barcode),
    INDEX idx_product_active (is_active),
    FULLTEXT idx_product_search (name, generic_name, description)
) ENGINE=InnoDB COMMENT='Catalogue de produits pharmaceutiques';

-- ============================================
-- MODULE 4: GESTION DES STOCKS & TRAÇABILITÉ
-- ============================================

-- Table: storage_zones (Zones de stockage dans l'entrepôt)
CREATE TABLE storage_zones (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    zone_type ENUM('AMBIENT', 'REFRIGERATED', 'FROZEN', 'QUARANTINE', 'RETURNS') NOT NULL,
    capacity INT COMMENT 'Capacité maximale',
    temperature_min DECIMAL(5,2) COMMENT 'Température min °C',
    temperature_max DECIMAL(5,2) COMMENT 'Température max °C',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_zone_code (code),
    INDEX idx_zone_type (zone_type)
) ENGINE=InnoDB COMMENT='Zones de stockage dans l\'entrepôt';

-- Table: product_batches (Lots de produits - TRAÇABILITÉ)
CREATE TABLE product_batches (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    batch_number VARCHAR(100) NOT NULL COMMENT 'Numéro de lot fabricant',
    supplier_id BIGINT,
    storage_zone_id BIGINT,
    manufacturing_date DATE NOT NULL,
    expiry_date DATE NOT NULL,
    quantity_received INT NOT NULL,
    quantity_remaining INT NOT NULL,
    purchase_price DECIMAL(15,2) COMMENT 'Prix d\'achat du lot',
    quality_status ENUM('APPROVED', 'QUARANTINE', 'REJECTED', 'RECALLED') DEFAULT 'APPROVED',
    quality_check_date TIMESTAMP NULL,
    quality_checked_by BIGINT COMMENT 'ID utilisateur',
    storage_location VARCHAR(100) COMMENT 'Emplacement précis',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    FOREIGN KEY (storage_zone_id) REFERENCES storage_zones(id),
    FOREIGN KEY (quality_checked_by) REFERENCES users(id),
    UNIQUE KEY unique_product_batch (product_id, batch_number),
    INDEX idx_batch_product (product_id),
    INDEX idx_batch_expiry (expiry_date),
    INDEX idx_batch_status (quality_status)
) ENGINE=InnoDB COMMENT='Lots de produits avec traçabilité complète';

-- Table: inventory (Inventaire global par produit)
CREATE TABLE inventory (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT UNIQUE NOT NULL,
    quantity_in_stock INT DEFAULT 0 COMMENT 'Quantité totale en stock',
    quantity_reserved INT DEFAULT 0 COMMENT 'Quantité réservée (commandes)',
    quantity_available INT GENERATED ALWAYS AS (quantity_in_stock - quantity_reserved) STORED,
    minimum_stock INT DEFAULT 10,
    maximum_stock INT DEFAULT 1000,
    last_restock_date TIMESTAMP NULL,
    last_count_date TIMESTAMP NULL COMMENT 'Dernier inventaire physique',
    last_count_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (last_count_by) REFERENCES users(id),
    INDEX idx_inventory_product (product_id),
    INDEX idx_inventory_low_stock (quantity_in_stock, minimum_stock)
) ENGINE=InnoDB COMMENT='Inventaire global par produit';

-- Table: stock_movements (Mouvements de stock)
CREATE TABLE stock_movements (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    batch_id BIGINT,
    movement_type ENUM('IN', 'OUT', 'ADJUSTMENT', 'TRANSFER', 'RETURN', 'LOSS', 'EXPIRED') NOT NULL,
    quantity INT NOT NULL COMMENT 'Quantité (+ ou -)',
    reference_type VARCHAR(50) COMMENT 'Type de référence: ORDER, PURCHASE, ADJUSTMENT',
    reference_id BIGINT COMMENT 'ID de la référence',
    from_zone_id BIGINT,
    to_zone_id BIGINT,
    unit_cost DECIMAL(15,2) COMMENT 'Coût unitaire',
    total_cost DECIMAL(15,2) COMMENT 'Coût total du mouvement',
    user_id BIGINT NOT NULL COMMENT 'Utilisateur ayant effectué le mouvement',
    reason TEXT COMMENT 'Raison du mouvement',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (batch_id) REFERENCES product_batches(id),
    FOREIGN KEY (from_zone_id) REFERENCES storage_zones(id),
    FOREIGN KEY (to_zone_id) REFERENCES storage_zones(id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_movement_product (product_id),
    INDEX idx_movement_batch (batch_id),
    INDEX idx_movement_type (movement_type),
    INDEX idx_movement_date (created_at),
    INDEX idx_movement_reference (reference_type, reference_id)
) ENGINE=InnoDB COMMENT='Historique de tous les mouvements de stock';

-- Table: stock_alerts (Alertes de stock)
CREATE TABLE stock_alerts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT,
    batch_id BIGINT,
    alert_type ENUM('LOW_STOCK', 'OUT_OF_STOCK', 'EXPIRING_SOON', 'EXPIRED', 'OVERSTOCK', 'QUALITY_ISSUE') NOT NULL,
    severity ENUM('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') DEFAULT 'MEDIUM',
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    is_resolved BOOLEAN DEFAULT FALSE,
    resolved_by BIGINT,
    resolved_at TIMESTAMP NULL,
    resolution_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (batch_id) REFERENCES product_batches(id),
    FOREIGN KEY (resolved_by) REFERENCES users(id),
    INDEX idx_alert_product (product_id),
    INDEX idx_alert_type (alert_type),
    INDEX idx_alert_severity (severity),
    INDEX idx_alert_resolved (is_resolved),
    INDEX idx_alert_date (created_at)
) ENGINE=InnoDB COMMENT='Alertes automatiques de gestion de stock';

-- ============================================
-- MODULE 5: GESTION DES COMMANDES
-- ============================================

-- Table: orders (Commandes clients)
CREATE TABLE orders (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL COMMENT 'Numéro de commande unique',
    customer_id BIGINT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    required_date DATE COMMENT 'Date de livraison souhaitée',
    shipped_date TIMESTAMP NULL,
    delivered_date TIMESTAMP NULL,
    status ENUM('DRAFT', 'PENDING', 'CONFIRMED', 'PROCESSING', 'READY', 'SHIPPED', 'DELIVERED', 'CANCELLED', 'RETURNED') DEFAULT 'PENDING',
    priority ENUM('LOW', 'NORMAL', 'HIGH', 'URGENT') DEFAULT 'NORMAL',
    subtotal DECIMAL(15,2) DEFAULT 0 COMMENT 'Sous-total HT',
    tax_amount DECIMAL(15,2) DEFAULT 0 COMMENT 'Montant TVA',
    discount_amount DECIMAL(15,2) DEFAULT 0 COMMENT 'Montant remise',
    shipping_cost DECIMAL(15,2) DEFAULT 0 COMMENT 'Frais de livraison',
    total_amount DECIMAL(15,2) DEFAULT 0 COMMENT 'Montant total TTC',
    payment_status ENUM('PENDING', 'PARTIAL', 'PAID', 'OVERDUE', 'REFUNDED') DEFAULT 'PENDING',
    payment_method ENUM('CASH', 'BANK_TRANSFER', 'MTN_MOMO', 'ORANGE_MONEY', 'CREDIT', 'CHEQUE') NULL,
    delivery_address TEXT,
    delivery_city VARCHAR(100),
    delivery_region VARCHAR(100),
    delivery_instructions TEXT,
    tracking_number VARCHAR(100) COMMENT 'Numéro de suivi livraison',
    created_by BIGINT NOT NULL COMMENT 'Utilisateur créateur',
    assigned_to BIGINT COMMENT 'Préparateur assigné',
    notes TEXT,
    internal_notes TEXT COMMENT 'Notes internes non visibles client',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (assigned_to) REFERENCES users(id),
    INDEX idx_order_number (order_number),
    INDEX idx_order_customer (customer_id),
    INDEX idx_order_status (status),
    INDEX idx_order_payment_status (payment_status),
    INDEX idx_order_date (order_date),
    INDEX idx_order_created_by (created_by)
) ENGINE=InnoDB COMMENT='Commandes clients';

-- Table: order_items (Lignes de commande)
CREATE TABLE order_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    batch_id BIGINT COMMENT 'Lot assigné lors de la préparation',
    quantity INT NOT NULL,
    unit_price DECIMAL(15,2) NOT NULL COMMENT 'Prix unitaire HT',
    discount_percent DECIMAL(5,2) DEFAULT 0,
    tax_rate DECIMAL(5,2) DEFAULT 19.00,
    line_total DECIMAL(15,2) NOT NULL COMMENT 'Total ligne TTC',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (batch_id) REFERENCES product_batches(id),
    INDEX idx_order_item_order (order_id),
    INDEX idx_order_item_product (product_id)
) ENGINE=InnoDB COMMENT='Détails des lignes de commande';

-- Table: delivery_tracking (Suivi des livraisons)
CREATE TABLE delivery_tracking (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    status ENUM('PREPARING', 'READY', 'IN_TRANSIT', 'DELIVERED', 'FAILED', 'RETURNED') NOT NULL,
    driver_name VARCHAR(255),
    driver_phone VARCHAR(20),
    vehicle_number VARCHAR(50),
    departure_time TIMESTAMP NULL,
    estimated_arrival TIMESTAMP NULL,
    actual_arrival TIMESTAMP NULL,
    recipient_name VARCHAR(255),
    recipient_signature TEXT COMMENT 'Signature numérique base64',
    delivery_proof_url VARCHAR(500) COMMENT 'Photo de livraison',
    latitude DECIMAL(10,8) COMMENT 'Coordonnées GPS',
    longitude DECIMAL(11,8),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    INDEX idx_delivery_order (order_id),
    INDEX idx_delivery_status (status)
) ENGINE=InnoDB COMMENT='Suivi détaillé des livraisons';

-- ============================================
-- MODULE 6: GESTION FINANCIÈRE
-- ============================================

-- Table: payment_transactions (Transactions de paiement)
CREATE TABLE payment_transactions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    transaction_number VARCHAR(100) UNIQUE NOT NULL,
    order_id BIGINT,
    customer_id BIGINT NOT NULL,
    payment_method ENUM('CASH', 'BANK_TRANSFER', 'MTN_MOMO', 'ORANGE_MONEY', 'CREDIT', 'CHEQUE') NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'XAF',
    status ENUM('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED', 'CANCELLED', 'REFUNDED') DEFAULT 'PENDING',
    reference_number VARCHAR(255) COMMENT 'Référence externe (banque, mobile money)',
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_by BIGINT COMMENT 'Utilisateur ayant traité',
    notes TEXT,
    metadata JSON COMMENT 'Données supplémentaires (réponse API paiement)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (processed_by) REFERENCES users(id),
    INDEX idx_payment_transaction_number (transaction_number),
    INDEX idx_payment_order (order_id),
    INDEX idx_payment_customer (customer_id),
    INDEX idx_payment_status (status),
    INDEX idx_payment_date (payment_date)
) ENGINE=InnoDB COMMENT='Transactions de paiement';

-- Table: invoices (Factures)
CREATE TABLE invoices (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    order_id BIGINT NOT NULL,
    customer_id BIGINT NOT NULL,
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    subtotal DECIMAL(15,2) NOT NULL,
    tax_amount DECIMAL(15,2) NOT NULL,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    total_amount DECIMAL(15,2) NOT NULL,
    amount_paid DECIMAL(15,2) DEFAULT 0,
    balance_due DECIMAL(15,2) GENERATED ALWAYS AS (total_amount - amount_paid) STORED,
    status ENUM('DRAFT', 'SENT', 'PAID', 'PARTIAL', 'OVERDUE', 'CANCELLED') DEFAULT 'DRAFT',
    pdf_url VARCHAR(500) COMMENT 'URL du PDF généré',
    sent_date TIMESTAMP NULL,
    paid_date TIMESTAMP NULL,
    notes TEXT,
    created_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    INDEX idx_invoice_number (invoice_number),
    INDEX idx_invoice_order (order_id),
    INDEX idx_invoice_customer (customer_id),
    INDEX idx_invoice_status (status),
    INDEX idx_invoice_due_date (due_date)
) ENGINE=InnoDB COMMENT='Factures clients';

-- ============================================
-- MODULE 7: GESTION QUALITÉ & RETOURS
-- ============================================

-- Table: product_recalls (Rappels de lots)
CREATE TABLE product_recalls (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    recall_number VARCHAR(50) UNIQUE NOT NULL,
    product_id BIGINT,
    batch_id BIGINT,
    recall_type ENUM('VOLUNTARY', 'MANDATORY', 'PRECAUTIONARY') NOT NULL,
    severity ENUM('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') NOT NULL,
    reason TEXT NOT NULL,
    recall_date DATE NOT NULL,
    affected_quantity INT,
    recovered_quantity INT DEFAULT 0,
    status ENUM('INITIATED', 'IN_PROGRESS', 'COMPLETED', 'CLOSED') DEFAULT 'INITIATED',
    authority_reference VARCHAR(255) COMMENT 'Référence autorité sanitaire',
    initiated_by BIGINT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (batch_id) REFERENCES product_batches(id),
    FOREIGN KEY (initiated_by) REFERENCES users(id),
    INDEX idx_recall_number (recall_number),
    INDEX idx_recall_product (product_id),
    INDEX idx_recall_batch (batch_id),
    INDEX idx_recall_status (status)
) ENGINE=InnoDB COMMENT='Rappels de produits/lots';

-- Table: product_returns (Retours de produits)
CREATE TABLE product_returns (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    return_number VARCHAR(50) UNIQUE NOT NULL,
    order_id BIGINT,
    customer_id BIGINT NOT NULL,
    return_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    return_type ENUM('DEFECTIVE', 'EXPIRED', 'DAMAGED', 'WRONG_PRODUCT', 'CUSTOMER_REQUEST', 'OTHER') NOT NULL,
    status ENUM('REQUESTED', 'APPROVED', 'REJECTED', 'RECEIVED', 'REFUNDED', 'COMPLETED') DEFAULT 'REQUESTED',
    total_amount DECIMAL(15,2),
    refund_amount DECIMAL(15,2),
    refund_method ENUM('CASH', 'BANK_TRANSFER', 'CREDIT_NOTE', 'REPLACEMENT') NULL,
    reason TEXT NOT NULL,
    resolution TEXT,
    approved_by BIGINT,
    processed_by BIGINT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (approved_by) REFERENCES users(id),
    FOREIGN KEY (processed_by) REFERENCES users(id),
    INDEX idx_return_number (return_number),
    INDEX idx_return_order (order_id),
    INDEX idx_return_customer (customer_id),
    INDEX idx_return_status (status)
) ENGINE=InnoDB COMMENT='Retours de produits clients';

-- Table: return_items (Détails des retours)
CREATE TABLE return_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    return_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    batch_id BIGINT,
    quantity INT NOT NULL,
    unit_price DECIMAL(15,2),
    line_total DECIMAL(15,2),
    condition_received ENUM('GOOD', 'DAMAGED', 'EXPIRED', 'DEFECTIVE') NOT NULL,
    action_taken ENUM('REFUND', 'REPLACE', 'CREDIT', 'DISPOSE') NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (return_id) REFERENCES product_returns(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (batch_id) REFERENCES product_batches(id),
    INDEX idx_return_item_return (return_id),
    INDEX idx_return_item_product (product_id)
) ENGINE=InnoDB COMMENT='Détails des lignes de retour';

-- ============================================
-- MODULE 8: ACHATS & APPROVISIONNEMENT
-- ============================================

-- Table: purchase_orders (Bons de commande fournisseurs)
CREATE TABLE purchase_orders (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    po_number VARCHAR(50) UNIQUE NOT NULL COMMENT 'Numéro bon de commande',
    supplier_id BIGINT NOT NULL,
    order_date DATE NOT NULL,
    expected_delivery_date DATE,
    actual_delivery_date DATE NULL,
    status ENUM('DRAFT', 'SENT', 'CONFIRMED', 'PARTIAL', 'RECEIVED', 'CANCELLED') DEFAULT 'DRAFT',
    subtotal DECIMAL(15,2) DEFAULT 0,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    shipping_cost DECIMAL(15,2) DEFAULT 0,
    total_amount DECIMAL(15,2) DEFAULT 0,
    payment_terms INT DEFAULT 30,
    payment_status ENUM('PENDING', 'PARTIAL', 'PAID') DEFAULT 'PENDING',
    created_by BIGINT NOT NULL,
    approved_by BIGINT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (approved_by) REFERENCES users(id),
    INDEX idx_po_number (po_number),
    INDEX idx_po_supplier (supplier_id),
    INDEX idx_po_status (status),
    INDEX idx_po_date (order_date)
) ENGINE=InnoDB COMMENT='Bons de commande fournisseurs';

-- Table: purchase_order_items (Lignes de commande fournisseur)
CREATE TABLE purchase_order_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    purchase_order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity_ordered INT NOT NULL,
    quantity_received INT DEFAULT 0,
    unit_price DECIMAL(15,2) NOT NULL,
    tax_rate DECIMAL(5,2) DEFAULT 19.00,
    line_total DECIMAL(15,2) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    INDEX idx_po_item_po (purchase_order_id),
    INDEX idx_po_item_product (product_id)
) ENGINE=InnoDB COMMENT='Détails des commandes fournisseurs';

-- Table: goods_receipts (Réceptions de marchandises)
CREATE TABLE goods_receipts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    receipt_number VARCHAR(50) UNIQUE NOT NULL,
    purchase_order_id BIGINT,
    supplier_id BIGINT NOT NULL,
    receipt_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    delivery_note_number VARCHAR(100) COMMENT 'Numéro bon de livraison fournisseur',
    status ENUM('PENDING', 'PARTIAL', 'COMPLETE', 'QUALITY_CHECK', 'APPROVED', 'REJECTED') DEFAULT 'PENDING',
    received_by BIGINT NOT NULL,
    checked_by BIGINT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders(id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    FOREIGN KEY (received_by) REFERENCES users(id),
    FOREIGN KEY (checked_by) REFERENCES users(id),
    INDEX idx_receipt_number (receipt_number),
    INDEX idx_receipt_po (purchase_order_id),
    INDEX idx_receipt_supplier (supplier_id)
) ENGINE=InnoDB COMMENT='Réceptions de marchandises';

-- Table: goods_receipt_items (Détails réceptions)
CREATE TABLE goods_receipt_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    goods_receipt_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    batch_id BIGINT COMMENT 'Lot créé lors de la réception',
    quantity_expected INT,
    quantity_received INT NOT NULL,
    quantity_accepted INT,
    quantity_rejected INT DEFAULT 0,
    unit_cost DECIMAL(15,2),
    rejection_reason TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (goods_receipt_id) REFERENCES goods_receipts(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (batch_id) REFERENCES product_batches(id),
    INDEX idx_receipt_item_receipt (goods_receipt_id),
    INDEX idx_receipt_item_product (product_id)
) ENGINE=InnoDB COMMENT='Détails des réceptions de marchandises';

-- ============================================
-- MODULE 9: NOTIFICATIONS & COMMUNICATIONS
-- ============================================

-- Table: notifications (Notifications système)
CREATE TABLE notifications (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT,
    notification_type ENUM('INFO', 'WARNING', 'ERROR', 'SUCCESS', 'ALERT') NOT NULL,
    category ENUM('STOCK', 'ORDER', 'PAYMENT', 'SYSTEM', 'QUALITY', 'DELIVERY') NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    link VARCHAR(500) COMMENT 'Lien vers la ressource concernée',
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL,
    priority ENUM('LOW', 'NORMAL', 'HIGH', 'URGENT') DEFAULT 'NORMAL',
    expires_at TIMESTAMP NULL COMMENT 'Date d\'expiration de la notification',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_notification_user (user_id),
    INDEX idx_notification_read (is_read),
    INDEX idx_notification_type (notification_type),
    INDEX idx_notification_date (created_at)
) ENGINE=InnoDB COMMENT='Notifications utilisateurs';

-- Table: email_logs (Logs des emails envoyés)
CREATE TABLE email_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    recipient_email VARCHAR(255) NOT NULL,
    recipient_name VARCHAR(255),
    subject VARCHAR(500) NOT NULL,
    email_type ENUM('ORDER_CONFIRMATION', 'INVOICE', 'DELIVERY', 'ALERT', 'MARKETING', 'SYSTEM') NOT NULL,
    status ENUM('PENDING', 'SENT', 'FAILED', 'BOUNCED') DEFAULT 'PENDING',
    sent_at TIMESTAMP NULL,
    error_message TEXT,
    reference_type VARCHAR(50) COMMENT 'Type de référence: ORDER, INVOICE',
    reference_id BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_email_recipient (recipient_email),
    INDEX idx_email_status (status),
    INDEX idx_email_type (email_type),
    INDEX idx_email_date (created_at)
) ENGINE=InnoDB COMMENT='Historique des emails envoyés';

-- Table: sms_logs (Logs des SMS envoyés)
CREATE TABLE sms_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    phone_number VARCHAR(20) NOT NULL,
    message TEXT NOT NULL,
    sms_type ENUM('ORDER', 'DELIVERY', 'PAYMENT', 'ALERT', 'OTP', 'MARKETING') NOT NULL,
    status ENUM('PENDING', 'SENT', 'FAILED', 'DELIVERED') DEFAULT 'PENDING',
    provider VARCHAR(50) COMMENT 'Fournisseur SMS',
    provider_message_id VARCHAR(255),
    cost DECIMAL(10,4) COMMENT 'Coût du SMS',
    sent_at TIMESTAMP NULL,
    delivered_at TIMESTAMP NULL,
    error_message TEXT,
    reference_type VARCHAR(50),
    reference_id BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_sms_phone (phone_number),
    INDEX idx_sms_status (status),
    INDEX idx_sms_type (sms_type),
    INDEX idx_sms_date (created_at)
) ENGINE=InnoDB COMMENT='Historique des SMS envoyés';

-- ============================================
-- MODULE 10: AUDIT & SÉCURITÉ
-- ============================================

-- Table: audit_logs (Logs d'audit complets)
CREATE TABLE audit_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT,
    action VARCHAR(100) NOT NULL COMMENT 'Action effectuée: CREATE, UPDATE, DELETE, LOGIN',
    entity_type VARCHAR(100) COMMENT 'Type d\'entité: Product, Order, User',
    entity_id BIGINT COMMENT 'ID de l\'entité',
    old_values JSON COMMENT 'Anciennes valeurs',
    new_values JSON COMMENT 'Nouvelles valeurs',
    ip_address VARCHAR(50),
    user_agent TEXT,
    session_id VARCHAR(255),
    request_url VARCHAR(500),
    http_method VARCHAR(10),
    status_code INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_audit_user (user_id),
    INDEX idx_audit_action (action),
    INDEX idx_audit_entity (entity_type, entity_id),
    INDEX idx_audit_date (created_at)
) ENGINE=InnoDB COMMENT='Logs d\'audit pour traçabilité complète';

-- Table: login_attempts (Tentatives de connexion)
CREATE TABLE login_attempts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    ip_address VARCHAR(50) NOT NULL,
    user_agent TEXT,
    success BOOLEAN NOT NULL,
    failure_reason VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_login_username (username),
    INDEX idx_login_ip (ip_address),
    INDEX idx_login_success (success),
    INDEX idx_login_date (created_at)
) ENGINE=InnoDB COMMENT='Historique des tentatives de connexion';

-- Table: system_settings (Paramètres système)
CREATE TABLE system_settings (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT,
    setting_type ENUM('STRING', 'NUMBER', 'BOOLEAN', 'JSON') DEFAULT 'STRING',
    category VARCHAR(50) COMMENT 'Catégorie: GENERAL, EMAIL, SMS, PAYMENT',
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE COMMENT 'Visible côté client',
    updated_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (updated_by) REFERENCES users(id),
    INDEX idx_setting_key (setting_key),
    INDEX idx_setting_category (category)
) ENGINE=InnoDB COMMENT='Paramètres de configuration système';

-- ============================================
-- MODULE 11: REPORTING & ANALYTICS
-- ============================================

-- Table: reports (Rapports générés)
CREATE TABLE reports (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    report_name VARCHAR(255) NOT NULL,
    report_type ENUM('SALES', 'INVENTORY', 'FINANCIAL', 'CUSTOMER', 'SUPPLIER', 'CUSTOM') NOT NULL,
    period_start DATE,
    period_end DATE,
    file_url VARCHAR(500) COMMENT 'URL du fichier PDF/Excel généré',
    file_format ENUM('PDF', 'EXCEL', 'CSV') NOT NULL,
    status ENUM('GENERATING', 'COMPLETED', 'FAILED') DEFAULT 'GENERATING',
    generated_by BIGINT NOT NULL,
    parameters JSON COMMENT 'Paramètres du rapport',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (generated_by) REFERENCES users(id),
    INDEX idx_report_type (report_type),
    INDEX idx_report_date (created_at)
) ENGINE=InnoDB COMMENT='Rapports générés';

-- ============================================
-- INSERTION DES DONNÉES DE TEST
-- ============================================

-- Rôles
INSERT INTO roles (code, name, description, is_active) VALUES
('ADMIN', 'Administrateur', 'Accès complet au système', TRUE),
('MANAGER', 'Gestionnaire', 'Gestion des opérations', TRUE),
('STOCK_MANAGER', 'Gestionnaire de Stock', 'Gestion du stock et inventaire', TRUE),
('SALES', 'Commercial', 'Gestion des ventes et clients', TRUE),
('ACCOUNTANT', 'Comptable', 'Gestion financière', TRUE),
('WAREHOUSE', 'Magasinier', 'Préparation et expédition', TRUE),
('CUSTOMER', 'Client B2B', 'Accès portail client', TRUE);

-- Utilisateurs (mot de passe: password123 - hash BCrypt)
INSERT INTO users (role_id, username, email, password_hash, first_name, last_name, phone, is_active) VALUES
(1, 'admin', 'admin@venus.cm', '$2a$10$rKvvJQxQxQxQxQxQxQxQxOeKqKqKqKqKqKqKqKqKqKqKqKqKqKqKq', 'Admin', 'VENUS', '+237670000001', TRUE),
(2, 'manager', 'manager@venus.cm', '$2a$10$rKvvJQxQxQxQxQxQxQxQxOeKqKqKqKqKqKqKqKqKqKqKqKqKqKqKq', 'Jean', 'MBARGA', '+237670000002', TRUE),
(3, 'stock', 'stock@venus.cm', '$2a$10$rKvvJQxQxQxQxQxQxQxQxOeKqKqKqKqKqKqKqKqKqKqKqKqKqKqKq', 'Marie', 'NGUEMA', '+237670000003', TRUE),
(4, 'sales', 'sales@venus.cm', '$2a$10$rKvvJQxQxQxQxQxQxQxQxOeKqKqKqKqKqKqKqKqKqKqKqKqKqKqKq', 'Paul', 'KAMGA', '+237670000004', TRUE);

-- Zones de stockage
INSERT INTO storage_zones (code, name, zone_type, temperature_min, temperature_max, is_active) VALUES
('ZONE-A', 'Zone Ambiante A', 'AMBIENT', 15, 25, TRUE),
('ZONE-B', 'Zone Ambiante B', 'AMBIENT', 15, 25, TRUE),
('ZONE-FROID', 'Zone Réfrigérée', 'REFRIGERATED', 2, 8, TRUE),
('ZONE-QUAR', 'Zone Quarantaine', 'QUARANTINE', 15, 25, TRUE);

-- Catégories de produits
INSERT INTO product_categories (code, name, description, requires_prescription, storage_conditions, is_active) VALUES
('ANTIBIO', 'Antibiotiques', 'Médicaments antibactériens', TRUE, 'AMBIENT', TRUE),
('ANALG', 'Antalgiques', 'Médicaments contre la douleur', FALSE, 'AMBIENT', TRUE),
('ANTIPALU', 'Antipaludéens', 'Traitement du paludisme', TRUE, 'AMBIENT', TRUE),
('DIABET', 'Antidiabétiques', 'Traitement du diabète', TRUE, 'AMBIENT', TRUE),
('HYPERT', 'Antihypertenseurs', 'Traitement de l\'hypertension', TRUE, 'AMBIENT', TRUE),
('VITAM', 'Vitamines', 'Compléments vitaminiques', FALSE, 'AMBIENT', TRUE),
('VACCIN', 'Vaccins', 'Vaccins et immunisations', TRUE, 'REFRIGERATED', TRUE);

-- Fournisseurs
INSERT INTO suppliers (supplier_code, supplier_type, company_name, contact_person, email, phone, city, country, is_active) VALUES
('FOUR001', 'LABORATORY', 'Sanofi Cameroun', 'Dr. MBARGA', 'contact@sanofi.cm', '+237222111111', 'Douala', 'Cameroun', TRUE),
('FOUR002', 'LABORATORY', 'Pfizer Central Africa', 'Dr. NKOMO', 'info@pfizer.cm', '+237222222222', 'Yaoundé', 'Cameroun', TRUE),
('FOUR003', 'LABORATORY', 'Novartis Cameroun', 'Dr. FOTSO', 'contact@novartis.cm', '+237222333333', 'Douala', 'Cameroun', TRUE);

-- Clients
INSERT INTO customers (customer_code, customer_type, company_name, contact_person, email, phone, address, city, credit_limit, is_active, is_verified) VALUES
('CLI001', 'PHARMACY', 'Pharmacie du Centre', 'Mme ATANGANA', 'centre@pharma.cm', '+237670111111', 'Avenue Kennedy', 'Yaoundé', 5000000, TRUE, TRUE),
('CLI002', 'PHARMACY', 'Pharmacie de la Paix', 'M. NDI', 'paix@pharma.cm', '+237670222222', 'Bastos', 'Yaoundé', 3000000, TRUE, TRUE),
('CLI003', 'HOSPITAL', 'Hôpital Central de Yaoundé', 'Dr. MBALLA', 'hcy@hospital.cm', '+237670333333', 'Centre-ville', 'Yaoundé', 20000000, TRUE, TRUE);

-- Produits
INSERT INTO products (product_code, category_id, supplier_id, name, generic_name, dosage, form, packaging, purchase_price, selling_price, tax_rate, reorder_level, is_active, barcode) VALUES
('PROD001', 1, 1, 'Amoxicilline 500mg', 'Amoxicilline', '500mg', 'CAPSULE', 'Boîte de 12', 2500, 3500, 19.00, 50, TRUE, '3401234567890'),
('PROD002', 2, 2, 'Paracétamol 1000mg', 'Paracétamol', '1000mg', 'TABLET', 'Boîte de 8', 500, 800, 19.00, 100, TRUE, '3401234567891'),
('PROD003', 3, 3, 'Artesunate 100mg', 'Artesunate', '100mg', 'TABLET', 'Boîte de 6', 3000, 4500, 19.00, 30, TRUE, '3401234567892');

-- Inventaire initial
INSERT INTO inventory (product_id, quantity_in_stock, quantity_reserved, minimum_stock, maximum_stock) VALUES
(1, 150, 0, 50, 500),
(2, 300, 0, 100, 1000),
(3, 80, 0, 30, 300);

-- Lots de produits
INSERT INTO product_batches (product_id, batch_number, supplier_id, storage_zone_id, manufacturing_date, expiry_date, quantity_received, quantity_remaining, purchase_price, quality_status) VALUES
(1, 'AMOX2024001', 1, 1, '2024-01-15', '2026-01-15', 200, 150, 2500, 'APPROVED'),
(2, 'PARA2024001', 2, 1, '2024-02-01', '2026-02-01', 500, 300, 500, 'APPROVED'),
(3, 'ARTE2024001', 3, 1, '2024-01-20', '2025-07-20', 100, 80, 3000, 'APPROVED');

-- Paramètres système
INSERT INTO system_settings (setting_key, setting_value, setting_type, category, description) VALUES
('COMPANY_NAME', 'VENUS Distribution Pharmaceutique', 'STRING', 'GENERAL', 'Nom de l\'entreprise'),
('COMPANY_ADDRESS', 'Yaoundé, Cameroun', 'STRING', 'GENERAL', 'Adresse de l\'entreprise'),
('COMPANY_PHONE', '+237 XXX XXX XXX', 'STRING', 'GENERAL', 'Téléphone de l\'entreprise'),
('COMPANY_EMAIL', 'contact@venus.cm', 'STRING', 'GENERAL', 'Email de l\'entreprise'),
('TAX_RATE', '19.00', 'NUMBER', 'GENERAL', 'Taux de TVA par défaut'),
('CURRENCY', 'XAF', 'STRING', 'GENERAL', 'Devise'),
('LOW_STOCK_ALERT_DAYS', '30', 'NUMBER', 'STOCK', 'Jours avant alerte stock bas'),
('EXPIRY_WARNING_DAYS', '180', 'NUMBER', 'STOCK', 'Jours avant alerte expiration'),
('EXPIRY_CRITICAL_DAYS', '90', 'NUMBER', 'STOCK', 'Jours avant alerte expiration critique');

-- ============================================
-- FIN DE L'INSERTION DES DONNÉES
-- ============================================

-- Afficher un résumé
SELECT 'Base de données VENUS créée avec succès!' AS Status;
SELECT COUNT(*) AS 'Nombre de tables' FROM information_schema.tables WHERE table_schema = 'venus_db';
SELECT COUNT(*) AS 'Nombre de rôles' FROM roles;
SELECT COUNT(*) AS 'Nombre d\'utilisateurs' FROM users;
SELECT COUNT(*) AS 'Nombre de produits' FROM products;
SELECT COUNT(*) AS 'Nombre de clients' FROM customers;

