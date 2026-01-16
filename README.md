# Carnet de Contacts - Application Mobile Flutter + Backend

Application mobile complète de gestion de contacts avec authentification utilisateur, synchronisation backend, et stockage local. Projet full-stack avec frontend Flutter et backend Node.js.

---

## 🚀 Démarrage Rapide Complet

### Prérequis Globaux
- **Flutter SDK** ≥ 2.18.0 - [Installer Flutter](https://flutter.dev/docs/get-started/install)
- **Dart** 2.18+
- **Node.js** ≥ 14.0
- **npm** ou yarn
- Émulateur Android/iOS ou appareil physique
- SQLite3 (géré automatiquement)

### Installation Complète

```bash
# 1. Cloner et accéder au projet
cd flutter_app

# 2. Configurer et lancer le backend
cd backend
npm install

# Créer le fichier .env
echo PORT=3000 > .env
echo JWT_SECRET=your_very_secure_secret_key_change_in_production_123456 >> .env
echo DB_PATH=./database.sqlite >> .env
echo NODE_ENV=development >> .env

# Lancer le serveur (dans un terminal séparé)
npm run dev

# 3. Revenir à la racine et configurer l'application Flutter
cd ..
flutter pub get
flutter run
```

---

## 📱 Application Flutter

### ✨ Fonctionnalités Frontend

#### Authentification
- ✓ Inscription et connexion par email/mot de passe
- ✓ JWT pour la gestion de session
- ✓ Validation de formulaire
- ✓ Gestion des erreurs utilisateur

#### Gestion des Contacts
- ✓ Affichage liste complète des contacts
- ✓ Recherche en temps réel
- ✓ Filtrage par groupe
- ✓ Ajouter, modifier, supprimer contacts
- ✓ Marquer comme favoris
- ✓ Avatar/photo de contact
- ✓ Groupes de contacts

#### Interface Utilisateur
- ✓ Design Material moderne
- ✓ Mode sombre/clair (toggle)
- ✓ Interface responsive
- ✓ Navigation fluide
- ✓ Animations fluides

#### Données Locales
- ✓ Stockage local SQLite avec `sqflite`
- ✓ Persistence entre sessions
- ✓ Synchronisation bidirectionnelle avec backend

### 📁 Structure Flutter

```
flutter_app/
├── lib/
│   ├── main.dart                      # Point d'entrée, thème, routage
│   ├── db/
│   │   └── database_helper.dart       # Gestion base de données SQLite
│   ├── models/
│   │   └── contact.dart               # Modèle Contact
│   └── screens/
│       ├── login_screen.dart          # Écran de connexion
│       ├── register_screen.dart       # Écran d'inscription
│       ├── contact_list_screen.dart   # Écran liste de contacts
│       └── contact_form_screen.dart   # Écran ajouter/modifier contact
├── pubspec.yaml                       # Dépendances
└── README.md                          # Documentation
```

### 📦 Dépendances Flutter

| Package | Version | Usage |
|---------|---------|-------|
| `sqflite` | ^2.0.0 | Base de données SQLite locale |
| `path` | ^1.8.3 | Gestion chemins fichiers |
| `file_picker` | ^10.3.6 | Sélection fichiers/images |

### 📖 Guide d'Utilisation Flutter

1. **Démarrer l'application:** `flutter run`
2. **S'inscrire** avec email et mot de passe
3. **Se connecter** à votre compte
4. **Gérer les contacts:**
   - Ajouter: Bouton "+" en bas de l'écran
   - Modifier: Cliquer sur un contact
   - Supprimer: Swipe ou menu contextuel
   - Ajouter photo: Cliquer sur l'avatar
5. **Rechercher:** Utiliser la barre de recherche
6. **Filtrer:** Utiliser le filtre par groupe
7. **Favoris:** Cœur sur chaque contact pour marquer/demarquer
8. **Thème:** Toggle mode sombre depuis le menu

---

## 🔌 Backend API - Node.js/Express

### ✨ Fonctionnalités Backend

#### Authentification
- ✓ Inscription et connexion sécurisée
- ✓ Hachage bcryptjs des mots de passe
- ✓ JWT avec expiration
- ✓ Validation d'email

#### Gestion des Contacts
- ✓ CRUD complet pour les contacts
- ✓ Upload d'avatars
- ✓ Groupes de contacts
- ✓ Favoris
- ✓ Recherche et filtrage
- ✓ Isolation par utilisateur

#### Sécurité
- ✓ CORS configuré
- ✓ Validation d'entrée
- ✓ Authentification JWT
- ✓ Isolation utilisateur stricte

### 📁 Structure Backend

```
backend/
├── config/
│   └── database.js          # Configuration SQLite
├── middleware/
│   └── auth.js              # Middleware JWT
├── routes/
│   ├── auth.js              # Routes authentification
│   └── contacts.js          # Routes contacts
├── server.js                # Point d'entrée
├── package.json             # Dépendances
├── .env                     # Variables d'environnement (non versionné)
└── README.md                # Documentation
```

### 📦 Dépendances Backend

| Package | Version | Description |
|---------|---------|-------------|
| `express` | ^4.18.2 | Framework web |
| `sqlite3` | ^5.1.6 | Base de données SQLite |
| `bcryptjs` | ^2.4.3 | Hash de mots de passe |
| `jsonwebtoken` | ^9.0.2 | Authentification JWT |
| `cors` | ^2.8.5 | Gestion CORS |
| `dotenv` | ^16.3.1 | Variables d'environnement |
| `multer` | ^1.4.5 | Upload de fichiers |
| `nodemon` (dev) | ^3.0.1 | Rechargement en développement |

### 🔐 Endpoints API

**Base URL:** `http://localhost:3000/api`

#### Authentification (Public)

**Inscription:**
```http
POST /api/auth/register
Content-Type: application/json

{
  "username": "john_doe",
  "email": "john@example.com",
  "password": "secure_password_123"
}
```

**Connexion:**
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "secure_password_123"
}
```

**Réponse:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "userId": 1,
  "username": "john_doe"
}
```

