-- ============================================
-- VENUS - Données de Test
-- Système de Gestion de Distribution Pharmaceutique
-- ============================================

-- Insertion des rôles
INSERT INTO roles (name, description, permissions) VALUES
('ADMIN', 'Administrateur système', '{"all": true}'),
('MANAGER', 'Gestionnaire', '{"products": true, "orders": true, "customers": true, "reports": true}'),
('STOCK_MANAGER', 'Gestionnaire de stock', '{"products": true, "inventory": true, "stock_movements": true}'),
('SALES', 'Commercial', '{"orders": true, "customers": true}'),
('ACCOUNTANT', 'Comptable', '{"orders": true, "payments": true, "reports": true}'),
('VIEWER', 'Consultation uniquement', '{"view_only": true}');

-- Insertion des utilisateurs (mot de passe: password123)
INSERT INTO users (role_id, username, email, password_hash, first_name, last_name, phone) VALUES
(1, 'admin', 'admin@venus-pharma.cm', '$2b$10$rKvvJQxQxQxQxQxQxQxQxOeKqKqKqKqKqKqKqKqKqKqKqKqKqKqKq', 'Admin', 'Venus', '+237670000001'),
(2, 'manager', 'manager@venus-pharma.cm', '$2b$10$rKvvJQxQxQxQxQxQxQxQxOeKqKqKqKqKqKqKqKqKqKqKqKqKqKqKq', 'Jean', 'Dupont', '+237670000002'),
(3, 'stock', 'stock@venus-pharma.cm', '$2b$10$rKvvJQxQxQxQxQxQxQxQxOeKqKqKqKqKqKqKqKqKqKqKqKqKqKqKq', 'Marie', 'Nguema', '+237670000003'),
(4, 'sales', 'sales@venus-pharma.cm', '$2b$10$rKvvJQxQxQxQxQxQxQxQxOeKqKqKqKqKqKqKqKqKqKqKqKqKqKqKq', 'Paul', 'Kamga', '+237670000004');

-- Insertion des catégories de produits
INSERT INTO product_categories (name, description, requires_prescription, storage_conditions) VALUES
('Antibiotiques', 'Médicaments antibactériens', TRUE, 'AMBIENT'),
('Antalgiques', 'Médicaments contre la douleur', FALSE, 'AMBIENT'),
('Antipaludéens', 'Traitement du paludisme', TRUE, 'AMBIENT'),
('Antidiabétiques', 'Traitement du diabète', TRUE, 'AMBIENT'),
('Antihypertenseurs', 'Traitement de l''hypertension', TRUE, 'AMBIENT'),
('Vitamines', 'Compléments vitaminiques', FALSE, 'AMBIENT'),
('Vaccins', 'Vaccins et immunisations', TRUE, 'REFRIGERATED'),
('Perfusions', 'Solutions injectables', FALSE, 'AMBIENT'),
('Matériel médical', 'Dispositifs médicaux', FALSE, 'AMBIENT'),
('Antiseptiques', 'Produits désinfectants', FALSE, 'AMBIENT');

-- Insertion des fournisseurs
INSERT INTO suppliers (supplier_code, name, supplier_type, contact_person, email, phone, address, city, country) VALUES
('SUP001', 'Sanofi Cameroun', 'LABORATORY', 'Dr. Mbarga', 'contact@sanofi.cm', '+237222111111', 'Douala', 'Douala', 'Cameroun'),
('SUP002', 'Pfizer Central Africa', 'LABORATORY', 'Dr. Nkomo', 'info@pfizer.cm', '+237222222222', 'Yaoundé', 'Yaoundé', 'Cameroun'),
('SUP003', 'Novartis Cameroun', 'LABORATORY', 'Dr. Fotso', 'contact@novartis.cm', '+237222333333', 'Douala', 'Douala', 'Cameroun'),
('SUP004', 'GSK Afrique Centrale', 'LABORATORY', 'Dr. Essomba', 'info@gsk.cm', '+237222444444', 'Yaoundé', 'Yaoundé', 'Cameroun'),
('SUP005', 'Laboratoires Locaux SA', 'MANUFACTURER', 'M. Tchoua', 'contact@lablocaux.cm', '+237222555555', 'Yaoundé', 'Yaoundé', 'Cameroun');

