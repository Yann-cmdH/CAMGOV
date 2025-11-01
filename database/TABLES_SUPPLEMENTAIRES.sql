-- ============================================
-- VENUS - TABLES SUPPLÉMENTAIRES CRITIQUES
-- Tables manquantes pour système pharmaceutique complet
-- ============================================

USE venus_db;

-- ============================================
-- MODULE 12: GESTION DES PRESCRIPTIONS
-- ============================================

CREATE TABLE prescriptions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    prescription_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id BIGINT NOT NULL,
    doctor_name VARCHAR(255) NOT NULL COMMENT 'Nom du médecin prescripteur',
    doctor_license VARCHAR(100) COMMENT 'Numéro d\'ordre du médecin',
    patient_name VARCHAR(255) NOT NULL,
    patient_age INT,
    patient_gender ENUM('M', 'F', 'OTHER'),
    prescription_date DATE NOT NULL,
    expiry_date DATE COMMENT 'Date d\'expiration de l\'ordonnance',
    diagnosis TEXT COMMENT 'Diagnostic',
    status ENUM('PENDING', 'VALIDATED', 'PARTIALLY_FILLED', 'FILLED', 'EXPIRED', 'REJECTED') DEFAULT 'PENDING',
    validated_by BIGINT COMMENT 'Pharmacien validateur',
    validated_at TIMESTAMP NULL,
    image_url VARCHAR(500) COMMENT 'Scan de l\'ordonnance',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (validated_by) REFERENCES users(id),
    INDEX idx_prescription_number (prescription_number),
    INDEX idx_prescription_customer (customer_id),
    INDEX idx_prescription_status (status),
    INDEX idx_prescription_date (prescription_date)
) ENGINE=InnoDB COMMENT='Ordonnances médicales';

CREATE TABLE prescription_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    prescription_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity_prescribed INT NOT NULL,
    quantity_dispensed INT DEFAULT 0,
    dosage_instructions TEXT COMMENT 'Posologie',
    duration_days INT COMMENT 'Durée du traitement en jours',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (prescription_id) REFERENCES prescriptions(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    INDEX idx_prescription_item_prescription (prescription_id),
    INDEX idx_prescription_item_product (product_id)
) ENGINE=InnoDB COMMENT='Détails des prescriptions';

-- ============================================
-- MODULE 13: GESTION DES PRIX & PROMOTIONS
-- ============================================

CREATE TABLE price_history (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    price_type ENUM('PURCHASE', 'SELLING', 'WHOLESALE') NOT NULL,
    old_price DECIMAL(15,2) NOT NULL,
    new_price DECIMAL(15,2) NOT NULL,
    change_reason TEXT,
    effective_date DATE NOT NULL,
    changed_by BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (changed_by) REFERENCES users(id),
    INDEX idx_price_history_product (product_id),
    INDEX idx_price_history_date (effective_date)
) ENGINE=InnoDB COMMENT='Historique des changements de prix';

CREATE TABLE promotions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    promotion_code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    promotion_type ENUM('PERCENTAGE', 'FIXED_AMOUNT', 'BUY_X_GET_Y', 'FREE_SHIPPING') NOT NULL,
    discount_value DECIMAL(15,2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    min_purchase_amount DECIMAL(15,2) DEFAULT 0,
    max_discount_amount DECIMAL(15,2),
    usage_limit INT COMMENT 'Nombre max d\'utilisations',
    usage_count INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    applies_to ENUM('ALL', 'CATEGORY', 'PRODUCT', 'CUSTOMER_TYPE') DEFAULT 'ALL',
    created_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id),
    INDEX idx_promotion_code (promotion_code),
    INDEX idx_promotion_dates (start_date, end_date),
    INDEX idx_promotion_active (is_active)
) ENGINE=InnoDB COMMENT='Promotions et offres spéciales';

CREATE TABLE promotion_products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    promotion_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (promotion_id) REFERENCES promotions(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    UNIQUE KEY unique_promotion_product (promotion_id, product_id)
) ENGINE=InnoDB COMMENT='Produits en promotion';

