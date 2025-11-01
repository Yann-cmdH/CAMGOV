# 🐘 Installation PostgreSQL pour Venus Pharma ERP

## 📥 Téléchargement PostgreSQL

### Option 1: Site officiel (Recommandé)
1. Aller sur : https://www.postgresql.org/download/windows/
2. Cliquer sur "Download the installer"
3. Télécharger PostgreSQL 15.x pour Windows x86-64

### Option 2: Lien direct
https://get.enterprisedb.com/postgresql/postgresql-15.4-1-windows-x64.exe

## 🛠️ Installation

### 1. Lancer l'installateur
- Double-cliquer sur `postgresql-15.4-1-windows-x64.exe`
- Suivre l'assistant d'installation

### 2. Configuration pendant l'installation
- **Répertoire d'installation** : `C:\Program Files\PostgreSQL\15`
- **Composants** : Cocher tous (PostgreSQL Server, pgAdmin 4, Stack Builder, Command Line Tools)
- **Répertoire des données** : `C:\Program Files\PostgreSQL\15\data`
- **Mot de passe superuser (postgres)** : `postgres123` ⚠️ **IMPORTANT : Retenir ce mot de passe !**
- **Port** : `5432` (par défaut)
- **Locale** : `French, France`

### 3. Finaliser l'installation
- Laisser Stack Builder se lancer (optionnel)
- PostgreSQL est maintenant installé !

## ⚙️ Configuration pour Venus Pharma

### 1. Ouvrir pgAdmin 4
- Chercher "pgAdmin 4" dans le menu Démarrer
- Se connecter avec le mot de passe `postgres123`

### 2. Créer l'utilisateur Venus
```sql
CREATE USER venus_user WITH PASSWORD 'venus123';
ALTER USER venus_user CREATEDB;
```

### 3. Créer la base de données
```sql
CREATE DATABASE venus_pharma 
OWNER venus_user 
ENCODING 'UTF8';
```

### 4. Exécuter le script Venus Pharma
1. Clic droit sur la base `venus_pharma`
2. Query Tool
3. Ouvrir le fichier `create_venus_database_postgresql.sql`
4. Exécuter (F5)

## 🔧 Configuration Spring Boot

Mettre à jour `application.properties` :
```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/venus_pharma
spring.datasource.username=venus_user
spring.datasource.password=venus123
spring.datasource.driver-class-name=org.postgresql.Driver
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect
```

## ✅ Test de connexion

### Via pgAdmin
1. Se connecter à la base `venus_pharma`
2. Vérifier les tables créées
3. Vérifier les données de base

### Via application Spring Boot
```bash
cd backend
mvn spring-boot:run
```

## 🎯 Résultat attendu

✅ PostgreSQL installé et configuré  
✅ Base `venus_pharma` créée  
✅ Utilisateur `venus_user` configuré  
✅ Tables et données de base insérées  
✅ Application Spring Boot connectée  

## 🔐 Informations de connexion

- **Serveur** : localhost:5432
- **Base de données** : venus_pharma
- **Utilisateur** : venus_user
- **Mot de passe** : venus123
- **Super utilisateur** : postgres / postgres123

## 🚨 En cas de problème

### Service PostgreSQL ne démarre pas
```cmd
net start postgresql-x64-15
```

### Erreur de connexion
- Vérifier que le service PostgreSQL est démarré
- Vérifier les paramètres de connexion
- Vérifier le pare-feu Windows

### Port 5432 occupé
- Changer le port dans postgresql.conf
- Redémarrer le service PostgreSQL

---
**Venus Pharma SARL** - Configuration PostgreSQL 🏥💊
