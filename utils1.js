const db = require('./dbConnection');

// ##############################################
// ##############################################
// ##############################################

const import_info = (id, req) => {
    return new Promise((resolve, reject) => {
        if (req['enableDateTimeRange'] == 'true') {
            let fab_id_query = 'SELECT * FROM import_info WHERE fabcat_code = ? AND ((import_date > ? AND import_date < ?) OR (import_date = ? AND import_time >= ?) or (import_date = ? AND import_time <= ?))'
            db.query(fab_id_query, [id, req['dateFrom'], req['dateTo'], req['dateFrom'], req['timeFrom'],req['dateTo'], req['timeTo']], (err, result) => {
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

const get_fabric = async (req) => {
    if (req['searchByID'] == 'true') {
        console.log(req)
        return new Promise((resolve, reject) => {
            let name_query = 'SELECT * FROM fabric_cat WHERE fabcat_code = ?';
            db.query(name_query, req['categoryID'], (err, result) => {
                if (err) {
                    reject(err);
                } else {
                    resolve(result);
                }
            })
        })
    } else {
        return new Promise((resolve, reject) => {
            const name = req['categoryName']
            let name_query = 'SELECT * FROM fabric_cat WHERE name LIKE ?';
            db.query(name_query, ['%' + name + '%'], (err, result) => {
                if (err) {
                    reject(err);
                } else {
                    resolve(result);
                }
            });
        });
    }
};

const get_supplier = async (supplier_code) => {
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

const get_phone = async (supplier_code) => {
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

module.exports = {import_info, get_fabric, get_phone, get_supplier}