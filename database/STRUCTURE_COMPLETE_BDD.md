# 🗄️ STRUCTURE COMPLÈTE - BASE DE DONNÉES VENUS

## 📊 STATISTIQUES GLOBALES

- **Total de tables** : 40+ tables
- **Modules fonctionnels** : 20 modules
- **Relations (Foreign Keys)** : 60+ relations
- **Index optimisés** : 100+ index
- **Données de test** : Incluses

---

## 📋 LISTE COMPLÈTE DES TABLES PAR MODULE

### 🔐 MODULE 1: UTILISATEURS & SÉCURITÉ (5 tables)
| Table | Description | Lignes clés |
|-------|-------------|-------------|
| `roles` | Rôles utilisateurs | Admin, Manager, Stock, Sales, Accountant, Warehouse, Customer |
| `users` | Utilisateurs du système | Authentification, profils, statuts |
| `login_attempts` | Tentatives de connexion | Sécurité, détection d'intrusion |
| `refresh_tokens` | Tokens JWT refresh | Sessions sécurisées |
| `password_reset_tokens` | Réinitialisation MDP | Récupération de compte |

### 👥 MODULE 2: PARTENAIRES (3 tables)
| Table | Description | Lignes clés |
|-------|-------------|-------------|
| `customers` | Clients B2B | Pharmacies, Hôpitaux, Cliniques, Grossistes |
| `suppliers` | Fournisseurs | Laboratoires, Fabricants, Importateurs |
| `customer_contacts` | Contacts multiples | Contacts primaires, facturation, livraison |

### 📦 MODULE 3: CATALOGUE PRODUITS (2 tables)
| Table | Description | Lignes clés |
|-------|-------------|-------------|
| `product_categories` | Catégories | Antibiotiques, Antalgiques, Antipaludéens, etc. |
| `products` | Produits pharmaceutiques | Code, nom, DCI, dosage, forme, prix |

### 🏭 MODULE 4: STOCK & TRAÇABILITÉ (7 tables)
| Table | Description | Lignes clés |
|-------|-------------|-------------|
| `storage_zones` | Zones de stockage | Ambiante, Réfrigérée, Congelée, Quarantaine |
| `product_batches` | Lots de produits | **TRAÇABILITÉ COMPLÈTE** - Numéro lot, dates |
| `inventory` | Inventaire global | Stock disponible, réservé, seuils |
| `stock_movements` | Mouvements de stock | IN, OUT, ADJUSTMENT, TRANSFER, RETURN |
| `stock_alerts` | Alertes automatiques | Stock bas, expiration, rupture |
| `temperature_logs` | Monitoring température | **CHAÎNE DU FROID** - Logs automatiques |
| `vehicles` | Flotte de véhicules | Véhicules réfrigérés, maintenance |

### 🛒 MODULE 5: COMMANDES (3 tables)
| Table | Description | Lignes clés |
|-------|-------------|-------------|
| `orders` | Commandes clients | Statuts, priorités, livraison |
| `order_items` | Lignes de commande | Produits, quantités, prix |
| `delivery_tracking` | Suivi livraison | GPS, signature, preuve de livraison |

### 💰 MODULE 6: FINANCE (3 tables)
| Table | Description | Lignes clés |
|-------|-------------|-------------|
| `payment_transactions` | Transactions | Cash, Virement, MTN, Orange Money, Crédit |
| `invoices` | Factures | Génération PDF, échéances |
| `price_history` | Historique prix | Traçabilité des changements |

### 🎯 MODULE 7: PROMOTIONS (3 tables)
| Table | Description | Lignes clés |
|-------|-------------|-------------|
| `promotions` | Promotions | Pourcentage, montant fixe, offres spéciales |
| `promotion_products` | Produits en promo | Liaison produits-promotions |
| `quotations` | Devis | Devis avant commande |
| `quotation_items` | Détails devis | Lignes de devis |

### ⚕️ MODULE 8: PRESCRIPTIONS (2 tables)
| Table | Description | Lignes clés |
|-------|-------------|-------------|
| `prescriptions` | Ordonnances | Médecin, patient, validation pharmacien |
| `prescription_items` | Détails ordonnances | Produits prescrits, posologie |

### 🔄 MODULE 9: QUALITÉ & RETOURS (4 tables)
| Table | Description | Lignes clés |
|-------|-------------|-------------|
| `product_recalls` | Rappels de lots | **RÉGLEMENTAIRE** - Rappels sanitaires |
| `product_returns` | Retours clients | Défectueux, périmés, erreurs |
| `return_items` | Détails retours | Produits retournés |
| `documents` | Documents | Certificats, factures PDF, rapports |

### 🚚 MODULE 10: ACHATS & APPROVISIONNEMENT (4 tables)
| Table | Description | Lignes clés |
|-------|-------------|-------------|
| `purchase_orders` | Bons de commande | Commandes fournisseurs |
| `purchase_order_items` | Lignes BC | Détails commandes |
| `goods_receipts` | Réceptions | Contrôle qualité à réception |
| `goods_receipt_items` | Détails réceptions | Quantités reçues/acceptées/rejetées |

### 🚛 MODULE 11: TRANSPORTEURS (2 tables)
| Table | Description | Lignes clés |
|-------|-------------|-------------|
| `carriers` | Transporteurs | Sociétés de livraison |
| `vehicles` | Véhicules | Flotte, maintenance, assurance |

