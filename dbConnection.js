const mysql = require('mysql')

const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'fabric_agency',
    timezone: "+07:00:000"
});

db.connect((err) => {
    if (err) {
        console.error('Error connecting to MySQL: ', err.message);
        return;
    }
    console.log('MySQL database connected !\n');
});

module.exports = db;