const express = require('express');
const cors = require('cors');
const utils1 = require('./utils1');
// const utils2 = require('./utils2');
// const utils3 = require('./utils3');
const utils4 = require('./utils4');


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

app.get('/ques2', async (req, res) => {
    request = {
        'name': 'test',
        'bank_account': '123123123',
        'address': '720 Dien Bien Phu',
        'tax_code': 'FA2345',
        'phone_numbers': ['0905123123', '0906123123']
    }
    utils2.operation(request, res)
})

app.get('/ques3', async (req, res) => {
    let res_;
    if(req['searchByID'] == true) {
        res_ = await utils3.get_all_supplier(req['supplierName:'])
    }
    else{
        res_ = await utils3.get_all_supplier_by_id(req['supplierID'])
    }
    console.log(res_)
    res.json(res_)
})

app.get('/ques4', async (req, res) => {
    let customer = await utils4.get_customer_info(req['customerID'])
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
