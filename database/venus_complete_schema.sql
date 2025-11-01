-- =====================================================
-- VENUS PHARMA SARL - SCHÉMA COMPLET DE BASE DE DONNÉES
-- Distribution Pharmaceutique - Yaoundé, Cameroun
-- =====================================================

-- Supprimer la base existante et la recréer
DROP DATABASE IF EXISTS venus_db;
CREATE DATABASE venus_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE venus_db;

-- =====================================================
-- 1. TABLES DE BASE - RÔLES ET UTILISATEURS
-- =====================================================

-- Table des rôles
CREATE TABLE roles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name ENUM(
        'ADMIN', 'MANAGER', 'PHARMACIST', 'SALES', 'WAREHOUSE', 
        'ACCOUNTANT', 'SUPPORT', 'DRIVER', 'CUSTOMER_ADMIN', 'CUSTOMER_USER'
    ) NOT NULL UNIQUE,
    description TEXT,
    permissions JSON,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table des clients (entreprises)
CREATE TABLE customers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    customer_type ENUM('PHARMACY', 'HOSPITAL', 'CLINIC', 'DISTRIBUTOR', 'OTHER') NOT NULL,
    
    -- Statut d'approbation (CRUCIAL)
    approval_status ENUM('PENDING', 'EMAIL_VERIFIED', 'APPROVED', 'REJECTED', 'SUSPENDED') DEFAULT 'PENDING',
    approved_by BIGINT NULL,
    approved_at TIMESTAMP NULL,
    rejection_reason TEXT NULL,
    
    -- Informations légales
    business_license VARCHAR(100),
    tax_id VARCHAR(100),
    license_number VARCHAR(100),
    license_expiry_date DATE,
    
    -- Contact principal
    contact_person VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(20) NOT NULL,
    
    -- Adresse
    address TEXT NOT NULL,
    city VARCHAR(100),
    region VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) DEFAULT 'Cameroun',
    
    -- Conditions commerciales
    credit_limit DECIMAL(15,2) DEFAULT 0.00,
    payment_terms INT DEFAULT 30, -- jours
    discount_rate DECIMAL(5,2) DEFAULT 0.00,
    
    -- Statut et métadonnées
    is_active BOOLEAN DEFAULT FALSE, -- Activé seulement après approbation
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_customer_code (customer_code),
    INDEX idx_approval_status (approval_status),
    INDEX idx_customer_type (customer_type),
    INDEX idx_is_active (is_active)
);

-- Table des utilisateurs
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    
    -- Informations personnelles
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    
    -- Relation avec client (pour utilisateurs B2B)
    customer_id BIGINT NULL,
    
    -- Statut de sécurité
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    is_locked BOOLEAN DEFAULT FALSE,
    failed_login_attempts INT DEFAULT 0,
    
    -- Dates importantes
    last_login TIMESTAMP NULL,
    last_password_change TIMESTAMP NULL,
    email_verified_at TIMESTAMP NULL,
    
    -- Métadonnées
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_customer_id (customer_id),
    INDEX idx_is_active (is_active),
    INDEX idx_is_verified (is_verified),
    
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL
);

-- Table de liaison utilisateurs-rôles (Many-to-Many)
CREATE TABLE user_roles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    assigned_by BIGINT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    
    UNIQUE KEY unique_user_role (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_by) REFERENCES users(id) ON DELETE SET NULL
);

-- =====================================================
-- 2. TABLES D'AUTHENTIFICATION ET SÉCURITÉ
-- =====================================================

-- Tokens de rafraîchissement
CREATE TABLE refresh_tokens (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token VARCHAR(500) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    is_revoked BOOLEAN DEFAULT FALSE,
    ip_address VARCHAR(50),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_token (token),
    INDEX idx_user_id (user_id),
    INDEX idx_expires_at (expires_at),
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Tokens de réinitialisation de mot de passe
CREATE TABLE password_reset_tokens (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token VARCHAR(255) NOT NULL UNIQUE,
    expiry_date TIMESTAMP NOT NULL,
    used BOOLEAN DEFAULT FALSE,
    used_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_token (token),
    INDEX idx_user_id (user_id),
    INDEX idx_expiry_date (expiry_date),
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Tentatives de connexion
CREATE TABLE login_attempts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100),
    ip_address VARCHAR(50),
    user_agent TEXT,
    successful BOOLEAN NOT NULL,
    failure_reason VARCHAR(255),
    attempt_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_username (username),
    INDEX idx_ip_address (ip_address),
    INDEX idx_attempt_time (attempt_time),
    INDEX idx_successful (successful)
);

-- =====================================================
-- 3. TABLES DE SUPPORT CLIENT
-- =====================================================

