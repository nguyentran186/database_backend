const express = require('express');
const mysql = require('mysql');


/////////////////    DATABASE CONNECT     ////////////////
//////////////////////////////////////////////////////////
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
    console.log('MySql Connected ...')
});

let request = {
    'searchByID': true,
    'categoryId': 'FA0001',
    'categoryName': 'Tasar Silk',
    'enableDateTimeRange': true,
    'dateFrom': '2023-09-06',
    'dateTo': '2023-09-18',
    'timeFrom': '14:00:00',
    'timeTo': '07:00:00'
};

const app = express();
/////////////       FUNCTION                ///////////////
///////////////////////////////////////////////////////////
let import_info = (id, req) => {
    return new Promise((resolve, reject) => {
        if (req['enableDateTimeRange'] == true) {
            let fab_id_query = 'SELECT * FROM import_info WHERE fabcat_code = ? AND ((import_date > ? and import_date < ?) or (import_date = ? and import_time >= ?) or (import_date = ? and import_time <= ?))'
            db.query(fab_id_query, [id, req['dateFrom'], req['dateTo'], req['dateFrom'], req['timeFrom'], req['dateTo'], req['timeTo']], (err, result) => {
                if (err) {
                    reject(err);
                } else {
                    resolve(result);
                }
            });
        } else {
            let fab_id_query = 'SELECT * FROM import_info WHERE fabcat_code = ?';
            db.query(fab_id_query, id, (err, result) => {
                if (err) {
                    reject(err);
                } else {
                    resolve(result);
                }
            });
        }
    });
};

let get_fabric = async (req) => {
    if (req['searchByID'] == true) {
        return new Promise((resolve, reject) => {
            let name_query = 'SELECT * FROM fabric_cat WHERE fabcat_code = ?';
            db.query(name_query, req['categoryId'], (err, result) => {
                if (err) {
                    reject(err);
                } else {
                    resolve(result[0]);
                }
            })
        })
    } else {
        return new Promise((resolve, reject) => {
            let name_query = 'SELECT * FROM fabric_cat WHERE name = ?';
            db.query(name_query, req['categoryName'], (err, result) => {
                if (err) {
                    reject(err);
                } else {
                    resolve(result[0]);
                }
            });
        });
    }
};

let get_supplier = async (supplier_code) => {
    return new Promise((resovled, reject) => {
        let supplier_query = 'SELECT * FROM supplier WHERE supplier_code = ?'
        db.query(supplier_query, supplier_code, async (err, result) => {
            if (err) {
                reject(err);
            } else {
                resovled(result[0]);
            };
        });
    });
}

let get_phone = async (supplier_code) => {
    return new Promise((resovled, reject) => {
        let supplier_phone_query = 'SELECT * FROM supplier_phone_number WHERE supplier_code = ?'
        db.query(supplier_phone_query, supplier_code, async (err, result) => {
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
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////


app.listen('3000', () => {
    console.log('Server started on port 3000')
});

app.get('/ques1', async (req, res) => {
    let fabric = await get_fabric(request)
    let supplier = await get_supplier(fabric['supplier_code'])
    let query_result = await import_info(fabric['fabcat_code'], request)
    let supplier_phone = await get_phone(supplier['supplier_code'])
    
    let res_ = {
            'categoryName': fabric['name'],
            'categoryId': fabric['fabcat_code'],
            'supplierID': fabric['supplier_code'],
            'supplierName': supplier['name'],
            'supplierPhoneNumbers' : supplier_phone,
            'importInfos': query_result
        }
    
        console.log(res_)


    res.json(res_)
});

