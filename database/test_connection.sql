-- =====================================================
-- TEST DE CONNEXION POSTGRESQL VENUS PHARMA
-- =====================================================

-- Vérifier la version PostgreSQL
SELECT version();

-- Vérifier les bases de données
SELECT datname FROM pg_database WHERE datname = 'venus_pharma';

-- Vérifier les utilisateurs
SELECT usename FROM pg_user WHERE usename = 'venus_user';

-- Vérifier les tables créées
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Vérifier les données de base
SELECT COUNT(*) as nb_roles FROM system_roles;
SELECT COUNT(*) as nb_users FROM system_users;
SELECT COUNT(*) as nb_categories FROM product_categories;
SELECT COUNT(*) as nb_zones FROM storage_zones;
SELECT COUNT(*) as nb_accounts FROM chart_of_accounts;

-- Test de connexion réussi
SELECT 'Connexion PostgreSQL Venus Pharma réussie !' as status;
