const express = require('express');
const utils = require('./utils');


/////////////////    DATABASE CONNECT     ////////////////
//////////////////////////////////////////////////////////


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

///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////


app.listen('3000', () => {
    console.log('Server started on port 3000')
});

app.get('/ques1', async (req, res) => {
    let fabric = await utils.get_fabric(req)
    let supplier = await utils.get_supplier(fabric['supplier_code'])
    let query_result = await utils.import_info(fabric['fabcat_code'], req)
    let supplier_phone = await utils.get_phone(supplier['supplier_code'])
    
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