-- Insertion des clients
INSERT INTO customers (customer_code, customer_type, name, contact_person, email, phone, address, city, region, credit_limit) VALUES
('CLI001', 'PHARMACY', 'Pharmacie du Centre', 'Mme Atangana', 'centre@pharma.cm', '+237670111111', 'Avenue Kennedy, Yaoundé', 'Yaoundé', 'Centre', 5000000),
('CLI002', 'PHARMACY', 'Pharmacie de la Paix', 'M. Ndi', 'paix@pharma.cm', '+237670222222', 'Bastos, Yaoundé', 'Yaoundé', 'Centre', 3000000),
('CLI003', 'HOSPITAL', 'Hôpital Central de Yaoundé', 'Dr. Mballa', 'hcy@hospital.cm', '+237670333333', 'Centre-ville, Yaoundé', 'Yaoundé', 'Centre', 20000000),
('CLI004', 'HOSPITAL', 'Hôpital Général de Douala', 'Dr. Ewane', 'hgd@hospital.cm', '+237670444444', 'Akwa, Douala', 'Douala', 'Littoral', 25000000),
('CLI005', 'PHARMACY', 'Pharmacie Moderne', 'Mme Fouda', 'moderne@pharma.cm', '+237670555555', 'Melen, Yaoundé', 'Yaoundé', 'Centre', 4000000),
('CLI006', 'CLINIC', 'Clinique des Spécialités', 'Dr. Onana', 'specialites@clinic.cm', '+237670666666', 'Bastos, Yaoundé', 'Yaoundé', 'Centre', 10000000),
('CLI007', 'PHARMACY', 'Pharmacie de l''Espoir', 'M. Biya', 'espoir@pharma.cm', '+237670777777', 'Mvog-Ada, Yaoundé', 'Yaoundé', 'Centre', 3500000),
('CLI008', 'PHARMACY', 'Pharmacie du Marché', 'Mme Njoya', 'marche@pharma.cm', '+237670888888', 'Mokolo, Yaoundé', 'Yaoundé', 'Centre', 2500000);

-- Insertion des produits
INSERT INTO products (product_code, category_id, supplier_id, name, generic_name, description, dosage, form, packaging, purchase_price, selling_price, reorder_level, reorder_quantity) VALUES
('PROD001', 1, 1, 'Amoxicilline 500mg', 'Amoxicilline', 'Antibiotique à large spectre', '500mg', 'CAPSULE', 'Boîte de 12', 2500, 3500, 50, 200),
('PROD002', 2, 2, 'Paracétamol 1000mg', 'Paracétamol', 'Antalgique et antipyrétique', '1000mg', 'TABLET', 'Boîte de 8', 500, 800, 100, 500),
('PROD003', 3, 3, 'Artesunate 100mg', 'Artesunate', 'Antipaludéen', '100mg', 'TABLET', 'Boîte de 6', 3000, 4500, 30, 150),
('PROD004', 4, 4, 'Metformine 850mg', 'Metformine', 'Antidiabétique oral', '850mg', 'TABLET', 'Boîte de 30', 4000, 6000, 40, 200),
('PROD005', 5, 1, 'Amlodipine 5mg', 'Amlodipine', 'Antihypertenseur', '5mg', 'TABLET', 'Boîte de 30', 3500, 5500, 35, 150),
('PROD006', 6, 5, 'Vitamine C 1000mg', 'Acide Ascorbique', 'Complément vitaminique', '1000mg', 'TABLET', 'Boîte de 20', 1500, 2500, 60, 300),
('PROD007', 1, 2, 'Ciprofloxacine 500mg', 'Ciprofloxacine', 'Antibiotique fluoroquinolone', '500mg', 'TABLET', 'Boîte de 10', 4500, 6500, 25, 100),
('PROD008', 2, 3, 'Ibuprofène 400mg', 'Ibuprofène', 'Anti-inflammatoire', '400mg', 'TABLET', 'Boîte de 20', 1800, 2800, 80, 400),
('PROD009', 3, 4, 'Coartem', 'Artemether + Lumefantrine', 'Antipaludéen combiné', 'Combiné', 'TABLET', 'Boîte de 24', 5000, 7500, 40, 200),
('PROD010', 8, 1, 'Sérum Physiologique 500ml', 'NaCl 0.9%', 'Solution injectable', '500ml', 'INJECTION', 'Poche de 500ml', 800, 1200, 100, 500),
('PROD011', 9, 5, 'Gants médicaux (boîte)', 'Gants latex', 'Gants d''examen', 'Taille M', 'BOX', 'Boîte de 100', 3000, 4500, 20, 100),
('PROD012', 10, 2, 'Alcool 70° (1L)', 'Éthanol 70%', 'Antiseptique', '1L', 'LIQUID', 'Flacon 1L', 2000, 3000, 30, 150);

