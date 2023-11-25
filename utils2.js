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
        throw err;
    }
});

// ##############################################
// ##############################################
// ##############################################

const add_supplier = async (req) => {
    return new Promise((resovled, reject) => {
        let phone_query = "INSERT INTO fabric_agency.supplier (supplier_code, partner_staff_code, name, address, bank_account, tax_code)\
        VALUES (?, ?, ?, ?, ?, ?)"
        db.query(phone_query, customer_code, async (err, result) => {
            if (err) {
                reject(err);
            } else {
                let phones = []
                for (const phone in result){
                    phones.push(result[phone]['phone_num'])
                }
                resovled(phones);
            };
        });
    })
}