const db = require('./dbConnection');

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
      const bank_account = req['bank'];
      const tax_code = req['tax'];
      const phone_numbers = req['phoneNumbers'];
  
      var operationSuccess = true;
      // Check for duplicate phone numbers
      const phoneDuplicatePromises = phone_numbers.map(async (phone_number) => {
        const query = 'SELECT * FROM supplier_phone_number WHERE phone_num = ?';
        const result = await queryAsync(query, phone_number);
  
        if (result.length > 0) {
          throw new Error('phone duplicated');
        }
      });
  
      await Promise.all(phoneDuplicatePromises).catch((err) => {
        if (err.message === 'phone duplicated') {
          res.status(400).send('Phone number duplicated');
          operationSuccess = false;
        }
      });

      if (!operationSuccess) {
        return;
      } else {
        operationSuccess = true;
      }
  
      // Check for duplicate tax code
      const taxCodeQuery = 'SELECT * FROM supplier WHERE tax_code = ?';
      const taxCodeResult = await queryAsync(taxCodeQuery, tax_code);
  
      if (taxCodeResult.length > 0) {
        throw new Error('tax code duplicated');
      }
  
      // Get a random partner_staff_code
      const partnerStaffQuery = 'SELECT * FROM employee WHERE employee_type = ?';
      const partnerStaffResult = await queryAsync(partnerStaffQuery, 'partner_staff');
  
      if (partnerStaffResult.length === 0) {
        res.status(402).send("No partner staff");
        return;
      }
  
      const len = partnerStaffResult.length;
      const partner_staff_code = partnerStaffResult[Math.floor(Math.random() * len)]['employee_code'];
  
      // Insert data into the supplier table
      const insertSupplierQuery = 'INSERT INTO supplier(supplier_code, partner_staff_code, name, address, bank_account, tax_code) VALUES (?,?,?,?,?,?)';
      await queryAsync(insertSupplierQuery, [supplier_code, partner_staff_code, supplier_name, address, bank_account, tax_code]);
      console.log("Insert supplier successful");
  
      // Insert phone numbers into the supplier_phone_number table
      const insertPhoneNumberPromises = phone_numbers.map((phone_number) => {
        const insertPhoneNumberQuery = 'INSERT INTO supplier_phone_number(supplier_code, phone_num) VALUES (?,?)';
        return queryAsync(insertPhoneNumberQuery, [supplier_code, phone_number]);
      });
  
      await Promise.all(insertPhoneNumberPromises);
  
      // Get staff details
      let staff = await get_staff(partner_staff_code);

      // Send success response
      const _res = {
        'success': 'Successful',
        'statusMessage': 'OK',
        'supplierCode': supplier_code,
        'staffID': staff['employee_code'],
        'staffFName': staff['first_name'],
        'staffLName': staff['last_name']
      };
      res.status(200).send(_res);
  
    } catch (error) {
      console.error(error);
  
      // Handle the error appropriately
      if (error.message === 'phone duplicated') {
        res.status(400).send('Phone number duplicated');
      } else if (error.message === 'tax code duplicated') {
        res.status(400).send('Tax code duplicated');
      } else {
        res.status(500).send(error);
      }
    }
  };

  const get_staff = (partner_staff_code) => {
    return new Promise((resolve, reject) => {
      const new_query = 'SELECT * FROM employee WHERE employee_code = ?';
      db.query(new_query, partner_staff_code, (err, result) => {
        if (err) {
          reject(err);
        } else {
          resolve(result[0]);
        }
      });
    });
  };
  
  const queryAsync = (sql, values) => {
    return new Promise((resolve, reject) => {
      db.query(sql, values, (err, result) => {
        if (err) {
          reject(err);
        } else {
          resolve(result);
        }
      });
    });
  };
  


module.exports = {
    operation,
    get_supplier_code
}