-- Insertion de l'inventaire initial
INSERT INTO inventory (product_id, quantity_in_stock, quantity_reserved, minimum_stock, maximum_stock) VALUES
(1, 150, 0, 50, 500),
(2, 300, 0, 100, 1000),
(3, 80, 0, 30, 300),
(4, 120, 0, 40, 400),
(5, 100, 0, 35, 350),
(6, 200, 0, 60, 600),
(7, 60, 0, 25, 250),
(8, 250, 0, 80, 800),
(9, 90, 0, 40, 400),
(10, 400, 0, 100, 1000),
(11, 50, 0, 20, 200),
(12, 80, 0, 30, 300);

-- Insertion des lots de produits
INSERT INTO product_batches (product_id, batch_number, manufacturing_date, expiry_date, quantity_received, quantity_remaining, supplier_id, purchase_price, storage_location, quality_status) VALUES
(1, 'AMOX2024001', '2024-01-15', '2026-01-15', 200, 150, 1, 2500, 'Zone A-Shelf 1', 'APPROVED'),
(2, 'PARA2024001', '2024-02-01', '2026-02-01', 500, 300, 2, 500, 'Zone A-Shelf 2', 'APPROVED'),
(3, 'ARTE2024001', '2024-01-20', '2025-07-20', 100, 80, 3, 3000, 'Zone B-Shelf 1', 'APPROVED'),
(4, 'METF2024001', '2024-03-01', '2026-03-01', 150, 120, 4, 4000, 'Zone A-Shelf 3', 'APPROVED'),
(5, 'AMLO2024001', '2024-02-15', '2026-02-15', 120, 100, 1, 3500, 'Zone A-Shelf 4', 'APPROVED'),
(6, 'VITC2024001', '2024-01-10', '2025-12-10', 300, 200, 5, 1500, 'Zone C-Shelf 1', 'APPROVED'),
(7, 'CIPR2024001', '2024-02-20', '2026-02-20', 80, 60, 2, 4500, 'Zone B-Shelf 2', 'APPROVED'),
(8, 'IBUP2024001', '2024-03-05', '2026-03-05', 400, 250, 3, 1800, 'Zone A-Shelf 5', 'APPROVED'),
(9, 'COAR2024001', '2024-01-25', '2025-06-25', 120, 90, 4, 5000, 'Zone B-Shelf 3', 'APPROVED'),
(10, 'SERU2024001', '2024-03-10', '2026-03-10', 500, 400, 1, 800, 'Zone D-Shelf 1', 'APPROVED'),
(11, 'GANT2024001', '2024-02-01', '2027-02-01', 100, 50, 5, 3000, 'Zone E-Shelf 1', 'APPROVED'),
(12, 'ALCO2024001', '2024-03-01', '2026-03-01', 100, 80, 2, 2000, 'Zone C-Shelf 2', 'APPROVED');

