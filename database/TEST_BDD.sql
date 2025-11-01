-- ============================================
-- SCRIPT DE TEST - BASE DE DONNÉES VENUS
-- ============================================

USE venus_db;

-- ============================================
-- TEST 1: Vérifier les tables
-- ============================================
SELECT '=== TEST 1: TABLES ===' AS Test;
SELECT COUNT(*) AS 'Nombre total de tables' 
FROM information_schema.tables 
WHERE table_schema = 'venus_db';

-- ============================================
-- TEST 2: Vérifier les données de base
-- ============================================
SELECT '=== TEST 2: DONNÉES DE BASE ===' AS Test;

SELECT COUNT(*) AS 'Rôles' FROM roles;
SELECT COUNT(*) AS 'Utilisateurs' FROM users;
SELECT COUNT(*) AS 'Zones de stockage' FROM storage_zones;
SELECT COUNT(*) AS 'Catégories' FROM product_categories;
SELECT COUNT(*) AS 'Fournisseurs' FROM suppliers;
SELECT COUNT(*) AS 'Clients' FROM customers;
SELECT COUNT(*) AS 'Produits' FROM products;

-- ============================================
-- TEST 3: Afficher les utilisateurs
-- ============================================
SELECT '=== TEST 3: UTILISATEURS ===' AS Test;

SELECT 
    u.id,
    u.username,
    u.email,
    CONCAT(u.first_name, ' ', u.last_name) AS nom_complet,
    r.name AS role,
    u.is_active AS actif
FROM users u
JOIN roles r ON u.role_id = r.id;

-- ============================================
-- TEST 4: Afficher les produits avec inventaire
-- ============================================
SELECT '=== TEST 4: PRODUITS & INVENTAIRE ===' AS Test;

SELECT 
    p.product_code AS code,
    p.name AS produit,
    c.name AS categorie,
    p.selling_price AS prix_vente,
    COALESCE(i.quantity_in_stock, 0) AS stock,
    COALESCE(i.quantity_available, 0) AS disponible,
    p.is_active AS actif
FROM products p
LEFT JOIN product_categories c ON p.category_id = c.id
LEFT JOIN inventory i ON p.id = i.product_id;

-- ============================================
-- TEST 5: Afficher les lots avec dates d'expiration
-- ============================================
SELECT '=== TEST 5: LOTS & EXPIRATION ===' AS Test;

SELECT 
    pb.batch_number AS numero_lot,
    p.name AS produit,
    pb.manufacturing_date AS fabrication,
    pb.expiry_date AS expiration,
    DATEDIFF(pb.expiry_date, CURDATE()) AS jours_avant_expiration,
    pb.quantity_remaining AS quantite_restante,
    pb.quality_status AS statut
FROM product_batches pb
JOIN products p ON pb.product_id = p.id
ORDER BY pb.expiry_date ASC;

-- ============================================
-- TEST 6: Afficher les clients
-- ============================================
SELECT '=== TEST 6: CLIENTS ===' AS Test;

SELECT 
    customer_code AS code,
    company_name AS nom,
    customer_type AS type,
    city AS ville,
    phone AS telephone,
    credit_limit AS limite_credit,
    is_verified AS verifie,
    is_active AS actif
FROM customers;

-- ============================================
-- TEST 7: Vérifier les relations (Foreign Keys)
-- ============================================
SELECT '=== TEST 7: RELATIONS (FOREIGN KEYS) ===' AS Test;

SELECT 
    COUNT(*) AS 'Nombre de Foreign Keys'
FROM information_schema.KEY_COLUMN_USAGE
WHERE table_schema = 'venus_db'
AND referenced_table_name IS NOT NULL;

-- ============================================
-- TEST 8: Vérifier les index
-- ============================================
SELECT '=== TEST 8: INDEX ===' AS Test;

SELECT 
    COUNT(DISTINCT index_name) AS 'Nombre d\'index'
FROM information_schema.statistics
WHERE table_schema = 'venus_db'
AND index_name != 'PRIMARY';

-- ============================================
-- TEST 9: Statistiques globales
-- ============================================
SELECT '=== TEST 9: STATISTIQUES GLOBALES ===' AS Test;

SELECT 
    'Utilisateurs' AS Type,
    COUNT(*) AS Total,
    SUM(CASE WHEN is_active = TRUE THEN 1 ELSE 0 END) AS Actifs
FROM users

UNION ALL

SELECT 
    'Produits' AS Type,
    COUNT(*) AS Total,
    SUM(CASE WHEN is_active = TRUE THEN 1 ELSE 0 END) AS Actifs
FROM products

UNION ALL

SELECT 
    'Clients' AS Type,
    COUNT(*) AS Total,
    SUM(CASE WHEN is_active = TRUE THEN 1 ELSE 0 END) AS Actifs
FROM customers

UNION ALL

SELECT 
    'Fournisseurs' AS Type,
    COUNT(*) AS Total,
    SUM(CASE WHEN is_active = TRUE THEN 1 ELSE 0 END) AS Actifs
FROM suppliers;

-- ============================================
-- TEST 10: Paramètres système
-- ============================================
SELECT '=== TEST 10: PARAMÈTRES SYSTÈME ===' AS Test;

SELECT 
    setting_key AS parametre,
    setting_value AS valeur,
    category AS categorie
FROM system_settings
ORDER BY category, setting_key;

-- ============================================
-- RÉSULTAT FINAL
-- ============================================
SELECT '=== ✅ TOUS LES TESTS TERMINÉS ===' AS Resultat;
SELECT 'Base de données VENUS opérationnelle!' AS Status;