-- ============================================
-- MODULE 14: GESTION DES TRANSPORTEURS
-- ============================================

CREATE TABLE carriers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    carrier_code VARCHAR(50) UNIQUE NOT NULL,
    company_name VARCHAR(255) NOT NULL,
    contact_person VARCHAR(255),
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(255),
    address TEXT,
    vehicle_count INT DEFAULT 0,
    rating DECIMAL(3,2) DEFAULT 0 COMMENT 'Note 0-5',
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_carrier_code (carrier_code),
    INDEX idx_carrier_active (is_active)
) ENGINE=InnoDB COMMENT='Transporteurs et livreurs';

CREATE TABLE vehicles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    carrier_id BIGINT,
    vehicle_number VARCHAR(50) UNIQUE NOT NULL COMMENT 'Plaque d\'immatriculation',
    vehicle_type ENUM('MOTORCYCLE', 'CAR', 'VAN', 'TRUCK', 'REFRIGERATED_TRUCK') NOT NULL,
    capacity_kg DECIMAL(10,2),
    has_refrigeration BOOLEAN DEFAULT FALSE,
    driver_name VARCHAR(255),
    driver_phone VARCHAR(20),
    driver_license VARCHAR(100),
    insurance_number VARCHAR(100),
    insurance_expiry DATE,
    last_maintenance_date DATE,
    next_maintenance_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (carrier_id) REFERENCES carriers(id),
    INDEX idx_vehicle_number (vehicle_number),
    INDEX idx_vehicle_carrier (carrier_id),
    INDEX idx_vehicle_active (is_active)
) ENGINE=InnoDB COMMENT='Flotte de véhicules';

-- ============================================
-- MODULE 15: GESTION DES DOCUMENTS
-- ============================================

CREATE TABLE documents (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    document_number VARCHAR(50) UNIQUE NOT NULL,
    document_type ENUM('INVOICE', 'DELIVERY_NOTE', 'CERTIFICATE', 'PRESCRIPTION', 'REPORT', 'CONTRACT', 'OTHER') NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    file_url VARCHAR(500) NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_size BIGINT COMMENT 'Taille en bytes',
    mime_type VARCHAR(100),
    reference_type VARCHAR(50) COMMENT 'Type de référence: ORDER, PRODUCT, CUSTOMER',
    reference_id BIGINT,
    uploaded_by BIGINT NOT NULL,
    is_public BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (uploaded_by) REFERENCES users(id),
    INDEX idx_document_number (document_number),
    INDEX idx_document_type (document_type),
    INDEX idx_document_reference (reference_type, reference_id)
) ENGINE=InnoDB COMMENT='Documents et fichiers';

-- ============================================
-- MODULE 16: GESTION DES CONTACTS CLIENTS
-- ============================================

CREATE TABLE customer_contacts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    contact_type ENUM('PRIMARY', 'BILLING', 'DELIVERY', 'TECHNICAL', 'OTHER') NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    position VARCHAR(100) COMMENT 'Poste/Fonction',
    email VARCHAR(255),
    phone VARCHAR(20) NOT NULL,
    phone_secondary VARCHAR(20),
    is_primary BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    INDEX idx_contact_customer (customer_id),
    INDEX idx_contact_type (contact_type)
) ENGINE=InnoDB COMMENT='Contacts multiples par client';

-- ============================================
-- MODULE 17: GESTION DES DEVIS (QUOTATIONS)
-- ============================================

