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
    if (req['enableDateTimeRange'] == true){
        console.log(1)
        let fab_id_query = 'SELECT * FROM import_info WHERE fabcat_code = ? AND import_date >= ? and import_date <= ?';
        db.query(fab_id_query, [id, req['dateFrom'], req['dateTo']], (err, result) => {
        if (err) throw err;
            console.log(result)
            return result
        })
    }
    else {
        let fab_id_query = 'SELECT * FROM import_info WHERE fabcat_code = ?';
        db.query(fab_id_query, id, (err, result) => {
            if (err) throw err;
            console.log(result)
            return result
        })
    }
}



///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////


app.listen('3000', () => {
    console.log('Server started on port 3000')
});

app.get('/ques1', (req , res) => {
    let id = 'undefined';

    if (req['searchByID'] == true) {
        id = req['categoryID'];
    }
    else{
        let name_query = 'SELECT * FROM fabric_cat WHERE name = ?'
        db.query(name_query, 'Tasar Silk', async (err, result) => {
        // db.query(name_query, req['categoryName'], (err, result) => {
            if (err) throw err;
            id = result[0]['fabcat_code'];
            request = {
                'enableDateTimeRange': false,
                'dateFrom': '2023-08-30',
                'dateTo': '2023-09-30'
            }
            let query_result = await supplier_query(id, request)
            console.log(query_result)
        })
    }


    
    // let sql = 'SELECT * FROM BOLT';
    // db.query(sql, (err,result) => {
    //     if(err) throw err;
    //     console.log(result);
    //     res.send(result);
    // })
})