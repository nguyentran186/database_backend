const mysql = require('mysql')
const bcrypt = require('bcrypt');

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

const get_username_and_hashed_password = (username) => {
    return new Promise((resolve, reject) => {
        const query = 'SELECT * FROM admin_account_hash WHERE username = ?';
        db.query(query, [username], (err, result) => {
            if (err) {
                reject(err);
            } else {
                resolve(result);
            }
        })
  })}

const safeLogin = async (req) => {
  try {
    const username = req["username"];
    const enteredPassword = req["password"];

    const result = await get_username_and_hashed_password(username);

    if (result.length === 0) {
      return [];
    }

    const storedHashedPassword = result[0]['password_hash'];

    const passwordMatch = await bcrypt.compare(enteredPassword, storedHashedPassword);

    if (passwordMatch) {
      return result;
    } else {
      return [];
    }
  } catch (error) {
    console.log(error);
    throw error;
  }
};

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