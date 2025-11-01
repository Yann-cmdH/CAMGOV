# 🚀 INSTALLATION MANUELLE - BASE DE DONNÉES VENUS

## ⚠️ PROBLÈME DÉTECTÉ
Le mot de passe MySQL ne correspond pas. Suivez ces étapes pour installer manuellement.

---

## 📋 MÉTHODE 1 : Ligne de Commande (RECOMMANDÉ)

### Étape 1 : Ouvrir PowerShell
```powershell
cd "C:\Users\LENOVO T570\Documents\augment-projects\venus\database"
```

### Étape 2 : Se connecter à MySQL
```powershell
mysql -u root -p
```
**Entrez votre VRAI mot de passe MySQL quand demandé**

### Étape 3 : Exécuter les scripts SQL
Une fois connecté à MySQL, exécutez :

```sql
-- Script 1 : Base principale
SOURCE CREATION_BDD_COMPLETE.sql;

-- Script 2 : Tables supplémentaires
SOURCE TABLES_SUPPLEMENTAIRES.sql;

-- Script 3 : Tests
SOURCE TEST_BDD.sql;
```

### Étape 4 : Vérifier
```sql
USE venus_db;
SHOW TABLES;
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM products;
```

---

## 📋 MÉTHODE 2 : MySQL Workbench (Interface Graphique)

### Étape 1 : Ouvrir MySQL Workbench
1. Lancez **MySQL Workbench**
2. Connectez-vous à votre serveur local

### Étape 2 : Exécuter le premier script
1. **File** → **Open SQL Script**
2. Sélectionnez `CREATION_BDD_COMPLETE.sql`
3. Cliquez sur l'éclair ⚡ **Execute**
4. Attendez la fin (peut prendre 30 secondes)

### Étape 3 : Exécuter le deuxième script
1. **File** → **Open SQL Script**
2. Sélectionnez `TABLES_SUPPLEMENTAIRES.sql`
3. Cliquez sur l'éclair ⚡ **Execute**

### Étape 4 : Exécuter les tests
1. **File** → **Open SQL Script**
2. Sélectionnez `TEST_BDD.sql`
3. Cliquez sur l'éclair ⚡ **Execute**
4. Vérifiez les résultats

---

## 📋 MÉTHODE 3 : phpMyAdmin

### Étape 1 : Ouvrir phpMyAdmin
Allez sur : `http://localhost/phpmyadmin`

### Étape 2 : Onglet SQL
1. Cliquez sur l'onglet **SQL** en haut
2. Cliquez sur **Choisir un fichier**
3. Sélectionnez `CREATION_BDD_COMPLETE.sql`
4. Cliquez sur **Exécuter**

### Étape 3 : Tables supplémentaires
1. Sélectionnez la base `venus_db` dans le menu gauche
2. Onglet **SQL**
3. Choisir `TABLES_SUPPLEMENTAIRES.sql`
4. **Exécuter**

---

## 🔍 TROUVER VOTRE MOT DE PASSE MYSQL

### Option 1 : Vérifier dans d'autres projets
Cherchez dans vos anciens projets PHP/Laravel :
```
.env
config/database.php
```

### Option 2 : Réinitialiser le mot de passe MySQL

#### Windows :
1. Arrêter MySQL :
```powershell
Stop-Service MySQL80
```

2. Démarrer en mode sans mot de passe :
```powershell
mysqld --skip-grant-tables
```

3. Dans un autre terminal :
```powershell
mysql -u root
```

4. Réinitialiser le mot de passe :
```sql
USE mysql;
ALTER USER 'root'@'localhost' IDENTIFIED BY 'ictu2023';
FLUSH PRIVILEGES;
EXIT;
```

5. Redémarrer MySQL normalement :
```powershell
Restart-Service MySQL80
```

---

## ✅ VÉRIFICATION APRÈS INSTALLATION

### Test 1 : Connexion
```powershell
mysql -u root -p
# Entrez votre mot de passe
```

### Test 2 : Vérifier la base
```sql
SHOW DATABASES;
USE venus_db;
SHOW TABLES;
```

Vous devriez voir **40+ tables**.

### Test 3 : Vérifier les données
```sql
SELECT COUNT(*) AS 'Utilisateurs' FROM users;
SELECT COUNT(*) AS 'Produits' FROM products;
SELECT COUNT(*) AS 'Clients' FROM customers;
```

Résultats attendus :
- Utilisateurs : 4
- Produits : 3
- Clients : 3

---

## 🔧 MISE À JOUR DU MOT DE PASSE DANS LE PROJET

Une fois que vous connaissez votre VRAI mot de passe MySQL, mettez à jour :

### Fichier : `backend/src/main/resources/application.properties`

```properties
spring.datasource.password=VOTRE_VRAI_MOT_DE_PASSE_ICI
```

**⚠️ Remplacez par votre vrai mot de passe !**

---

## 📞 AIDE SUPPLÉMENTAIRE

### Erreur : "Can't connect to MySQL server"
**Solution :** MySQL n'est pas démarré
```powershell
Start-Service MySQL80
```

### Erreur : "Access denied"
**Solution :** Mauvais mot de passe
- Vérifiez votre mot de passe
- Ou réinitialisez-le (voir ci-dessus)

### Erreur : "Database already exists"
**Solution :** Supprimez d'abord
```sql
DROP DATABASE venus_db;
```
Puis réexécutez les scripts.

---

## 🎯 APRÈS L'INSTALLATION

1. ✅ Base de données créée
2. ✅ 40+ tables créées
3. ✅ Données de test insérées
4. ⏭️ **Mettre à jour application.properties**
5. ⏭️ **Démarrer Spring Boot**
6. ⏭️ **Tester l'API**

---

**🎉 Une fois installé, revenez me voir pour continuer avec le backend Spring Boot !**