#### Contacts (Routes Protégées)

**Header obligatoire:**
```
Authorization: Bearer <jwt_token>
```

**Lister tous les contacts:**
```http
GET /api/contacts?search=John&group=Amis&favorite=true
```

**Obtenir un contact:**
```http
GET /api/contacts/:id
```

**Créer un contact:**
```http
POST /api/contacts
Content-Type: multipart/form-data

name: John Doe
phone: 06 12 34 56 78
group_name: Amis
is_favorite: false
avatar: <fichier image>
```

**Modifier un contact:**
```http
PUT /api/contacts/:id
Content-Type: multipart/form-data
```

**Supprimer un contact:**
```http
DELETE /api/contacts/:id
```

**Lister les groupes:**
```http
GET /api/contacts/groups/list
```

### 🗄️ Schéma Base de Données

**Table: users**
```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Table: contacts**
```sql
CREATE TABLE contacts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  phone TEXT,
  group_name TEXT,
  is_favorite INTEGER DEFAULT 0,
  avatar_path TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

### 🧪 Test des Endpoints

**Avec cURL:**
```bash
# Inscription
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test","email":"test@example.com","password":"123456"}'

# Connexion
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"123456"}'

# Lister les contacts
curl -X GET http://localhost:3000/api/contacts \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## 📊 Configuration Environnement

### Fichier `.env` Backend (backend/.env)

```env
# Port du serveur (défaut: 3000)
PORT=3000

# Secret JWT (IMPORTANT: changer en production!)
JWT_SECRET=your_very_secure_secret_key_change_in_production_123456

# Chemin base de données
DB_PATH=./database.sqlite

