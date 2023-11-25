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
const get_all_category = async (supplier_code) => {
    return new Promise((resovled, reject) => {
        let categories_queries = "SELECT * FROM fabric_agency.fabric_cat WHERE supplier_code = ?"
        db.query(categories_queries, supplier_code, async (err, result) => {
            if (err) {
                reject(err);
            } else {
                let categories = []
                for (const cate in result){
                    temp = {
                        'ID': result[cate]['fabcat_code'],
                        'name': result[cate]['name'],
                        'color': result[cate]['color'],
                        'quantity': result[cate]['quantity'],
                        'priceHistory': await get_current_price(result[cate]['fabcat_code'])
                    }
                    categories.push(temp)
                }
                resovled(categories);
            };
        });
    })
}

const get_emp = async (employee_code) => {
    return new Promise((resovled, reject) => {
        let categories_queries = "SELECT * FROM fabric_agency.employee WHERE employee_code = ?"
        db.query(categories_queries, employee_code, async (err, result) => {
            if (err) {
                reject(err);
            } else {
                resovled(result[0]);
            };
        });
    })
}

const get_all_supplier = async (name) => {
    return new Promise((resovled, reject) => {
        let supplier_query = "SELECT * FROM fabric_agency.supplier WHERE name like ?"
        db.query(supplier_query, name, async (err, result) => {
            if (err) {
                reject(err);
            } else {
                let suppliers = []
                for (const supplier in result){
                    let emp = await get_emp(result[supplier]['partner_staff_code'])
                    let temp = {
                        'supplierID': result[supplier]['supplier_code'],
                        'supplierName': result[supplier]['name'],
                        'partnerInfo': result[supplier]['partner_staff_code'],
                        'partnerFName': emp['first_name'],
                        'partnerLName': emp['last_name'],
                        'partnerGender': emp['gender'],
                        'partnerAddress': emp['address'],
                        'categories': await get_all_category(result[supplier]['supplier_code'])
                    }
                    suppliers.push(temp)
                }
                resovled(suppliers);
            };
        });
    })
}

const get_all_supplier_by_id = async (id) => {
    return new Promise((resovled, reject) => {
        let supplier_query = "SELECT * FROM fabric_agency.supplier WHERE supplier_code = ?"
        db.query(supplier_query, id, async (err, result) => {
            if (err) {
                reject(err);
            } else {
                let suppliers = []
                for (const supplier in result){
                    let emp = await get_emp(result[supplier]['partner_staff_code'])
                    let temp = {
                        'supplierID': result[supplier]['supplier_code'],
                        'supplierName': result[supplier]['name'],
                        'partnerInfo': result[supplier]['partner_staff_code'],
                        'partnerFName': emp['first_name'],
                        'partnerLName': emp['last_name'],
                        'partnerGender': emp['gender'],
                        'partnerAddress': emp['address'],
                        'categories': await get_all_category(result[supplier]['supplier_code'])
                    }
                    suppliers.push(temp)
                }
                resovled(suppliers);
            };
        });
    })
}

const get_current_price = async (fabcat_code) => {
    return new Promise((resovled, reject) => {
        let price_query = "SELECT fcp.*, fc.name AS fabric_name\
        FROM fabric_agency.fabcat_current_price AS fcp\
        JOIN fabric_agency.fabric_cat AS fc ON fcp.fabcat_code = fc.fabcat_code\
        WHERE fc.fabcat_code = ?"
        db.query(price_query, fabcat_code, async (err, result) => {
            if (err) {
                reject(err);
            } else {
                let prices = []
                for (const price in result){
                    temp = {
                        'date': result[price]['valid_date'],
                        'price': result[price]['price']
                    }
                    prices.push(temp)
                }
                resovled(prices);
            };
        });
    })
}

module.exports = {
    get_current_price,
    get_all_category,
    get_all_supplier,
    get_all_supplier_by_id,
    get_emp
}