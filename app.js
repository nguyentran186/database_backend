const express = require('express');
const mysql = require('mysql');


/////////////////    DATABASE CONNECT     ////////////////
//////////////////////////////////////////////////////////
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'fabric_agency'
});

db.connect((err) => {
    if(err){
        throw err;
    }
    console.log('MySql Connected ...')
});


const app = express();
/////////////       FUNCTION                ///////////////
///////////////////////////////////////////////////////////
let supplier_query = (id, req) => {
    return new Promise((resolve, reject) => {
        if (req['enableDateTimeRange'] == true) {
            let fab_id_query = 'SELECT * FROM import_info WHERE fabcat_code = ? AND import_date >= ? and import_date <= ?';
            db.query(fab_id_query, [id, req['dateFrom'], req['dateTo']], (err, result) => {
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



///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////


app.listen('3000', () => {
    console.log('Server started on port 3000')
});

app.get('/ques1', (req, res) => {
    let request = {
        'categoryName': 'Tasar Silk',
        'enableDateTimeRange': false,
        'dateFrom': '2023-08-30',
        'dateTo': '2023-09-30'
    };

    let id = 'undefined';

    if (req['searchByID'] == true) {
        id = req['categoryID'];
    } else {
        let name_query = 'SELECT * FROM fabric_cat WHERE name = ?';
        db.query(name_query, request['categoryName'], async (err, result) => {
            if (err) {
                throw err;
            }
            id = result[0]['fabcat_code'];

            try {
                let query_result = await supplier_query(id, request);
                console.log(query_result);
                res.json(query_result);
            } catch (err) {
                console.error(err);
                // Handle error appropriately
            }
        });
    }
});

