const express = require('express');
const router = express.Router();
const pool = require('../db');

// Get all notes
router.get('/', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM notes ORDER BY id DESC');
    res.json(rows);
  } catch (err) {
    console.error("❌ Error in GET /notes:", err.message);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Add a new note
router.post('/', async (req, res) => {
  try {
    const { title, description } = req.body;

    if (!title || !description) {
      return res.status(400).json({ error: 'Title and description are required' });
    }

    const [result] = await pool.query(
      'INSERT INTO notes (title, description) VALUES (?, ?)',
      [title, description]
    );

    const [newNote] = await pool.query('SELECT * FROM notes WHERE id = ?', [result.insertId]);
    res.status(201).json(newNote[0]);
  } catch (err) {
    console.error("❌ Error in POST /notes:", err.message);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update a note
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { title, description, completed } = req.body;

    const [result] = await pool.query(
      'UPDATE notes SET title = ?, description = ?, completed = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [title, description, completed, id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Note not found' });
    }

    const [updatedNote] = await pool.query('SELECT * FROM notes WHERE id = ?', [id]);
    res.json(updatedNote[0]);
  } catch (err) {
    console.error("❌ Error in PUT /notes/:id:", err.message);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Delete a note
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const [result] = await pool.query('DELETE FROM notes WHERE id = ?', [id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Note not found' });
    }

    res.json({ message: 'Note deleted successfully' });
  } catch (err) {
    console.error("❌ Error in DELETE /notes/:id:", err.message);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
