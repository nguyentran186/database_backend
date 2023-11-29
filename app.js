const express = require('express');
const bodyParser = require('body-parser')
const cors = require('cors');
const utils1 = require('./utils1');
const utils2 = require('./utils2');
const utils3 = require('./utils3');
const utils4 = require('./utils4');
const { get_supplier_code } = require('./utils2');


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
    'timeTo': '07:00:00',
};

const app = express();
app.use( bodyParser.json() );
app.use(cors());
/////////////       FUNCTION                ///////////////
///////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////


app.listen('3000', () => {
    console.log('Server started on port 3000')
});

app.get('/ques1', async (req, res) => {
    let request = req.query
    let fabric = await utils1.get_fabric(request)
    console.log(fabric)
    let supplier = await utils1.get_supplier(fabric['supplier_code'])
    let query_result = await utils1.import_info(fabric['fabcat_code'], req)
    let supplier_phone = await utils1.get_phone(supplier['supplier_code'])
    
    let res_ = {
            'categoryName': fabric['name'],
            'categoryID': fabric['fabcat_code'],
            'supplierID': fabric['supplier_code'],
            'supplierName': supplier['name'],
            'supplierPhoneNumbers' : supplier_phone,
            'importInfos': query_result
        }
    
        console.log(res_)


    res.json(res_)
});


app.post('/ques2', async (req, res) => {
    // let request = {
    //     'name': 'Nguyen',
    //     'address': '123 Dien Bien Phu',
    //     'bankAccount': '102938120',
    //     'taxCode': 'TA1233',
    //     'phoneNumbers': ['0989128301', '0918238122']
    // }
    request = req.body['params']
    utils2.operation(request, res)
})

app.get('/ques3', async (req, res) => {
    const request = req.query
    let res_;
    if(request['searchByID'] == 'false') {
        res_ = await utils3.get_all_supplier(request['supplierName'])
    }
    else{
        res_ = await utils3.get_all_supplier_by_id(request['supplierID'])
    }
    console.log(res_)
    res.json(res_)
})

app.get('/ques4', async (req, res) => {
    const request = req.query
    let customer = await utils4.get_customer_info(request['customerID'])
    let res_ = {
        'ID': customer['customer_code'],
        'fName': customer['first_name'],
        'lName': customer['last_name'],
        'address': customer['address'],
        'arrearage': customer['arrearage'],
        'debtStartDate': customer['debt_start_date'],
        'phoneNumbers': await utils4.get_phone_customer(customer['customer_code']),
        'categories': await utils4.get_all_category(customer['customer_code'])
    }
    res.json(res_)
})
