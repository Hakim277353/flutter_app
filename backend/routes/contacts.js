const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { db } = require('../config/database');
const authMiddleware = require('../middleware/auth');
const router = express.Router();

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDir = path.join(__dirname, '..', 'uploads');
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({ 
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
  fileFilter: (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|gif/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);
    
    if (mimetype && extname) {
      return cb(null, true);
    } else {
      cb(new Error('Only image files are allowed'));
    }
  }
});

// Get all contacts for authenticated user
router.get('/', authMiddleware, (req, res) => {
  const { search, group, favorite } = req.query;
  let query = 'SELECT * FROM contacts WHERE user_id = ?';
  const params = [req.userId];

  if (search) {
    query += ' AND (name LIKE ? OR phone LIKE ?)';
    params.push(`%${search}%`, `%${search}%`);
  }

  if (group && group !== 'Tous') {
    query += ' AND group_name = ?';
    params.push(group);
  }

  if (favorite === 'true') {
    query += ' AND is_favorite = 1';
  }

  query += ' ORDER BY name ASC';

  db.all(query, params, (err, contacts) => {
    if (err) {
      return res.status(500).json({ error: 'Error fetching contacts' });
    }
    res.json(contacts);
  });
});

// Get single contact
router.get('/:id', authMiddleware, (req, res) => {
  db.get(
    'SELECT * FROM contacts WHERE id = ? AND user_id = ?',
    [req.params.id, req.userId],
    (err, contact) => {
      if (err) {
        return res.status(500).json({ error: 'Error fetching contact' });
      }
      if (!contact) {
        return res.status(404).json({ error: 'Contact not found' });
      }
      res.json(contact);
    }
  );
});

// Create new contact
router.post('/', authMiddleware, upload.single('avatar'), (req, res) => {
  const { name, phone, group_name, is_favorite } = req.body;

  if (!name || !phone) {
    return res.status(400).json({ error: 'Name and phone are required' });
  }

  const avatarPath = req.file ? `/uploads/${req.file.filename}` : null;

  db.run(
    'INSERT INTO contacts (user_id, name, phone, group_name, is_favorite, avatar_path) VALUES (?, ?, ?, ?, ?, ?)',
    [req.userId, name, phone, group_name || 'Général', is_favorite ? 1 : 0, avatarPath],
    function(err) {
      if (err) {
        return res.status(500).json({ error: 'Error creating contact' });
      }

      db.get('SELECT * FROM contacts WHERE id = ?', [this.lastID], (err, contact) => {
        if (err) {
          return res.status(500).json({ error: 'Error fetching created contact' });
        }
        res.status(201).json(contact);
      });
    }
  );
});

// Update contact
router.put('/:id', authMiddleware, upload.single('avatar'), (req, res) => {
  const { name, phone, group_name, is_favorite } = req.body;

  // First check if contact exists and belongs to user
  db.get(
    'SELECT * FROM contacts WHERE id = ? AND user_id = ?',
    [req.params.id, req.userId],
    (err, contact) => {
      if (err) {
        return res.status(500).json({ error: 'Error fetching contact' });
      }
      if (!contact) {
        return res.status(404).json({ error: 'Contact not found' });
      }

      const avatarPath = req.file ? `/uploads/${req.file.filename}` : contact.avatar_path;

      // Delete old avatar if new one is uploaded
      if (req.file && contact.avatar_path) {
        const oldPath = path.join(__dirname, '..', contact.avatar_path);
        if (fs.existsSync(oldPath)) {
          fs.unlinkSync(oldPath);
        }
      }

      db.run(
        'UPDATE contacts SET name = ?, phone = ?, group_name = ?, is_favorite = ?, avatar_path = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
        [name, phone, group_name, is_favorite ? 1 : 0, avatarPath, req.params.id],
        (err) => {
          if (err) {
            return res.status(500).json({ error: 'Error updating contact' });
          }

          db.get('SELECT * FROM contacts WHERE id = ?', [req.params.id], (err, updatedContact) => {
            if (err) {
              return res.status(500).json({ error: 'Error fetching updated contact' });
            }
            res.json(updatedContact);
          });
        }
      );
    }
  );
});

// Delete contact
router.delete('/:id', authMiddleware, (req, res) => {
  // First get contact to delete avatar file
  db.get(
    'SELECT * FROM contacts WHERE id = ? AND user_id = ?',
    [req.params.id, req.userId],
    (err, contact) => {
      if (err) {
        return res.status(500).json({ error: 'Error fetching contact' });
      }
      if (!contact) {
        return res.status(404).json({ error: 'Contact not found' });
      }

      // Delete avatar file if exists
      if (contact.avatar_path) {
        const avatarPath = path.join(__dirname, '..', contact.avatar_path);
        if (fs.existsSync(avatarPath)) {
          fs.unlinkSync(avatarPath);
        }
      }

      db.run(
        'DELETE FROM contacts WHERE id = ? AND user_id = ?',
        [req.params.id, req.userId],
        (err) => {
          if (err) {
            return res.status(500).json({ error: 'Error deleting contact' });
          }
          res.json({ message: 'Contact deleted successfully' });
        }
      );
    }
  );
});

// Get contact groups
router.get('/groups/list', authMiddleware, (req, res) => {
  db.all(
    'SELECT DISTINCT group_name FROM contacts WHERE user_id = ? ORDER BY group_name',
    [req.userId],
    (err, groups) => {
      if (err) {
        return res.status(500).json({ error: 'Error fetching groups' });
      }
      const groupList = groups.map(g => g.group_name);
      res.json(groupList);
    }
  );
});

module.exports = router;
