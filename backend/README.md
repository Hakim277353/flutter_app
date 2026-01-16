# Contact App Backend

Backend API for the Contact Management Flutter application.

## Features

- User authentication (register/login) with JWT
- CRUD operations for contacts
- Image upload for contact avatars
- Contact grouping and filtering
- Favorite contacts management
- SQLite database

## Installation

```bash
cd backend
npm install
```

## Configuration

Create a `.env` file in the backend directory:

```
PORT=3000
JWT_SECRET=your_jwt_secret_key_change_this_in_production
DB_PATH=./database.sqlite
```

## Running the Server

Development mode:
```bash
npm run dev
```

Production mode:
```bash
npm start
```

## API Endpoints

### Authentication

- `POST /api/auth/register` - Register a new user
  - Body: `{ username, email, password }`
  - Returns: `{ token, userId, username }`

- `POST /api/auth/login` - Login user
  - Body: `{ email, password }`
  - Returns: `{ token, userId, username }`

### Contacts (Protected Routes - Require Authorization Header)

- `GET /api/contacts` - Get all contacts for authenticated user
  - Query params: `?search=...&group=...&favorite=true`
  
- `GET /api/contacts/:id` - Get single contact

- `POST /api/contacts` - Create new contact
  - Body: `{ name, phone, group_name, is_favorite }`
  - Optional: avatar file (multipart/form-data)
  
- `PUT /api/contacts/:id` - Update contact
  - Body: `{ name, phone, group_name, is_favorite }`
  - Optional: avatar file (multipart/form-data)
  
- `DELETE /api/contacts/:id` - Delete contact

- `GET /api/contacts/groups/list` - Get list of contact groups

### Authorization Header Format
```
Authorization: Bearer <jwt_token>
```

## Technologies Used

- Express.js - Web framework
- SQLite3 - Database
- bcryptjs - Password hashing
- jsonwebtoken - JWT authentication
- multer - File upload handling
- cors - Cross-origin resource sharing
