const express = require('express');
const bodyParser = require('body-parser')
const cors = require('cors');
const utils1 = require('./utils1');
const utils2 = require('./utils2');
const utils3 = require('./utils3');
const utils4 = require('./utils4');
const login = require('./login');
// const { get_supplier_code } = require('./utils2');


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
app.use( bodyParser.json());
app.use(cors());
process.on('uncaughtException', (err) => {
    console.error('Uncaught Exception:', err);
});
/////////////       FUNCTION                ///////////////
///////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////


app.listen(3000, () => {
    console.log('Server started on port https://localhost:3000')
});

app.get('/ques1', async (req, res) => {
    let request = req.query
    console.log(request)
    let fabrics = await utils1.get_fabric(request)
    if (fabrics.length == 0) {
        let res_ = {}
        console.log(res_)
        res.json()
        return
    }
    console.log(fabrics)
    let allMatches = []
    for (let fabric in fabrics) {
        fabric = fabrics[fabric]
        let supplier = await utils1.get_supplier(fabric['supplier_code'])
        let query_result = await utils1.import_info(fabric['fabcat_code'], request)
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
        allMatches.push(res_)
    }


    res.json(allMatches)
});

app.post('/ques2', async (req, res) => {
    request = req.body['params']
    utils2.operation(request, res)
})

app.get('/ques3', async (req, res) => {
    const request = req.query
    let res_;

    if (request['searchByPhoneNumber'] === 'true') {
        res_ = await utils3.get_all_supplier_by_phoneNum(request['supplierPhoneNumber'])
    } else {
        if (request['searchByID'] === 'false') {
            res_ = await utils3.get_all_supplier(request['supplierName'])
        }
        else if (request['searchByID'] === 'true') {
            res_ = await utils3.get_all_supplier_by_id(request['supplierID'])
        }
    }

    if (res_.length === 0) {
        res.json([])
        return
    }
    
    console.log(res_)
    console.log(res_[0].categories)
    res.json(res_)
})

app.get('/ques4', async (req, res) => {
    const request = req.query
    let customer;

    if (request['searchByPhoneNumber'] === 'true') {
        customer = await utils4.get_customer_by_phoneNum(request['customerPhoneNumber'])
    } else customer = await utils4.get_customer_info(request['customerID'])

    if (customer.length === 0) {
        res.json()
        return
    }
    customer = customer[0]

    let res_ = {
        'ID': customer['customer_code'],
        'fName': customer['first_name'],
        'lName': customer['last_name'],
        'address': customer['address'],
        'arrearage': customer['arrearage'] === null ? 0 : customer['arrearage'],
        'mode': customer['mode'],
        'debtStartDate': customer['debt_date'] === null ? 'null' : customer['debt_date'],
        'phoneNumbers': await utils4.get_phone_customer(customer['customer_code']),
        'orders': await utils4.get_all_order(customer['customer_code']),
    }
    // console.log(res_)
    res.json(res_)
})

app.post('/login/safe', async (req, res) => {
    const request = req.body
    const result = await login.safeLogin(request)
    if (result.length === 0) {
        const response = {
            'status': 'failed',
            'message': 'Username or password is incorrect'
        }
        res.status(200).send(response)
    } else {
        const response = {
            'status': 'success',
            'message': 'Login successfully'
        }
        res.status(200).send(response)
    }
})

app.post('/login/unsafe', async (req, res) => {
    const request = req.body
    let result = []
    try {
        result = await login.unsafeLogin(request)
    } catch (err) {
        console.log(err)
        const response = {
            'status': 'failed',
            'message': 'Internal server error'
        }
        res.status(200).send(response)
    }
    if (result.length === 0) {
        const response = {
            'status': 'failed',
            'message': 'Username or password is incorrect'
        }
        res.status(200).send(response)
    } else {
        const response = {
            'status': 'success',
            'message': 'Login successfully'
        }
        res.status(200).send(response)
    }
})