# Environnement (development/production)
NODE_ENV=development
```

### Variables d'environnement Flutter

Si nécessaire, créer `.env` à la racine flutter_app:
```
BACKEND_URL=http://localhost:3000
API_ENDPOINT=/api
```

---

## 🛠️ Mode Développement

### Lancer en Parallèle

**Terminal 1 - Backend:**
```bash
cd backend
npm run dev
```

**Terminal 2 - Flutter:**
```bash
flutter run
```

### Déboguer

**Flutter Debug:**
```bash
flutter run -v
```

**Flutter Web (optionnel):**
```bash
flutter run -d chrome
```

---

## ⚠️ Dépannage

### Problèmes Courants

| Problème | Solution |
|----------|----------|
| `Port 3000 déjà utilisé` | Changer PORT dans .env ou `lsof -i :3000` puis tuer le processus |
| `flutter run` échoue | Exécuter `flutter pub get` et vérifier installation Flutter |
| Connexion au backend impossible | Vérifier que le serveur backend est démarré (`npm run dev`) |
| `CORS error` | Vérifier configuration CORS dans backend/server.js |
| `Token invalide` | Générer nouveau token via `/api/auth/login` |
| Erreur SQLite | Supprimer `database.sqlite` et redémarrer |
| Erreur de permission stockage | Activer permissions d'accès au stockage dans paramètres |
| Avatar ne s'affiche pas | Vérifier accès aux fichiers de l'appareil |

---

## 🚀 Build & Déploiement

### Flutter

**APK Android (Release):**
```bash
flutter build apk --release
```

**IPA iOS (Release):**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```

### Backend - Déploiement Heroku

```bash
heroku login
heroku create nom-app
git push heroku main

# Variables d'environnement
heroku config:set JWT_SECRET=production_secret_key
heroku config:set NODE_ENV=production
```

---

## 🧪 Tests

### Flutter
```bash
flutter test
```

### Backend (optionnel)
```bash
cd backend
npm test
```

---

## 📝 Notes Importantes

### Architecture
- Frontend Flutter communique avec backend via HTTP/REST
- Authentification par JWT pour chaque requête
- Données locales synchronisées avec backend
- Base de données SQLite côté mobile et serveur

### Flux d'Authentification
1. Utilisateur s'inscrit/se connecte via Flutter
2. Backend retourne JWT token
3. Flutter stocke le token localement
4. Chaque requête API inclut le token dans le header
5. Backend valide le token avant de répondre

### Considérations Sécurité
- Mots de passe hachés avec bcryptjs
- Tokens JWT avec expiration
- Isolation utilisateur stricte
- Validation d'entrée côté serveur
- CORS configuré pour les origines autorisées

### Points Clés
- Les contacts sont d'abord stockés localement via SQLite
- La synchronisation avec le backend se fait via HTTP
- Les tokens JWT expirés requirent une reconnexion
- Les avatars sont stockés comme chemins de fichiers locaux
- Supprimer l'app supprimera toutes les données locales
- Les migrations SQL s'exécutent automatiquement au démarrage

---

## 📞 Support & Contribution

- Rapporter les bugs via les issues GitHub
- Les pull requests sont bienvenues
- Pour des questions, consulter la documentation du projet
- Consulter les fichiers README spécifiques pour plus de détails:
  - Documentation détaillée du backend: [backend/README.md](backend/README.md)

---

## 📄 Licence

[MIT License](LICENSE)

---

## 📌 Checklist Démarrage

- [ ] Cloner le repository
- [ ] Installer Flutter et Node.js
- [ ] Exécuter `npm install` dans le dossier backend
- [ ] Créer le fichier `.env` dans backend
- [ ] Démarrer le serveur backend (`npm run dev`)
- [ ] Exécuter `flutter pub get`
- [ ] Lancer l'application (`flutter run`)
- [ ] S'inscrire et créer un compte
- [ ] Ajouter des contacts pour tester
- [ ] Vérifier la synchronisation avec le backend
