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


const get_supplier_code = async () => {
    return new Promise(async (resolve, reject) => {
      let found = true;
      let supplier_code;
  
      const query = 'SELECT * FROM supplier WHERE supplier_code = ?';
  
      while (found) {
        const randomFourDigitNumber = Math.floor(1000 + Math.random() * 9000);
        supplier_code = `SU${randomFourDigitNumber}`;
  
        await new Promise((resolveQuery) => {
          db.query(query, supplier_code, (err, result) => {
            if (err) throw err;
            if (result.length === 0) {
              found = false;
              resolveQuery();
            }
          });
        });
      }
  
      resolve(supplier_code);
    });
  };
  

  const operation = async (req, res) => {
    try {
      // Generate supplier_code
      const supplier_code = await get_supplier_code();
  
      // Other data from the request
      const supplier_name = req['name'];
      const address = req['address'];
      const bank_account = req['bankAccount'];
      const tax_code = req['taxCode'];
      const phone_numbers = req['phoneNumbers'];
  
      // Get a random partner_staff_code
      const partnerStaffQuery = 'SELECT * FROM employee WHERE employee_type = ?';
      db.query(partnerStaffQuery, 'partner_staff', async (err, result) => {
        if (err) throw err;
        if (result.length === 0) {
          res.status(402).send("No partner staff");
          return;
        }
        const len = result.length;
        const partner_staff_code = result[Math.floor(Math.random() * len)]['employee_code'];
  
        // Insert data into the supplier table
        const insertSupplierQuery = 'INSERT INTO supplier(supplier_code, partner_staff_code, name, address, bank_account, tax_code) VALUES (?,?,?,?,?,?)';
        db.query(insertSupplierQuery, [supplier_code, partner_staff_code, supplier_name, address, bank_account, tax_code], (err, result) => {
          if (err) throw err;
          console.log("Insert supplier successful");
  
          // Insert phone numbers into the supplier_phone_number table
          phone_numbers.forEach((phone_number) => {
            const insertPhoneNumberQuery = 'INSERT INTO supplier_phone_number(supplier_code, phone_num) VALUES (?,?)';
            db.query(insertPhoneNumberQuery, [supplier_code, phone_number], (error, results) => {
              if (error) throw error;
              console.log("Insert phone number successful");
            });
          });
  
          res.status(200).send("Operation successful");
        });
      });
    } catch (error) {
      console.error(error);
      res.status(500).send("Internal Server Error");
    }
  };  

module.exports = {
    operation,
    get_supplier_code
}