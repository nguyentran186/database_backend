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
const get_customer_category = async (customer_code) => {
    return new Promise((resovled, reject) => {
        let cate_query = 'SELECT\
        c.first_name,\
        c.last_name,\
        fc.fabcat_code,\
        fc.name AS fabric_category\
    FROM\
        fabric_agency.customer AS c\
    JOIN\
        fabric_agency.fab_order AS fo ON c.customer_code = fo.customer_code\
    JOIN\
        fabric_agency.bolt_and_order AS bao ON fo.order_code = bao.order_code\
    JOIN\
        fabric_agency.fabric_cat AS fc ON bao.fabcat_code = fc.fabcat_code\
    WHERE\
        c.customer_code = ?'
        db.query(cate_query, customer_code, async (err, result) => {
            if (err) {
                reject(err);
            } else {
                let categories = []
                for (const cate in result){
                    categories.push(result[cate]['fabcat_code'])
                }
                resovled(categories);
            };
        });
    })
}

const get_order_info = async (customer_code, fabcat_code) => {
    return new Promise((resovled, reject) => {
        let order_query = 'SELECT\
        c.customer_code,\
        c.first_name,\
        c.last_name,\
        fo.*,\
        b.bolt_code,\
        fc.fabcat_code,\
        fc.name AS fabric_category\
    FROM\
        fabric_agency.customer AS c\
    JOIN\
        fabric_agency.fab_order AS fo ON c.customer_code = fo.customer_code\
    JOIN\
        fabric_agency.bolt_and_order AS bao ON fo.order_code = bao.order_code\
    JOIN\
        fabric_agency.bolt AS b ON bao.bolt_code = b.bolt_code\
    JOIN\
        fabric_agency.fabric_cat AS fc ON bao.fabcat_code = fc.fabcat_code\
    WHERE\
        c.customer_code = ?  \
        AND fc.fabcat_code = ? \
    '
        db.query(order_query, [customer_code, fabcat_code], async (err, result) => {
            if (err) {
                reject(err);
            } else {
                res_ = result
                resovled(res_);
            };
        });
    })
}

const get_category_by_ID = async (fabcat_code) => {
    return new Promise((resolve, reject) => {
        let name_query = 'SELECT * FROM fabric_cat WHERE fabcat_code = ?';
        db.query(name_query, fabcat_code, (err, result) => {
            if (err) {
                reject(err);
            } else {
                resolve(result[0]);
            }
        })
    }) 
}

const get_all_category = async (customer_code) => {
    return new Promise(async (resolve, reject) => {
        let categories = []
        let fab_list = await get_customer_category(customer_code);
        for (index in fab_list){
            let cate = await get_category_by_ID(fab_list[index]);

            category = {
                'categoryID': cate['fabcat_code'],
                'categoryName': cate['name'],
                'orders': await get_all_order(cate['fabcat_code'], customer_code)
            }
            categories.push(category)
        }
        resolve(categories)
    }) 
}

const get_all_order = async (fabcat_code, customer_code) => {
    return new Promise((resolve, reject) => {
        let name_query = "SELECT\
        c.customer_code,\
        c.first_name,\
        c.last_name,\
        fo.*,\
        b.*\
        FROM\
        fabric_agency.customer AS c\
        JOIN\
        fabric_agency.fab_order AS fo ON c.customer_code = fo.customer_code\
        JOIN\
        fabric_agency.bolt_and_order AS bao ON fo.order_code = bao.order_code\
        JOIN\
        fabric_agency.bolt AS b ON bao.bolt_code = b.bolt_code\
        JOIN\
        fabric_agency.fabric_cat AS fc ON b.fabcat_code = fc.fabcat_code\
        WHERE\
        fc.fabcat_code = ?\
        AND c.customer_code = ?";
        db.query(name_query,[fabcat_code, customer_code],async (err, result) => {
            if (err) {
                reject(err);
            } else {
                let orders = []
                for (index in result){
                    let order = {
                        'ID': result[index]['order_code'],
                        'boltID': result[index]['bolt_code'],
                        'dateTimeMade': result[index]['date_time'],
                        'totalPrice': result[index]['total_price'],
                        'status': result[index]['or_status'],
                        'dateTimeProcessed': await get_datetime_process(result[index]['order_code']),
                        'cancelReason': await get_cancel_reason(result[index]['order_code']),
                        'paymentHistory': await get_all_partial_payment(result[index]['order_code'])
                    }
                    orders.push(order);
                }
                resolve(orders);
            }
        })
    })  
}

const get_all_partial_payment = async (order_code) => {
    return new Promise((resolve, reject) => {
        let name_query = 'SELECT opp.* FROM fabric_agency.order_partial_payment AS opp WHERE opp.order_code = ?';
        db.query(name_query, order_code, (err, result) => {
            if (err) {
                reject(err);
            } else {
                let payments = []
                for (index in result){
                    let payment = {
                        'date' : result[index]['pay_date'],
                        'time' : result[index]['pay_time'],
                        'amount': result[index]['amount']
                    }
                    payments.push(payment)
                }
                resolve(payments);
            }
        })
    }) 
}

const get_cancel_reason = async (order_code) => {
    return new Promise((resolve, reject) => {
        let name_query = "SELECT\
        co.*\
        FROM\
        fabric_agency.customer AS c\
        JOIN\
        fabric_agency.fab_order AS fo ON c.customer_code = fo.customer_code\
        JOIN\
        fabric_agency.cancelled_order AS co ON fo.order_code = co.order_code\
        WHERE\
        co.order_code = ?"
        db.query(name_query, order_code, (err, result) => {
            if (err) {
                reject(err);
            } else {
                if (result.length == 0) resolve('None');
                else resolve(result[0]['cancelled_reason']);
            }
        })
    })  
}

const get_datetime_process = async (order_code) => {
    return new Promise((resolve, reject) => {
        let name_query = "SELECT\
        c.customer_code,\
        c.first_name,\
        c.last_name,\
        po.processed_datetime\
        FROM\
        fabric_agency.customer AS c\
        JOIN\
        fabric_agency.fab_order AS fo ON c.customer_code = fo.customer_code\
        JOIN\
        fabric_agency.processed_order AS po ON fo.order_code = po.order_code\
        WHERE\
        po.order_code = ?"
        db.query(name_query, order_code, (err, result) => {
            if (err) {
                reject(err);
            } else {
                if (result.length == 0) resolve('None');
                else resolve(result[0]['processed_datetime']);
            }
        })
    })  
}

const get_customer_info = async (customer_code) => {
    return new Promise((resovled, reject) => {
        let order_query = 'SELECT * FROM fabric_agency.customer WHERE customer_code = ?'
        db.query(order_query, customer_code, async (err, result) => {
            if (err) {
                reject(err);
            } else {
                res_ = result
                resovled(res_[0]);
            };
        });
    })
}

const get_phone_customer = async (customer_code) => {
    return new Promise((resovled, reject) => {
        let phone_query = 'SELECT * FROM customer_phone_number WHERE customer_code = ?'
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

module.exports = {get_customer_category, 
    get_order_info, 
    get_category_by_ID, 
    get_all_partial_payment, 
    get_all_order, 
    get_cancel_reason, 
    get_datetime_process, 
    get_all_category, 
    get_customer_info,
    get_phone_customer}