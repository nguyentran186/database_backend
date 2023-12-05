const mysql = require('mysql')

const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'login',
    timezone: "+07:00:000"
});

// ##############################################
// ##############################################
// ##############################################

const safeLogin = (req) => {
  return new Promise((resolve, reject) => {
    const query = 'SELECT * FROM admin_account WHERE username = ? AND password = ?';
    db.query(query, [req["username"], req["password"]], (err, result) => {
      if (err) {
        reject(err);
      } else {
        resolve(result);
      }
    });
  });
}

const unsafeLogin = (req) => {
  return new Promise((resolve, reject) => {
    const query = `SELECT * FROM admin_account WHERE username = '${req["username"]}' AND password = '${req["password"]}'`;
    db.query(query, (err, result) => {
      if (err) {
        reject(err);
      } else {
        resolve(result);
      }
    });
  });
}

module.exports = { safeLogin, unsafeLogin }