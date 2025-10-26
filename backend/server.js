const express = require('express');
const cors = require('cors'); // 👈 add this
const app = express();
const notesRouter = require('./routes/notes');

app.use(cors()); // 👈 add this
app.use(express.json());
app.use('/notes', notesRouter);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