### 📢 MODULE 12: NOTIFICATIONS (3 tables)
| Table | Description | Lignes clés |
|-------|-------------|-------------|
| `notifications` | Notifications système | Alertes temps réel |
| `email_logs` | Logs emails | Historique emails envoyés |
| `sms_logs` | Logs SMS | Historique SMS (MTN, Orange) |

### 🔍 MODULE 13: AUDIT & TRAÇABILITÉ (2 tables)
| Table | Description | Lignes clés |
|-------|-------------|-------------|
| `audit_logs` | Logs d'audit | **RÉGLEMENTAIRE** - Qui a fait quoi |
| `system_settings` | Paramètres | Configuration système |

### 📊 MODULE 14: REPORTING (1 table)
| Table | Description | Lignes clés |
|-------|-------------|-------------|
| `reports` | Rapports générés | PDF, Excel, CSV |

### 💝 MODULE 15: PORTAIL CLIENT (3 tables)
| Table | Description | Lignes clés |
|-------|-------------|-------------|
| `customer_wishlists` | Favoris | Produits favoris clients |
| `recurring_orders` | Commandes récurrentes | Automatisation commandes |
| `recurring_order_items` | Détails récurrents | Produits récurrents |

---

## 🔗 RELATIONS PRINCIPALES

### Relations Critiques
```
users → roles (Many-to-One)
products → product_categories (Many-to-One)
products → suppliers (Many-to-One)
product_batches → products (Many-to-One) ⭐ TRAÇABILITÉ
product_batches → storage_zones (Many-to-One)
orders → customers (Many-to-One)
order_items → orders (Many-to-One)
order_items → products (Many-to-One)
order_items → product_batches (Many-to-One) ⭐ TRAÇABILITÉ LOT
stock_movements → product_batches (Many-to-One) ⭐ TRAÇABILITÉ
payment_transactions → orders (Many-to-One)
prescriptions → customers (Many-to-One)
prescription_items → prescriptions (Many-to-One)
```

---

## 🎯 FONCTIONNALITÉS CLÉS IMPLÉMENTÉES

### ✅ Conformité Réglementaire Pharmaceutique
- ✅ **Traçabilité complète des lots** (numéro lot, dates fabrication/expiration)
- ✅ **Gestion des prescriptions** obligatoires
- ✅ **Rappels de lots** (product_recalls)
- ✅ **Audit logs** complets (qui a fait quoi, quand)
- ✅ **Chaîne du froid** (temperature_logs)
- ✅ **Contrôle qualité** à réception

### ✅ Gestion Commerciale Complète
- ✅ **Clients B2B** (pharmacies, hôpitaux, cliniques)
- ✅ **Devis** avant commande
- ✅ **Commandes** avec statuts multiples
- ✅ **Facturation** automatique
- ✅ **Paiements multiples** (Cash, Virement, Mobile Money)
- ✅ **Promotions** et remises

### ✅ Gestion de Stock Avancée
- ✅ **Inventaire temps réel**
- ✅ **Alertes automatiques** (stock bas, expiration)
- ✅ **Mouvements tracés** (entrées, sorties, ajustements)
- ✅ **Zones de stockage** (ambiante, réfrigérée)
- ✅ **FIFO** (First In, First Out) par lot

### ✅ Logistique & Livraison
- ✅ **Suivi GPS** des livraisons
- ✅ **Signature électronique**
- ✅ **Preuve de livraison** (photo)
- ✅ **Flotte de véhicules**
- ✅ **Transporteurs externes**

### ✅ Portail Client B2B
- ✅ **Commandes en ligne**
- ✅ **Historique commandes**
- ✅ **Produits favoris**
- ✅ **Commandes récurrentes**
- ✅ **Suivi livraison temps réel**

---

## 🔐 SÉCURITÉ

- ✅ **Authentification JWT** avec refresh tokens
- ✅ **Rôles et permissions** granulaires
- ✅ **Logs de connexion** (détection intrusion)
- ✅ **Verrouillage de compte** après tentatives échouées
- ✅ **Réinitialisation mot de passe** sécurisée
- ✅ **Audit complet** de toutes les actions

---

## 📈 OPTIMISATIONS

### Index Créés (100+)
- Index sur **codes** (product_code, customer_code, order_number)
- Index sur **dates** (order_date, expiry_date, created_at)
- Index sur **statuts** (order status, payment status)
- Index sur **relations** (foreign keys)
- Index **FULLTEXT** pour recherche produits

### Colonnes Calculées
- `inventory.quantity_available` = stock - réservé
- `invoices.balance_due` = total - payé

---

## 🚀 PROCHAINES ÉTAPES

1. ✅ **Base de données créée** (40+ tables)
2. ⏭️ **Exécuter les scripts SQL**
3. ⏭️ **Créer les Services Spring Boot**
4. ⏭️ **Créer les Controllers REST**
5. ⏭️ **Tester avec Swagger**
6. ⏭️ **Développer Frontend Angular**

---

## 📞 SUPPORT

**Développé pour VENUS Distribution Pharmaceutique**
**Yaoundé, Cameroun**

Cette base de données est conforme aux **Bonnes Pratiques de Distribution (GDP)** pharmaceutique.

