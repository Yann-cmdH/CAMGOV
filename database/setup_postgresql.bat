@echo off
echo =====================================================
echo CONFIGURATION POSTGRESQL POUR VENUS PHARMA ERP
echo =====================================================

echo.
echo 1. Demarrage du service PostgreSQL...
net start postgresql-x64-15

echo.
echo 2. Creation de l'utilisateur venus_user...
psql -U postgres -c "CREATE USER venus_user WITH PASSWORD 'venus123';"

echo.
echo 3. Creation de la base de donnees venus_pharma...
psql -U postgres -c "CREATE DATABASE venus_pharma OWNER venus_user;"

echo.
echo 4. Attribution des privileges...
psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE venus_pharma TO venus_user;"

echo.
echo 5. Execution du script de creation des tables...
psql -U venus_user -d venus_pharma -f "create_venus_database_postgresql.sql"

echo.
echo =====================================================
echo CONFIGURATION TERMINEE !
echo =====================================================
echo Base de donnees: venus_pharma
echo Utilisateur: venus_user
echo Mot de passe: venus123
echo Port: 5432
echo =====================================================

pause
