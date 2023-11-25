const { query } = require('express');
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

const operation = (req, res) => {
    results = [];
    
    let query;
    let supplier_code;
    let found = true;
    do {
        console.log('in')
        supplier_code = 'SU' +
        Math.floor(Math.random() * 9).toString() +
        Math.floor(Math.random() * 9).toString() +
        Math.floor(Math.random() * 9).toString() +
            Math.floor(Math.random() * 9).toString();

        query = 'SELECT * FROM supplier WHERE supplier_code = ?';
        db.query(query, supplier_code, async (err, result) => {
            if (result.length == 0) {
                break
            }
        })
    } while (found == true)



    supplier_name = req['name'];
    address = req['address'];
    bank_account = req['bankAccount'];
    tax_code = req['taxCode'];
    phone_numbers = req['phoneNumbers'];


    query = 'SELECT * FROM employee WHERE employee_type = ?';
    db.query(query, 'partner_staff', async (err, result) => {
        if (err) throw err;
        if (result.length == 0) {
            res.status(402).send("No partner staff")
            return
        }
        let len = result.length;
        partner_staff_code = result[Math.floor(Math.random() * len)]['employee_code'];
        
        query = 'INSERT INTO supplier(supplier_code, partner_staff_code, name, address, bank_account, tax_code) \
        VALUES (?,?,?,?,?,?)';
        db.query(query, [supplier_name, partner_staff_code, nam, address, bank_account, tax_code], (err, result) =>{
            if (err) throw err
            console.log("Insert supplier sucessful")
        })
    })


    phone_numbers.map((phone_number) => {
        query = 'INSERT INTO supplier_phone_number(supplier_code, phone_num) VALUES (\
            ?,?)';

        db.query(query,[supplier_code, phone_number], (error, results) => {
            if (error) throw error;
            console.log("Insert phone number sucessful")
        });
    });
}

module.exports = {
    operation
}