-- Insertion de quelques commandes
INSERT INTO orders (order_number, customer_id, order_date, required_date, status, priority, subtotal, tax_amount, total_amount, payment_status, payment_method, delivery_address, created_by) VALUES
('ORD2025001', 1, '2025-01-15 10:30:00', '2025-01-16', 'DELIVERED', 'NORMAL', 50000, 9500, 59500, 'PAID', 'MOBILE_MONEY', 'Avenue Kennedy, Yaoundé', 4),
('ORD2025002', 3, '2025-01-16 14:20:00', '2025-01-17', 'SHIPPED', 'HIGH', 250000, 47500, 297500, 'PAID', 'BANK_TRANSFER', 'Hôpital Central, Yaoundé', 4),
('ORD2025003', 2, '2025-01-17 09:15:00', '2025-01-18', 'PROCESSING', 'NORMAL', 35000, 6650, 41650, 'PENDING', 'CREDIT', 'Bastos, Yaoundé', 4),
('ORD2025004', 5, '2025-01-18 11:45:00', '2025-01-19', 'CONFIRMED', 'NORMAL', 42000, 7980, 49980, 'PENDING', 'MOBILE_MONEY', 'Melen, Yaoundé', 4);

-- Insertion des détails de commandes
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, tax_rate, line_total) VALUES
(1, 1, 1, 10, 3500, 19, 41650),
(1, 2, 2, 20, 800, 19, 19040),
(2, 3, 3, 30, 4500, 19, 160650),
(2, 4, 4, 20, 6000, 19, 142800),
(3, 5, 5, 15, 5500, 19, 98175),
(3, 8, 8, 25, 2800, 19, 83300),
(4, 6, 6, 30, 2500, 19, 89250),
(4, 10, 10, 50, 1200, 19, 71400);

-- Insertion de mouvements de stock
INSERT INTO stock_movements (product_id, batch_id, movement_type, quantity, reference_type, reference_id, user_id, notes) VALUES
(1, 1, 'IN', 200, 'PURCHASE', 1, 3, 'Réception lot AMOX2024001'),
(2, 2, 'IN', 500, 'PURCHASE', 2, 3, 'Réception lot PARA2024001'),
(1, 1, 'OUT', 10, 'ORDER', 1, 3, 'Commande ORD2025001'),
(2, 2, 'OUT', 20, 'ORDER', 1, 3, 'Commande ORD2025001'),
(3, 3, 'OUT', 30, 'ORDER', 2, 3, 'Commande ORD2025002'),
(4, 4, 'OUT', 20, 'ORDER', 2, 3, 'Commande ORD2025002');

-- Insertion d'alertes de stock
INSERT INTO stock_alerts (product_id, alert_type, severity, message) VALUES
(3, 'EXPIRING_SOON', 'HIGH', 'Le lot ARTE2024001 expire dans 6 mois'),
(9, 'EXPIRING_SOON', 'HIGH', 'Le lot COAR2024001 expire dans 5 mois'),
(6, 'EXPIRING_SOON', 'MEDIUM', 'Le lot VITC2024001 expire dans 11 mois');

-- Insertion de transactions de paiement
INSERT INTO payment_transactions (order_id, transaction_number, payment_method, amount, status, reference_number, payment_date) VALUES
(1, 'PAY2025001', 'MTN_MOMO', 59500, 'COMPLETED', 'MTN123456789', '2025-01-15 15:30:00'),
(2, 'PAY2025002', 'BANK_TRANSFER', 297500, 'COMPLETED', 'BANK987654321', '2025-01-16 16:45:00');

-- Insertion de notifications
INSERT INTO notifications (user_id, type, title, message, link) VALUES
(3, 'WARNING', 'Stock faible', 'Le produit Ciprofloxacine 500mg a atteint le niveau de réapprovisionnement', '/inventory/7'),
(3, 'WARNING', 'Expiration proche', 'Le lot ARTE2024001 expire dans 6 mois', '/batches/3'),
(4, 'INFO', 'Nouvelle commande', 'Nouvelle commande ORD2025004 de Pharmacie Moderne', '/orders/4'),
(1, 'INFO', 'Rapport mensuel', 'Le rapport mensuel de janvier est disponible', '/reports/monthly');

-- ============================================
-- FIN DES DONNÉES DE TEST
-- ============================================

