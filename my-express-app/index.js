const express = require("express");
const multer = require("multer");
const mysql = require("mysql");
const path = require("path");

const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads/");
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + "-" + file.originalname);
  },
});
const upload = multer({ storage: storage });

const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "",
  database: "my_database",
});

db.connect((err) => {
  if (err) {
    console.error("Koneksi ke database gagal:", err);
    return;
  }
  console.log("Terhubung ke database MySQL.");
});

app.post("/upload", upload.single("image"), (req, res) => {
  const { title, description } = req.body;
  const imageUrl = `http://localhost:3000/uploads/${req.file.filename}`;

  const insertDataQuery = "INSERT INTO data (title, description) VALUES (?, ?)";
  db.query(insertDataQuery, [title, description], (err, dataResult) => {
    if (err) {
      console.error("Error menyimpan data:", err);
      return res.status(500).send("Error menyimpan data.");
    }

    const dataId = dataResult.insertId;

    const insertImageQuery =
      "INSERT INTO images (data_id, filename, url) VALUES (?, ?, ?)";
    db.query(
      insertImageQuery,
      [dataId, req.file.filename, imageUrl],
      (err, imageResult) => {
        if (err) {
          console.error("Error menyimpan gambar:", err);
          return res.status(500).send("Error menyimpan gambar.");
        }
        res.send({ message: "Gambar dan data berhasil diupload", imageUrl });
      }
    );
  });
});

app.get("/data", (req, res) => {
  const query = `
    SELECT data.id, data.title, data.description, images.url AS imageUrl
    FROM data
    LEFT JOIN images ON data.id = images.data_id
  `;

  db.query(query, (err, results) => {
    if (err) {
      console.error("Error mengambil data:", err);
      return res.status(500).send("Error mengambil data.");
    }
    res.json(results);
  });
});

app.listen(3000, () => {
  console.log("Server berjalan di http://localhost:3000");
});