-- Tickets de support
CREATE TABLE support_tickets (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    ticket_number VARCHAR(50) NOT NULL UNIQUE,
    customer_id BIGINT NOT NULL,
    subject VARCHAR(500) NOT NULL,
    description TEXT NOT NULL,
    
    -- Catégorisation
    category ENUM('TECHNICAL', 'BILLING', 'DELIVERY', 'PRODUCT', 'ORDER', 'ACCOUNT', 'OTHER') NOT NULL,
    priority ENUM('LOW', 'MEDIUM', 'HIGH', 'URGENT') NOT NULL,
    status ENUM('OPEN', 'IN_PROGRESS', 'WAITING_CUSTOMER', 'RESOLVED', 'CLOSED', 'CANCELLED') DEFAULT 'OPEN',
    
    -- Assignation
    assigned_to_id BIGINT NULL,
    
    -- Informations de contact
    contact_method ENUM('EMAIL', 'PHONE', 'CHAT', 'WEB') DEFAULT 'WEB',
    preferred_language VARCHAR(5) DEFAULT 'fr',
    customer_email VARCHAR(255),
    customer_phone VARCHAR(20),
    
    -- Références
    order_number VARCHAR(50),
    product_code VARCHAR(100),
    
    -- Flags
    is_urgent BOOLEAN DEFAULT FALSE,
    
    -- Résolution
    resolution TEXT,
    internal_notes TEXT,
    
    -- Métriques
    response_time_minutes INT,
    resolution_time_minutes INT,
    satisfaction_rating DECIMAL(3,2), -- 1.00 à 5.00
    satisfaction_comment TEXT,
    
    -- Dates
    resolved_at TIMESTAMP NULL,
    closed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_ticket_number (ticket_number),
    INDEX idx_customer_id (customer_id),
    INDEX idx_status (status),
    INDEX idx_priority (priority),
    INDEX idx_assigned_to (assigned_to_id),
    INDEX idx_created_at (created_at),
    
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_to_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Réponses aux tickets
CREATE TABLE support_ticket_responses (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    ticket_id BIGINT NOT NULL,
    message TEXT NOT NULL,
    author_id BIGINT NOT NULL,
    is_internal BOOLEAN DEFAULT FALSE,
    response_type ENUM('ANSWER', 'QUESTION', 'UPDATE', 'ESCALATION', 'RESOLUTION') DEFAULT 'ANSWER',
    priority ENUM('LOW', 'NORMAL', 'HIGH') DEFAULT 'NORMAL',
    requires_follow_up BOOLEAN DEFAULT FALSE,
    notify_customer BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_ticket_id (ticket_id),
    INDEX idx_author_id (author_id),
    INDEX idx_created_at (created_at),
    
    FOREIGN KEY (ticket_id) REFERENCES support_tickets(id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Pièces jointes des tickets
CREATE TABLE support_ticket_attachments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    ticket_id BIGINT NULL,
    response_id BIGINT NULL,
    filename VARCHAR(255) NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    content_type VARCHAR(100),
    file_size BIGINT,
    file_path VARCHAR(500) NOT NULL,
    file_url VARCHAR(500),
    uploaded_by_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_ticket_id (ticket_id),
    INDEX idx_response_id (response_id),
    INDEX idx_uploaded_by (uploaded_by_id),
    
    FOREIGN KEY (ticket_id) REFERENCES support_tickets(id) ON DELETE CASCADE,
    FOREIGN KEY (response_id) REFERENCES support_ticket_responses(id) ON DELETE CASCADE,
    FOREIGN KEY (uploaded_by_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Enquêtes de satisfaction client
CREATE TABLE customer_satisfaction_surveys (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    ticket_id BIGINT NULL,
    customer_id BIGINT NOT NULL,
    order_id BIGINT NULL,

    -- Évaluations (1-5)
    overall_rating INT NOT NULL CHECK (overall_rating BETWEEN 1 AND 5),
    response_time_rating INT CHECK (response_time_rating BETWEEN 1 AND 5),
    solution_quality_rating INT CHECK (solution_quality_rating BETWEEN 1 AND 5),
    agent_courtesy_rating INT CHECK (agent_courtesy_rating BETWEEN 1 AND 5),
    communication_rating INT CHECK (communication_rating BETWEEN 1 AND 5),
    overall_experience_rating INT CHECK (overall_experience_rating BETWEEN 1 AND 5),

    -- Commentaires
    comment TEXT,
    improvement_suggestions TEXT,
    best_aspect TEXT,
    worst_aspect TEXT,

    -- Métadonnées
    category ENUM('RESPONSE_TIME', 'SOLUTION_QUALITY', 'AGENT_COURTESY', 'OVERALL', 'DELIVERY', 'PRODUCT_QUALITY', 'ORDERING_PROCESS'),
    would_recommend BOOLEAN,
    survey_channel ENUM('EMAIL', 'SMS', 'WEB', 'PHONE', 'CHAT') DEFAULT 'WEB',
    additional_data JSON,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_ticket_id (ticket_id),
    INDEX idx_customer_id (customer_id),
    INDEX idx_overall_rating (overall_rating),
    INDEX idx_created_at (created_at),

    FOREIGN KEY (ticket_id) REFERENCES support_tickets(id) ON DELETE SET NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
);

-- =====================================================
-- 4. TABLES DE PRODUITS ET INVENTAIRE
-- =====================================================

-- Catégories de produits
CREATE TABLE product_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    parent_id BIGINT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_parent_id (parent_id),
    INDEX idx_is_active (is_active),

    FOREIGN KEY (parent_id) REFERENCES product_categories(id) ON DELETE SET NULL
);

-- Fournisseurs
CREATE TABLE suppliers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    supplier_code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    contact_person VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(100),
    country VARCHAR(100) DEFAULT 'Cameroun',
    tax_id VARCHAR(100),
    payment_terms INT DEFAULT 30,
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_supplier_code (supplier_code),
    INDEX idx_is_active (is_active)
);

-- Produits
CREATE TABLE products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_code VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category_id BIGINT NOT NULL,
    supplier_id BIGINT NULL,

    -- Classification pharmaceutique
    drug_class VARCHAR(100),
    active_ingredient VARCHAR(255),
    dosage_form ENUM('TABLET', 'CAPSULE', 'SYRUP', 'INJECTION', 'CREAM', 'DROPS', 'OTHER'),
    strength VARCHAR(100),

    -- Informations réglementaires
    requires_prescription BOOLEAN DEFAULT FALSE,
    controlled_substance BOOLEAN DEFAULT FALSE,
    regulatory_approval VARCHAR(100),

    -- Unités et conditionnement
    unit_of_measure VARCHAR(50) DEFAULT 'UNIT',
    pack_size INT DEFAULT 1,

    -- Prix
    cost_price DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    selling_price DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    min_selling_price DECIMAL(15,2),

    -- Stock
    reorder_level INT DEFAULT 0,
    max_stock_level INT,

    -- Conditions de stockage
    storage_temperature_min DECIMAL(5,2),
    storage_temperature_max DECIMAL(5,2),
    requires_cold_chain BOOLEAN DEFAULT FALSE,

    -- Statut
    is_active BOOLEAN DEFAULT TRUE,
    is_discontinued BOOLEAN DEFAULT FALSE,

    -- Métadonnées
    manufacturer VARCHAR(255),
    country_of_origin VARCHAR(100),
    shelf_life_months INT,
    notes TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_product_code (product_code),
    INDEX idx_category_id (category_id),
    INDEX idx_supplier_id (supplier_id),
    INDEX idx_is_active (is_active),
    INDEX idx_requires_prescription (requires_prescription),

    FOREIGN KEY (category_id) REFERENCES product_categories(id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE SET NULL
);

-- Lots de produits
CREATE TABLE product_batches (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    batch_number VARCHAR(100) NOT NULL,
    manufacturing_date DATE,
    expiry_date DATE NOT NULL,
    quantity_received INT NOT NULL DEFAULT 0,
    quantity_available INT NOT NULL DEFAULT 0,
    cost_price DECIMAL(15,2),
    supplier_id BIGINT,
    purchase_order_id BIGINT NULL,

    -- Statut
    status ENUM('ACTIVE', 'EXPIRED', 'RECALLED', 'QUARANTINE') DEFAULT 'ACTIVE',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY unique_product_batch (product_id, batch_number),
    INDEX idx_expiry_date (expiry_date),
    INDEX idx_status (status),
    INDEX idx_supplier_id (supplier_id),

    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE SET NULL
);

-- Inventaire
CREATE TABLE inventory (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    batch_id BIGINT NULL,
    storage_zone_id BIGINT NULL,

    quantity_on_hand INT NOT NULL DEFAULT 0,
    quantity_reserved INT NOT NULL DEFAULT 0,
    quantity_available INT GENERATED ALWAYS AS (quantity_on_hand - quantity_reserved) STORED,

    last_count_date DATE,
    last_count_quantity INT,
    variance_quantity INT DEFAULT 0,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY unique_product_batch_zone (product_id, batch_id, storage_zone_id),
    INDEX idx_product_id (product_id),
    INDEX idx_batch_id (batch_id),
    INDEX idx_storage_zone_id (storage_zone_id),

    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (batch_id) REFERENCES product_batches(id) ON DELETE SET NULL
);

-- Zones de stockage
CREATE TABLE storage_zones (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    zone_code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    zone_type ENUM('AMBIENT', 'COLD', 'FREEZER', 'CONTROLLED', 'QUARANTINE') NOT NULL,
    temperature_min DECIMAL(5,2),
    temperature_max DECIMAL(5,2),
    humidity_min DECIMAL(5,2),
    humidity_max DECIMAL(5,2),
    capacity_cubic_meters DECIMAL(10,2),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_zone_code (zone_code),
    INDEX idx_zone_type (zone_type),
    INDEX idx_is_active (is_active)
);

-- =====================================================
-- 5. TABLES DE COMMANDES ET VENTES
-- =====================================================

-- Paniers d'achat
CREATE TABLE carts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    session_id VARCHAR(255),
    status ENUM('ACTIVE', 'ABANDONED', 'CONVERTED') DEFAULT 'ACTIVE',
    total_amount DECIMAL(15,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,

    INDEX idx_customer_id (customer_id),
    INDEX idx_session_id (session_id),
    INDEX idx_status (status),
    INDEX idx_expires_at (expires_at),

    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
);

-- Articles du panier
CREATE TABLE cart_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cart_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    batch_id BIGINT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(15,2) NOT NULL,
    total_price DECIMAL(15,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY unique_cart_product_batch (cart_id, product_id, batch_id),
    INDEX idx_cart_id (cart_id),
    INDEX idx_product_id (product_id),

    FOREIGN KEY (cart_id) REFERENCES carts(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (batch_id) REFERENCES product_batches(id) ON DELETE SET NULL
);

-- Commandes
CREATE TABLE orders (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(50) NOT NULL UNIQUE,
    customer_id BIGINT NOT NULL,
    created_by_user_id BIGINT NULL,

    -- Statut de la commande
    status ENUM('DRAFT', 'PENDING', 'CONFIRMED', 'PROCESSING', 'SHIPPED', 'DELIVERED', 'CANCELLED', 'RETURNED') DEFAULT 'PENDING',

    -- Montants
    subtotal DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    discount_amount DECIMAL(15,2) DEFAULT 0.00,
    tax_amount DECIMAL(15,2) DEFAULT 0.00,
    shipping_amount DECIMAL(15,2) DEFAULT 0.00,
    total_amount DECIMAL(15,2) NOT NULL DEFAULT 0.00,

    -- Adresse de livraison
    delivery_address TEXT NOT NULL,
    delivery_city VARCHAR(100),
    delivery_region VARCHAR(100),
    delivery_contact_person VARCHAR(255),
    delivery_phone VARCHAR(20),

    -- Dates importantes
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    requested_delivery_date DATE,
    confirmed_at TIMESTAMP NULL,
    shipped_at TIMESTAMP NULL,
    delivered_at TIMESTAMP NULL,

    -- Conditions de paiement
    payment_terms INT DEFAULT 30,
    payment_status ENUM('PENDING', 'PARTIAL', 'PAID', 'OVERDUE', 'CANCELLED') DEFAULT 'PENDING',

    -- Métadonnées
    notes TEXT,
    internal_notes TEXT,
    priority ENUM('LOW', 'NORMAL', 'HIGH', 'URGENT') DEFAULT 'NORMAL',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_order_number (order_number),
    INDEX idx_customer_id (customer_id),
    INDEX idx_status (status),
    INDEX idx_payment_status (payment_status),
    INDEX idx_order_date (order_date),
    INDEX idx_created_by (created_by_user_id),

    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (created_by_user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Articles de commande
CREATE TABLE order_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    batch_id BIGINT NULL,

    quantity_ordered INT NOT NULL,
    quantity_shipped INT DEFAULT 0,
    quantity_delivered INT DEFAULT 0,

    unit_price DECIMAL(15,2) NOT NULL,
    discount_percentage DECIMAL(5,2) DEFAULT 0.00,
    discount_amount DECIMAL(15,2) DEFAULT 0.00,
    line_total DECIMAL(15,2) NOT NULL,

    notes TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_order_id (order_id),
    INDEX idx_product_id (product_id),
    INDEX idx_batch_id (batch_id),

    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (batch_id) REFERENCES product_batches(id) ON DELETE SET NULL
);

-- =====================================================
-- 6. TABLES DE PAIEMENT
-- =====================================================

-- Transactions de paiement
CREATE TABLE payment_transactions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    transaction_id VARCHAR(100) NOT NULL UNIQUE,
    order_id BIGINT NOT NULL,
    customer_id BIGINT NOT NULL,

    -- Type et méthode de paiement
    payment_method ENUM('ORANGE_MONEY', 'MTN_MOMO', 'BANK_TRANSFER', 'CASH', 'CREDIT', 'CHECK') NOT NULL,
    payment_type ENUM('PAYMENT', 'REFUND', 'PARTIAL_REFUND') DEFAULT 'PAYMENT',

    -- Montants
    amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'XAF',

    -- Statut
    status ENUM('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED', 'CANCELLED', 'REFUNDED') DEFAULT 'PENDING',

    -- Informations spécifiques au paiement mobile
    mobile_number VARCHAR(20),
    mobile_operator ENUM('ORANGE', 'MTN'),
    external_transaction_id VARCHAR(255),

    -- Métadonnées
    gateway_response JSON,
    failure_reason TEXT,
    processed_by_user_id BIGINT NULL,

    -- Dates
    initiated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP NULL,
    completed_at TIMESTAMP NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_transaction_id (transaction_id),
    INDEX idx_order_id (order_id),
    INDEX idx_customer_id (customer_id),
    INDEX idx_status (status),
    INDEX idx_payment_method (payment_method),
    INDEX idx_mobile_number (mobile_number),
    INDEX idx_initiated_at (initiated_at),

    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (processed_by_user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- =====================================================
-- 7. TABLES DE LIVRAISON ET LOGISTIQUE
-- =====================================================

-- Transporteurs
CREATE TABLE carriers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    carrier_code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    contact_person VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(255),
    address TEXT,

    -- Capacités
    vehicle_types JSON,
    coverage_regions JSON,
    max_weight_kg DECIMAL(10,2),
    cold_chain_capable BOOLEAN DEFAULT FALSE,

    -- Tarification
    base_rate DECIMAL(10,2),
    rate_per_km DECIMAL(10,2),
    rate_per_kg DECIMAL(10,2),

    -- Performance
    average_delivery_time_hours DECIMAL(5,2),
    success_rate DECIMAL(5,2),

    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_carrier_code (carrier_code),
    INDEX idx_is_active (is_active)
);

-- Véhicules
CREATE TABLE vehicles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    vehicle_number VARCHAR(50) NOT NULL UNIQUE,
    carrier_id BIGINT NULL,
    vehicle_type ENUM('VAN', 'TRUCK', 'MOTORCYCLE', 'CAR') NOT NULL,

    -- Spécifications
    make VARCHAR(100),
    model VARCHAR(100),
    year_manufactured INT,
    license_plate VARCHAR(20),

    -- Capacités
    max_weight_kg DECIMAL(10,2),
    max_volume_cubic_meters DECIMAL(10,2),
    has_cold_chain BOOLEAN DEFAULT FALSE,

    -- Statut
    status ENUM('AVAILABLE', 'IN_USE', 'MAINTENANCE', 'OUT_OF_SERVICE') DEFAULT 'AVAILABLE',

    -- Métadonnées
    insurance_expiry DATE,
    last_maintenance_date DATE,
    next_maintenance_date DATE,

    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_vehicle_number (vehicle_number),
    INDEX idx_carrier_id (carrier_id),
    INDEX idx_status (status),
    INDEX idx_is_active (is_active),

    FOREIGN KEY (carrier_id) REFERENCES carriers(id) ON DELETE SET NULL
);

-- Livraisons
CREATE TABLE deliveries (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    delivery_number VARCHAR(50) NOT NULL UNIQUE,
    order_id BIGINT NOT NULL,
    carrier_id BIGINT NULL,
    vehicle_id BIGINT NULL,
    driver_user_id BIGINT NULL,

    -- Statut
    status ENUM('PENDING', 'ASSIGNED', 'PICKED_UP', 'IN_TRANSIT', 'OUT_FOR_DELIVERY', 'DELIVERED', 'FAILED', 'RETURNED') DEFAULT 'PENDING',

    -- Adresse de livraison
    delivery_address TEXT NOT NULL,
    delivery_city VARCHAR(100),
    delivery_region VARCHAR(100),
    delivery_contact_person VARCHAR(255),
    delivery_phone VARCHAR(20),

    -- Coordonnées GPS
    delivery_latitude DECIMAL(10, 8),
    delivery_longitude DECIMAL(11, 8),

    -- Dates et heures
    scheduled_date DATE,
    scheduled_time_start TIME,
    scheduled_time_end TIME,
    picked_up_at TIMESTAMP NULL,
    delivered_at TIMESTAMP NULL,

    -- Informations de livraison
    delivery_instructions TEXT,
    special_requirements TEXT,
    requires_signature BOOLEAN DEFAULT TRUE,
    requires_cold_chain BOOLEAN DEFAULT FALSE,

    -- Résultat de livraison
    delivery_status_reason TEXT,
    delivered_to_person VARCHAR(255),
    signature_image_path VARCHAR(500),
    delivery_photo_path VARCHAR(500),

    -- Coûts
    delivery_cost DECIMAL(10,2),
    distance_km DECIMAL(8,2),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_delivery_number (delivery_number),
    INDEX idx_order_id (order_id),
    INDEX idx_carrier_id (carrier_id),
    INDEX idx_vehicle_id (vehicle_id),
    INDEX idx_driver_user_id (driver_user_id),
    INDEX idx_status (status),
    INDEX idx_scheduled_date (scheduled_date),

    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (carrier_id) REFERENCES carriers(id) ON DELETE SET NULL,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE SET NULL,
    FOREIGN KEY (driver_user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Suivi GPS des livraisons
CREATE TABLE delivery_tracking (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    delivery_id BIGINT NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    accuracy_meters DECIMAL(8,2),
    speed_kmh DECIMAL(6,2),
    heading_degrees DECIMAL(6,2),
    altitude_meters DECIMAL(8,2),

    -- Statut au moment du tracking
    status ENUM('PICKED_UP', 'IN_TRANSIT', 'STOPPED', 'OUT_FOR_DELIVERY', 'DELIVERED') NOT NULL,
    notes TEXT,

    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_delivery_id (delivery_id),
    INDEX idx_recorded_at (recorded_at),
    INDEX idx_status (status),

    FOREIGN KEY (delivery_id) REFERENCES deliveries(id) ON DELETE CASCADE
);

-- =====================================================
-- 8. TABLES DE NOTIFICATIONS ET COMMUNICATION
-- =====================================================

-- Templates de notification
CREATE TABLE notification_templates (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    template_id VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    description TEXT,

    -- Type et catégorie
    type ENUM('EMAIL', 'SMS', 'PUSH') NOT NULL,
    category ENUM('ORDER', 'PAYMENT', 'DELIVERY', 'SUPPORT', 'MARKETING', 'SYSTEM', 'SECURITY') NOT NULL,
    language VARCHAR(5) NOT NULL DEFAULT 'fr',
    status ENUM('ACTIVE', 'INACTIVE', 'DRAFT', 'ARCHIVED') DEFAULT 'ACTIVE',

    -- Contenu pour EMAIL
    subject VARCHAR(500),
    html_content LONGTEXT,
    text_content TEXT,

    -- Contenu pour PUSH
    push_title VARCHAR(255),
    push_message TEXT,
    push_icon VARCHAR(255),
    push_image VARCHAR(255),

    -- Variables disponibles
    variables JSON,

    -- Configuration
    priority ENUM('LOW', 'NORMAL', 'HIGH') DEFAULT 'NORMAL',
    track_opening BOOLEAN DEFAULT TRUE,
    track_clicks BOOLEAN DEFAULT TRUE,
    retry_attempts INT DEFAULT 3,
    fallback_template_id VARCHAR(100),

    -- Métadonnées
    created_by_id BIGINT NOT NULL,
    last_modified_by_id BIGINT,

    -- Statistiques
    usage_count INT DEFAULT 0,
    last_used TIMESTAMP NULL,
    success_rate DECIMAL(5,2) DEFAULT 0.00,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_template_id (template_id),
    INDEX idx_type (type),
    INDEX idx_category (category),
    INDEX idx_language (language),
    INDEX idx_status (status),

    FOREIGN KEY (created_by_id) REFERENCES users(id),
    FOREIGN KEY (last_modified_by_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Préférences de notification
CREATE TABLE notification_preferences (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,

    -- Préférences générales
    email_notifications BOOLEAN DEFAULT TRUE,
    sms_notifications BOOLEAN DEFAULT TRUE,
    push_notifications BOOLEAN DEFAULT TRUE,

    -- Préférences par catégorie - Commandes
    order_email BOOLEAN DEFAULT TRUE,
    order_sms BOOLEAN DEFAULT TRUE,
    order_push BOOLEAN DEFAULT TRUE,
    order_priority ENUM('LOW', 'NORMAL', 'HIGH') DEFAULT 'HIGH',
    order_immediate BOOLEAN DEFAULT TRUE,
    order_digest BOOLEAN DEFAULT FALSE,

    -- Préférences par catégorie - Paiements
    payment_email BOOLEAN DEFAULT TRUE,
    payment_sms BOOLEAN DEFAULT TRUE,
    payment_push BOOLEAN DEFAULT TRUE,
    payment_priority ENUM('LOW', 'NORMAL', 'HIGH') DEFAULT 'HIGH',
    payment_immediate BOOLEAN DEFAULT TRUE,
    payment_digest BOOLEAN DEFAULT FALSE,

    -- Préférences par catégorie - Livraisons
    delivery_email BOOLEAN DEFAULT TRUE,
    delivery_sms BOOLEAN DEFAULT TRUE,
    delivery_push BOOLEAN DEFAULT TRUE,
    delivery_priority ENUM('LOW', 'NORMAL', 'HIGH') DEFAULT 'NORMAL',
    delivery_immediate BOOLEAN DEFAULT TRUE,
    delivery_digest BOOLEAN DEFAULT FALSE,

    -- Préférences par catégorie - Support
    support_email BOOLEAN DEFAULT TRUE,
    support_sms BOOLEAN DEFAULT FALSE,
    support_push BOOLEAN DEFAULT TRUE,
    support_priority ENUM('LOW', 'NORMAL', 'HIGH') DEFAULT 'NORMAL',
    support_immediate BOOLEAN DEFAULT TRUE,
    support_digest BOOLEAN DEFAULT TRUE,

    -- Préférences par catégorie - Marketing
    marketing_email BOOLEAN DEFAULT FALSE,
    marketing_sms BOOLEAN DEFAULT FALSE,
    marketing_push BOOLEAN DEFAULT FALSE,
    marketing_priority ENUM('LOW', 'NORMAL', 'HIGH') DEFAULT 'LOW',
    marketing_immediate BOOLEAN DEFAULT FALSE,
    marketing_digest BOOLEAN DEFAULT TRUE,

    -- Préférences par catégorie - Système
    system_email BOOLEAN DEFAULT TRUE,
    system_sms BOOLEAN DEFAULT FALSE,
    system_push BOOLEAN DEFAULT TRUE,
    system_priority ENUM('LOW', 'NORMAL', 'HIGH') DEFAULT 'HIGH',
    system_immediate BOOLEAN DEFAULT TRUE,
    system_digest BOOLEAN DEFAULT FALSE,

    -- Préférences de timing
    timezone VARCHAR(50) DEFAULT 'Africa/Douala',
    quiet_hours_start TIME DEFAULT '22:00:00',
    quiet_hours_end TIME DEFAULT '07:00:00',
    weekend_notifications BOOLEAN DEFAULT TRUE,
    digest_frequency ENUM('DAILY', 'WEEKLY', 'MONTHLY') DEFAULT 'DAILY',
    digest_time TIME DEFAULT '08:00:00',

    -- Préférences de langue et format
    preferred_language VARCHAR(5) DEFAULT 'fr',
    email_format ENUM('HTML', 'TEXT') DEFAULT 'HTML',
    include_attachments BOOLEAN DEFAULT TRUE,

    -- Préférences personnalisées
    custom_preferences JSON,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Logs d'emails
CREATE TABLE email_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    template_id VARCHAR(100),
    recipient_email VARCHAR(255) NOT NULL,
    recipient_name VARCHAR(255),
    subject VARCHAR(500),
    content_type ENUM('HTML', 'TEXT') DEFAULT 'HTML',
    status ENUM('PENDING', 'SENT', 'DELIVERED', 'BOUNCED', 'FAILED', 'OPENED', 'CLICKED') DEFAULT 'PENDING',

    -- Métadonnées
    message_id VARCHAR(255),
    error_message TEXT,
    sent_at TIMESTAMP NULL,
    delivered_at TIMESTAMP NULL,
    opened_at TIMESTAMP NULL,
    clicked_at TIMESTAMP NULL,

    -- Tracking
    open_count INT DEFAULT 0,
    click_count INT DEFAULT 0,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_recipient_email (recipient_email),
    INDEX idx_status (status),
    INDEX idx_template_id (template_id),
    INDEX idx_sent_at (sent_at)
);

-- =====================================================
-- 9. TABLES D'AUDIT ET LOGS
-- =====================================================

-- Logs d'audit
CREATE TABLE audit_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(100) NOT NULL,
    entity_id BIGINT NULL,
    old_values JSON,
    new_values JSON,
    ip_address VARCHAR(50),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_user_id (user_id),
    INDEX idx_action (action),
    INDEX idx_entity_type (entity_type),
    INDEX idx_entity_id (entity_id),
    INDEX idx_created_at (created_at),

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Paramètres système
CREATE TABLE system_settings (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT,
    setting_type ENUM('STRING', 'INTEGER', 'DECIMAL', 'BOOLEAN', 'JSON') DEFAULT 'STRING',
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    category VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_setting_key (setting_key),
    INDEX idx_category (category),
    INDEX idx_is_public (is_public)
);

-- =====================================================
-- 10. DONNÉES INITIALES
-- =====================================================

-- Insertion des rôles
INSERT INTO roles (name, description, permissions) VALUES
('ADMIN', 'Administrateur système', '["ALL"]'),
('MANAGER', 'Directeur Général', '["MANAGE_USERS", "MANAGE_CUSTOMERS", "VIEW_REPORTS", "APPROVE_CUSTOMERS", "MANAGE_ORDERS"]'),
('PHARMACIST', 'Pharmacien Responsable', '["MANAGE_PRODUCTS", "MANAGE_INVENTORY", "VIEW_ORDERS", "VALIDATE_PRESCRIPTIONS"]'),
('SALES', 'Responsable Commercial', '["MANAGE_CUSTOMERS", "MANAGE_ORDERS", "VIEW_REPORTS", "APPROVE_CUSTOMERS"]'),
('WAREHOUSE', 'Chef Magasinier', '["MANAGE_INVENTORY", "MANAGE_STOCK", "VIEW_ORDERS", "MANAGE_DELIVERIES"]'),
('ACCOUNTANT', 'Comptable', '["MANAGE_PAYMENTS", "VIEW_FINANCIAL_REPORTS", "MANAGE_INVOICES"]'),
('SUPPORT', 'Support Client', '["MANAGE_TICKETS", "VIEW_CUSTOMERS", "COMMUNICATE_CUSTOMERS"]'),
('DRIVER', 'Chauffeur Livreur', '["VIEW_DELIVERIES", "UPDATE_DELIVERY_STATUS", "GPS_TRACKING"]'),
('CUSTOMER_ADMIN', 'Administrateur Client B2B', '["MANAGE_CUSTOMER_USERS", "PLACE_ORDERS", "VIEW_REPORTS"]'),
('CUSTOMER_USER', 'Utilisateur Client B2B', '["PLACE_ORDERS", "VIEW_ORDER_HISTORY"]');

-- Insertion de l'utilisateur administrateur par défaut
INSERT INTO users (username, email, password_hash, first_name, last_name, phone, is_active, is_verified, email_verified_at) VALUES
('admin', 'admin@venus-pharma.cm', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqyc5rGkLSMpXeA4J9H1uDm', 'Administrateur', 'Système', '+237600000000', TRUE, TRUE, NOW());

-- Assigner le rôle ADMIN à l'utilisateur admin
INSERT INTO user_roles (user_id, role_id, assigned_by) VALUES
(1, 1, 1);

-- Insertion des catégories de produits de base
INSERT INTO product_categories (name, description, is_active) VALUES
('Médicaments', 'Produits pharmaceutiques', TRUE),
('Antibiotiques', 'Médicaments antibiotiques', TRUE),
('Antalgiques', 'Médicaments contre la douleur', TRUE),
('Vitamines', 'Compléments vitaminiques', TRUE),
('Matériel Médical', 'Équipements et matériel médical', TRUE),
('Produits de Parapharmacie', 'Produits de soins et hygiène', TRUE);

-- Mise à jour des relations parent-enfant pour les catégories
UPDATE product_categories SET parent_id = 1 WHERE name IN ('Antibiotiques', 'Antalgiques', 'Vitamines');

-- Insertion des zones de stockage
INSERT INTO storage_zones (zone_code, name, description, zone_type, temperature_min, temperature_max, is_active) VALUES
('AMB-01', 'Zone Ambiante 1', 'Stockage température ambiante', 'AMBIENT', 15.0, 25.0, TRUE),
('COLD-01', 'Zone Froide 1', 'Stockage réfrigéré', 'COLD', 2.0, 8.0, TRUE),
('CTRL-01', 'Zone Contrôlée 1', 'Stockage température contrôlée', 'CONTROLLED', 15.0, 25.0, TRUE),
('QUAR-01', 'Zone Quarantaine', 'Produits en quarantaine', 'QUARANTINE', 15.0, 25.0, TRUE);

-- Insertion des paramètres système
INSERT INTO system_settings (setting_key, setting_value, setting_type, description, category, is_public) VALUES
('company_name', 'VENUS PHARMA SARL', 'STRING', 'Nom de l\'entreprise', 'COMPANY', TRUE),
('company_address', 'Yaoundé, Cameroun', 'STRING', 'Adresse de l\'entreprise', 'COMPANY', TRUE),
('company_phone', '+237 6XX XXX XXX', 'STRING', 'Téléphone de l\'entreprise', 'COMPANY', TRUE),
('company_email', 'contact@venus-pharma.cm', 'STRING', 'Email de l\'entreprise', 'COMPANY', TRUE),
('default_currency', 'XAF', 'STRING', 'Devise par défaut', 'FINANCIAL', TRUE),
('default_tax_rate', '19.25', 'DECIMAL', 'Taux de TVA par défaut (%)', 'FINANCIAL', TRUE),
('default_payment_terms', '30', 'INTEGER', 'Conditions de paiement par défaut (jours)', 'FINANCIAL', FALSE),
('max_login_attempts', '5', 'INTEGER', 'Nombre maximum de tentatives de connexion', 'SECURITY', FALSE),
('password_expiry_days', '90', 'INTEGER', 'Expiration des mots de passe (jours)', 'SECURITY', FALSE),
('session_timeout_minutes', '30', 'INTEGER', 'Timeout de session (minutes)', 'SECURITY', FALSE),
('email_verification_required', 'true', 'BOOLEAN', 'Vérification email obligatoire', 'SECURITY', FALSE),
('customer_approval_required', 'true', 'BOOLEAN', 'Approbation client obligatoire', 'BUSINESS', FALSE),
('auto_approve_customers', 'false', 'BOOLEAN', 'Approbation automatique des clients', 'BUSINESS', FALSE),
('notification_email_from', 'noreply@venus-pharma.cm', 'STRING', 'Email expéditeur des notifications', 'NOTIFICATION', FALSE),
('sms_enabled', 'false', 'BOOLEAN', 'Notifications SMS activées', 'NOTIFICATION', FALSE),
('gps_tracking_enabled', 'true', 'BOOLEAN', 'Suivi GPS activé', 'DELIVERY', FALSE),
('delivery_radius_km', '50', 'INTEGER', 'Rayon de livraison (km)', 'DELIVERY', TRUE),
('min_order_amount', '10000', 'DECIMAL', 'Montant minimum de commande (XAF)', 'BUSINESS', TRUE),
('free_delivery_threshold', '50000', 'DECIMAL', 'Seuil de livraison gratuite (XAF)', 'BUSINESS', TRUE);

-- =====================================================
-- 11. TRIGGERS ET PROCÉDURES
-- =====================================================

-- Trigger pour mettre à jour le timestamp updated_at
DELIMITER $$

CREATE TRIGGER tr_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER tr_customers_updated_at
    BEFORE UPDATE ON customers
    FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER tr_orders_updated_at
    BEFORE UPDATE ON orders
    FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

-- Trigger pour générer automatiquement les codes
CREATE TRIGGER tr_customers_generate_code
    BEFORE INSERT ON customers
    FOR EACH ROW
BEGIN
    IF NEW.customer_code IS NULL OR NEW.customer_code = '' THEN
        SET NEW.customer_code = CONCAT('CUST', LPAD(LAST_INSERT_ID() + 1, 6, '0'));
    END IF;
END$$

CREATE TRIGGER tr_orders_generate_number
    BEFORE INSERT ON orders
    FOR EACH ROW
BEGIN
    IF NEW.order_number IS NULL OR NEW.order_number = '' THEN
        SET NEW.order_number = CONCAT('ORD', DATE_FORMAT(NOW(), '%Y%m%d'), LPAD(LAST_INSERT_ID() + 1, 4, '0'));
    END IF;
END$$

DELIMITER ;

-- =====================================================
-- 12. VUES UTILES
-- =====================================================

-- Vue des utilisateurs avec leurs rôles
CREATE VIEW v_users_with_roles AS
SELECT
    u.id,
    u.username,
    u.email,
    u.first_name,
    u.last_name,
    u.phone,
    u.customer_id,
    c.name as customer_name,
    u.is_active,
    u.is_verified,
    u.last_login,
    GROUP_CONCAT(r.name) as roles,
    u.created_at
FROM users u
LEFT JOIN user_roles ur ON u.id = ur.user_id AND ur.is_active = TRUE
LEFT JOIN roles r ON ur.role_id = r.id
LEFT JOIN customers c ON u.customer_id = c.id
GROUP BY u.id;

-- Vue des commandes avec détails client
CREATE VIEW v_orders_summary AS
SELECT
    o.id,
    o.order_number,
    o.customer_id,
    c.name as customer_name,
    c.customer_type,
    o.status,
    o.payment_status,
    o.total_amount,
    o.order_date,
    o.requested_delivery_date,
    COUNT(oi.id) as item_count,
    o.created_at
FROM orders o
JOIN customers c ON o.customer_id = c.id
LEFT JOIN order_items oi ON o.id = oi.order_id
GROUP BY o.id;

-- Vue des stocks avec alertes
CREATE VIEW v_inventory_alerts AS
SELECT
    p.id as product_id,
    p.product_code,
    p.name as product_name,
    p.reorder_level,
    COALESCE(SUM(i.quantity_available), 0) as total_available,
    CASE
        WHEN COALESCE(SUM(i.quantity_available), 0) <= p.reorder_level THEN 'LOW_STOCK'
        WHEN COALESCE(SUM(i.quantity_available), 0) = 0 THEN 'OUT_OF_STOCK'
        ELSE 'OK'
    END as stock_status
FROM products p
LEFT JOIN inventory i ON p.id = i.product_id
WHERE p.is_active = TRUE
GROUP BY p.id
HAVING stock_status != 'OK';

COMMIT;
