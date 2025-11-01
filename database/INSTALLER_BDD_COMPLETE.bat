@echo off
REM ============================================
REM VENUS - Installation Base de Données MySQL
REM ============================================

echo.
echo ========================================
echo   VENUS - Installation Base de Donnees
echo   Yaounde, Cameroun
echo ========================================
echo.

REM Vérifier que MySQL est installé
where mysql >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERREUR] MySQL n'est pas installe ou pas dans le PATH
    echo.
    echo Installez MySQL ou ajoutez-le au PATH systeme
    pause
    exit /b 1
)

echo [OK] MySQL detecte
echo.

REM Demander confirmation
echo Cette operation va:
echo   1. SUPPRIMER la base de donnees venus_db si elle existe
echo   2. CREER une nouvelle base de donnees venus_db
echo   3. CREER toutes les tables (40+ tables)
echo   4. INSERER les donnees de test
echo.
set /p confirm="Continuer? (O/N): "
if /i not "%confirm%"=="O" (
    echo Operation annulee
    pause
    exit /b 0
)

echo.
echo ========================================
echo   ETAPE 1: Creation de la base
echo ========================================
echo.

REM Exécuter le script principal
mysql -u root -p"Abdel@ictu2023" < CREATION_BDD_COMPLETE.sql
if %ERRORLEVEL% NEQ 0 (
    echo [ERREUR] Echec de la creation de la base principale
    pause
    exit /b 1
)

echo [OK] Base de donnees principale creee

echo.
echo ========================================
echo   ETAPE 2: Tables supplementaires
echo ========================================
echo.

REM Exécuter les tables supplémentaires
mysql -u root -p"Abdel@ictu2023" < TABLES_SUPPLEMENTAIRES.sql
if %ERRORLEVEL% NEQ 0 (
    echo [ERREUR] Echec de la creation des tables supplementaires
    pause
    exit /b 1
)

echo [OK] Tables supplementaires creees

echo.
echo ========================================
echo   ETAPE 3: Tests de verification
echo ========================================
echo.

REM Exécuter les tests
mysql -u root -p"Abdel@ictu2023" < TEST_BDD.sql
if %ERRORLEVEL% NEQ 0 (
    echo [ERREUR] Echec des tests
    pause
    exit /b 1
)

echo.
echo ========================================
echo   INSTALLATION TERMINEE AVEC SUCCES!
echo ========================================
echo.
echo Base de donnees: venus_db
echo Tables creees: 40+ tables
echo Donnees de test: Inserees
echo.
echo Comptes de test:
echo   - admin / password123
echo   - manager / password123
echo   - stock / password123
echo   - sales / password123
echo.
echo Prochaine etape:
echo   Demarrer le backend Spring Boot
echo.
pause

