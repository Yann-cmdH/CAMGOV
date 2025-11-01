# 🗄️ GUIDE D'EXÉCUTION - BASE DE DONNÉES VENUS

## ✅ ÉTAPE 1 : Vérifier MySQL

### Windows (PowerShell)
```powershell
# Vérifier que MySQL est installé
mysql --version

# Vérifier que MySQL est démarré
Get-Service MySQL*
```

Si MySQL n'est pas démarré :
```powershell
# Démarrer MySQL
Start-Service MySQL80  # ou MySQL57, selon votre version
```

---

## ✅ ÉTAPE 2 : Exécuter le Script SQL

### Option A : Ligne de commande (RECOMMANDÉ)

```powershell
# Aller dans le dossier database
cd "C:\Users\LENOVO T570\Documents\augment-projects\venus\database"

# Exécuter le script
mysql -u root -p < CREATION_BDD_COMPLETE.sql
```

**Entrez votre mot de passe MySQL root quand demandé.**

### Option B : MySQL Workbench (Interface graphique)

1. Ouvrir **MySQL Workbench**
2. Se connecter à votre serveur MySQL local
3. File → Open SQL Script
4. Sélectionner `CREATION_BDD_COMPLETE.sql`
5. Cliquer sur l'éclair ⚡ (Execute)

### Option C : phpMyAdmin

1. Ouvrir **phpMyAdmin** dans le navigateur
2. Onglet **SQL**
3. Cliquer sur **Choisir un fichier**
4. Sélectionner `CREATION_BDD_COMPLETE.sql`
5. Cliquer sur **Exécuter**

---

## ✅ ÉTAPE 3 : Vérifier la Création

### Vérifier que la base existe

```sql
SHOW DATABASES;
```

Vous devriez voir `venus_db` dans la liste.

### Vérifier les tables

```sql
USE venus_db;
SHOW TABLES;
```

Vous devriez voir **30+ tables**.

### Vérifier les données de test

```sql
-- Vérifier les utilisateurs
SELECT id, username, email, first_name, last_name FROM users;

-- Vérifier les produits
SELECT id, product_code, name, selling_price FROM products;

-- Vérifier les clients
SELECT id, customer_code, company_name, city FROM customers;

-- Vérifier l'inventaire
SELECT p.name, i.quantity_in_stock, i.quantity_available 
FROM inventory i 
JOIN products p ON i.product_id = p.id;
```

---

## ✅ ÉTAPE 4 : Configurer Spring Boot

Éditez le fichier : `backend/src/main/resources/application.properties`

```properties
# Configuration MySQL
spring.datasource.url=jdbc:mysql://localhost:3306/venus_db?useSSL=false&serverTimezone=Africa/Douala&allowPublicKeyRetrieval=true
spring.datasource.username=root
spring.datasource.password=VOTRE_MOT_DE_PASSE_ICI
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

# JPA/Hibernate
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQLDialect
```

**⚠️ IMPORTANT : Remplacez `VOTRE_MOT_DE_PASSE_ICI` par votre vrai mot de passe MySQL !**

---

## ✅ ÉTAPE 5 : Tester la Connexion

### Test rapide avec MySQL

```sql
USE venus_db;

-- Test de connexion
SELECT 'Connexion réussie!' AS Status;

-- Statistiques
SELECT 
    (SELECT COUNT(*) FROM users) AS Utilisateurs,
    (SELECT COUNT(*) FROM products) AS Produits,
    (SELECT COUNT(*) FROM customers) AS Clients,
    (SELECT COUNT(*) FROM orders) AS Commandes;
```

---

## 📊 STRUCTURE DE LA BASE DE DONNÉES

### Tables Principales (30+ tables)

| Module | Tables | Description |
|--------|--------|-------------|
| **Utilisateurs** | roles, users, login_attempts | Gestion des utilisateurs et sécurité |
| **Partenaires** | customers, suppliers | Clients B2B et fournisseurs |
| **Catalogue** | product_categories, products | Produits pharmaceutiques |
| **Stock** | inventory, product_batches, storage_zones, stock_movements, stock_alerts | Gestion complète du stock |
| **Commandes** | orders, order_items, delivery_tracking | Commandes clients |
| **Finance** | payment_transactions, invoices | Paiements et facturation |
| **Qualité** | product_recalls, product_returns, return_items | Rappels et retours |
| **Achats** | purchase_orders, purchase_order_items, goods_receipts, goods_receipt_items | Approvisionnement |
| **Communication** | notifications, email_logs, sms_logs | Notifications |
| **Audit** | audit_logs, system_settings | Traçabilité et configuration |
| **Reporting** | reports | Rapports générés |

---

## 🔐 COMPTES DE TEST

| Username | Password | Rôle | Email |
|----------|----------|------|-------|
| admin | password123 | Administrateur | admin@venus.cm |
| manager | password123 | Gestionnaire | manager@venus.cm |
| stock | password123 | Gestionnaire Stock | stock@venus.cm |
| sales | password123 | Commercial | sales@venus.cm |

**⚠️ Changez ces mots de passe en production !**

---

## 🐛 DÉPANNAGE

### Erreur : "Access denied for user 'root'@'localhost'"

**Solution :** Vérifiez votre mot de passe MySQL

```powershell
mysql -u root -p
# Entrez votre mot de passe
```

### Erreur : "Unknown database 'venus_db'"

**Solution :** La base n'a pas été créée. Réexécutez le script.

### Erreur : "Table already exists"

**Solution :** La base existe déjà. Pour recommencer :

```sql
DROP DATABASE venus_db;
```

Puis réexécutez le script.

### Erreur : "Can't connect to MySQL server"

**Solution :** MySQL n'est pas démarré

```powershell
# Windows
Start-Service MySQL80

# Ou redémarrer
Restart-Service MySQL80
```

---

## ✅ CHECKLIST DE VALIDATION

- [ ] MySQL installé et démarré
- [ ] Script SQL exécuté sans erreur
- [ ] Base de données `venus_db` créée
- [ ] 30+ tables créées
- [ ] Données de test insérées
- [ ] Connexion testée avec `SELECT`
- [ ] `application.properties` configuré
- [ ] Mot de passe MySQL correct dans la config

---

## 📞 PROCHAINES ÉTAPES

1. ✅ Base de données créée
2. ⏭️ Démarrer le backend Spring Boot
3. ⏭️ Tester les endpoints API avec Swagger
4. ⏭️ Développer le frontend Angular

---

**🎉 Félicitations ! Votre base de données VENUS est prête !**

**Développé pour VENUS Distribution Pharmaceutique - Yaoundé, Cameroun**