CREATE TABLE quotations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    quotation_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id BIGINT NOT NULL,
    quotation_date DATE NOT NULL,
    valid_until DATE NOT NULL,
    status ENUM('DRAFT', 'SENT', 'ACCEPTED', 'REJECTED', 'EXPIRED', 'CONVERTED') DEFAULT 'DRAFT',
    subtotal DECIMAL(15,2) DEFAULT 0,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    total_amount DECIMAL(15,2) DEFAULT 0,
    payment_terms INT DEFAULT 30,
    delivery_terms TEXT,
    notes TEXT,
    internal_notes TEXT,
    created_by BIGINT NOT NULL,
    converted_to_order_id BIGINT COMMENT 'ID de la commande si converti',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (converted_to_order_id) REFERENCES orders(id),
    INDEX idx_quotation_number (quotation_number),
    INDEX idx_quotation_customer (customer_id),
    INDEX idx_quotation_status (status)
) ENGINE=InnoDB COMMENT='Devis clients';

CREATE TABLE quotation_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    quotation_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(15,2) NOT NULL,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    tax_rate DECIMAL(5,2) DEFAULT 19.00,
    line_total DECIMAL(15,2) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (quotation_id) REFERENCES quotations(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    INDEX idx_quotation_item_quotation (quotation_id),
    INDEX idx_quotation_item_product (product_id)
) ENGINE=InnoDB COMMENT='Détails des devis';

-- ============================================
-- MODULE 18: MONITORING TEMPÉRATURE (CRITIQUE)
-- ============================================

CREATE TABLE temperature_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    storage_zone_id BIGINT NOT NULL,
    temperature DECIMAL(5,2) NOT NULL COMMENT 'Température en °C',
    humidity DECIMAL(5,2) COMMENT 'Humidité en %',
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    recorded_by BIGINT COMMENT 'Utilisateur ou système automatique',
    is_alert BOOLEAN DEFAULT FALSE COMMENT 'Température hors limites',
    alert_handled BOOLEAN DEFAULT FALSE,
    notes TEXT,
    FOREIGN KEY (storage_zone_id) REFERENCES storage_zones(id),
    FOREIGN KEY (recorded_by) REFERENCES users(id),
    INDEX idx_temp_zone (storage_zone_id),
    INDEX idx_temp_date (recorded_at),
    INDEX idx_temp_alert (is_alert, alert_handled)
) ENGINE=InnoDB COMMENT='Logs de température pour chaîne du froid';

-- ============================================
-- MODULE 19: SÉCURITÉ & TOKENS
-- ============================================

CREATE TABLE refresh_tokens (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token VARCHAR(500) UNIQUE NOT NULL,
    expiry_date TIMESTAMP NOT NULL,
    is_revoked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_token_user (user_id),
    INDEX idx_token_expiry (expiry_date)
) ENGINE=InnoDB COMMENT='Tokens de rafraîchissement JWT';

CREATE TABLE password_reset_tokens (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token VARCHAR(255) UNIQUE NOT NULL,
    expiry_date TIMESTAMP NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_reset_token (token),
    INDEX idx_reset_user (user_id)
) ENGINE=InnoDB COMMENT='Tokens de réinitialisation de mot de passe';

-- ============================================
-- MODULE 20: PORTAIL CLIENT - FAVORIS
-- ============================================

CREATE TABLE customer_wishlists (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    UNIQUE KEY unique_wishlist (customer_id, product_id),
    INDEX idx_wishlist_customer (customer_id)
) ENGINE=InnoDB COMMENT='Produits favoris des clients';

CREATE TABLE recurring_orders (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    order_name VARCHAR(255) NOT NULL,
    frequency ENUM('DAILY', 'WEEKLY', 'BIWEEKLY', 'MONTHLY', 'QUARTERLY') NOT NULL,
    next_order_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    INDEX idx_recurring_customer (customer_id),
    INDEX idx_recurring_next_date (next_order_date)
) ENGINE=InnoDB COMMENT='Commandes récurrentes automatiques';

CREATE TABLE recurring_order_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    recurring_order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (recurring_order_id) REFERENCES recurring_orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    INDEX idx_recurring_item_order (recurring_order_id)
) ENGINE=InnoDB COMMENT='Détails des commandes récurrentes';

-- ============================================
-- FIN DES TABLES SUPPLÉMENTAIRES
-- ============================================

SELECT 'Tables supplémentaires créées avec succès!' AS Status;

