from flask import Flask, redirect, render_template, request, flash, session, Response
from passlib.hash import sha256_crypt
import pymongo
from bson.objectid import ObjectId
from datetime import datetime
import json
from typing import Tuple, Dict, Any
from dotenv import load_dotenv
import os

from pymongoarrow.monkey import patch_all
patch_all()
from pymongoarrow.api import Schema
import pandas as pd
import numpy as np

load_dotenv()

MONGO_URI = os.getenv('MONGO_URI')
APP_SECRET_KEY = os.getenv('APP_SECRET_KEY')


app = Flask(__name__)
app.secret_key = APP_SECRET_KEY

# app.config['SESSION_TYPE'] = 'filesystem'
# app.config['SECRET_KEY'] = app.secret_key
# Session(app)


client = pymongo.MongoClient(MONGO_URI)
db = client.inventorymanager

admin_register_security_key = 'secret'

transactions_schema = Schema({
    "_id": ObjectId,
    "item_id": ObjectId,
    "user_id": ObjectId,
    "quantity": int,
    "reason": str,
    "date": str,
    "type": str
})

def validate_user(request) -> Tuple[bool, Dict[str, Any]]:
    email = request.form['email']
    password = request.form['password']

    if not email or not password:
        return False, {'status': 'error', 'message': 'You must be authenticated to do that!'}
    
    user = db.users.find_one({'email': email})

    if user is None:
        return False, {'status': 'error', 'message': 'Account not found'}
    
    if not sha256_crypt.verify(password, user['password']):
        return False, {'status': 'error', 'message': 'Invalid credentials'}
    
    return True, user

def user_has_access_to_item(user, item_id) -> bool:
    for assigned_item in user.get('assigned_items', []):
        if assigned_item['item_id'] == item_id:
            return True
    return False

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'GET':
        return render_template('index.html')
    
    elif request.method == 'POST':
        document = {}
        
        if 'register' in request.form:
            document['name'] = request.form['name']
            document['email'] = request.form['email']
            document['password'] = sha256_crypt.hash(request.form['password'])

            if request.form['security'] == admin_register_security_key:
                user = db.adminaccounts.find_one({'email': document['email']})

                if user is None:
                    doc = db.adminaccounts.insert_one(document)
                    
                    session['id'] = str(doc.inserted_id)
                    return redirect('/dashboard')
                
                else:
                    flash('Unable to register')
            
            else:
                flash('Invalid security key')
                

        if 'login' in request.form:
            document['email'] = request.form['email']
            document['password'] = request.form['password']

            target = db.adminaccounts.find_one({'email': document['email']})

            if target is None:
                flash('An account with this email was not found')
            
            else:
                if sha256_crypt.verify(document['password'], target['password']):
                    session['id'] = str(target['_id'])
                    return redirect('/dashboard')
                
                else:
                    flash('Incorrect email or password')

        return redirect('/')

@app.route('/dashboard', methods=['GET', 'POST'])
def dashboard():
    if 'id' not in session:
        flash('You must be logged in!')
        return redirect('/')
    
    if request.method == 'GET':
        pipeline = [
            {
                '$group': {
                    '_id': '$category',
                    'items': {'$push': '$$ROOT'}
                }
            }
        ]

        items_by_category = list(db.items.aggregate(pipeline))
        items_by_category = sorted(items_by_category, key=lambda x: x['_id'])

        users = list(db.users.find())

        return render_template('dashboard.html', items_by_category=items_by_category, users=users)
    
    elif request.method == 'POST':
        print(request.form)
        if 'add-item' in request.form:
            document = {}
            document['name'] = request.form['name']
            document['description'] = request.form['description']
            document['quantity'] = int(request.form['quantity'])
            document['category'] = request.form['category']
            document['image'] = request.form['image']
            document['status'] = 'service'
            document['status_update_date'] = datetime.now().strftime('%Y-%m-%d')

            item = db.items.insert_one(document)

            db.transactions.insert_one({'item_id': item.inserted_id, 'user_id': ObjectId(session['id']), 'quantity': document['quantity'], 'reason': '', 'date': datetime.now().strftime('%Y-%m-%d'), 'type': 'add'})

            flash('Product added successfully')
        
        elif 'adjust-stock' in request.form:
            target = db.items.find_one({'_id': ObjectId(request.form['id'])})

            if target['quantity'] + int(request.form['quantity']) >= 0:
                target = db.items.update_one({'_id': ObjectId(request.form['id'])}, {'$inc': {'quantity': int(request.form['quantity'])}})
            
            else:
                target = db.items.update_one({'_id': ObjectId(request.form['id'])}, {'$set': {'quantity': 0}})

        elif 'change-status' in request.form:
            target = db.items.find_one({'_id': ObjectId(request.form['id'])})

            if target['status'] == 'service':
                target = db.items.update_one({'_id': ObjectId(request.form['id'])}, {'$set': {'status': 'EOL'}})
            
            elif target['status'] == 'EOL':
                target = db.items.update_one({'_id': ObjectId(request.form['id'])}, {'$set': {'status': 'service'}})

        elif 'assign-user' in request.form:
            item_id = ObjectId(request.form['item_id'])
            user_id = ObjectId(request.form['user_id'])
            quantity = int(request.form['quantity'])
            reason = request.form['reason']

            if quantity <= 0:
                flash('Invalid quantity')
                return redirect('/dashboard')
            
            if quantity > db.items.find_one({'_id': item_id})['quantity']:
                flash('Insufficient stock')
                return redirect('/dashboard')

            db.items.update_one({'_id': item_id}, {'$inc': {'quantity': -quantity}})

            user = db.users.find_one({'_id': user_id, 'assigned_items.item_id': item_id})

            if user:
                db.users.update_one({'_id': user_id, 'assigned_items.item_id': item_id}, {'$inc': {'assigned_items.$.quantity': quantity}})

            else:
                db.users.update_one({'_id': user_id}, {'$push': {'assigned_items': {'item_id': item_id, 'quantity': quantity, 'date_assigned': datetime.now().strftime('%Y-%m-%d')}}})

            db.transactions.insert_one({'item_id': item_id, 'user_id': user_id, 'quantity': quantity, 'reason': reason, 'date': datetime.now().strftime('%Y-%m-%d'), 'type': 'assign'})
        
        return redirect('/dashboard')


@app.route('/transactions', methods=['GET'])
def transactions():
    if request.method == 'GET':
        if 'id' not in session:
            flash('You must be logged in!')
            return redirect('/')
        
        transactions_list = list(db.transactions.find().sort('date', pymongo.DESCENDING))

        for transaction in transactions_list:
            if transaction['type'] != 'add':
                transaction['user_name'] = db.users.find_one({'_id': transaction['user_id']})['name']
            
            else:
                transaction['user_name'] = db.adminaccounts.find_one({'_id': transaction['user_id']})['name']

            transaction['item_name'] = db.items.find_one({'_id': transaction['item_id']})['name']

        for transaction in transactions_list:
            transaction['item_id'] = str(transaction['item_id'])
            transaction['user_id'] = str(transaction['user_id'])
        
        search_by = request.args.get('search_by')
        query = request.args.get('query')

        if search_by is not None and query is not None:
            if search_by == 'user':
                transactions_list = [transaction for transaction in transactions_list if query.lower() in transaction['user_name'].lower()]
            
            elif search_by == 'item':
                transactions_list = [transaction for transaction in transactions_list if query.lower() in transaction['item_name'].lower()]
            
            elif search_by == 'date':
                transactions_list = [transaction for transaction in transactions_list if query in transaction['date']]
        
        return render_template('transactions.html', transactions=transactions_list)

@app.route('/report')
def reports():
    if 'id' not in session:
        flash('You must be logged in!')
        return redirect('/')

    transactions_df = db.transactions.find_pandas_all({}, schema=transactions_schema)
    transactions_df.to_csv('static/transactions.csv', index=False)

    return render_template('report.html')

    
    # items = list(db.items.find())
    # for item in items:
    #     item['_id'] = str(item['_id'])
    
    # transactions = list(db.transactions.find())
    # for transaction in transactions:
    #     transaction['_id'] = str(transaction['_id'])
    #     transaction['item_id'] = str(transaction['item_id'])
    #     transaction['user_id'] = str(transaction['user_id'])
    
    # users = list(db.users.find())
    # for user in users:
    #     user['_id'] = str(user['_id'])
    #     del user['password']
    #     for assigned_item in user['assigned_items']:
    #         assigned_item['item_id'] = str(assigned_item['item_id'])
    
    # report = {
    #     'inventory': items,
    #     'transactions': transactions,
    #     'users': users
    # }

    # return Response(json.dumps(report), mimetype='application/json')

@app.route('/logout')
def logout():
    session.clear()
    return redirect('/')

# API stuff
@app.route('/api/signup', methods=['POST'])
def api_signup():
    if request.method == 'POST':
        document = {}
        document['name'] = request.form['name']
        document['email'] = request.form['email']
        document['password'] = sha256_crypt.hash(request.form['password'])
        document['assigned_items'] = []

        user = db.users.find_one({'email': document['email']})

        if user is None:
            doc = db.users.insert_one(document)
            del document['password']
            document['_id'] = str(doc.inserted_id)

            return Response(json.dumps({'status':'success', 'message':'Account created', 'account': document}), mimetype='application/json')
        
        else:
            return Response(json.dumps({'status':'error', 'message': 'An account with this email already exists.'}), mimetype='application/json')

    return Response(json.dumps({'status':'error', 'message': 'Invalid request method'}), mimetype='application/json')

@app.route('/api/login', methods=['POST'])
def api_login():
    if request.method == 'POST':
        document = {}
        document['email'] = request.form['email']
        document['password'] = request.form['password']

        target = db.users.find_one({'email': document['email']})

        if target is None:
            return Response(json.dumps({'status':'error', 'message': 'An account with this email was not found'}), mimetype='application/json')
        
        if sha256_crypt.verify(document['password'], target['password']):
            del target['password']
            target['_id'] = str(target['_id'])
            target['assigned_items'] = []
            return Response(json.dumps({'status':'success', 'message': 'Login successful', 'account': target}), mimetype='application/json')
        
        else:
            return Response(json.dumps({'status':'error', 'message': 'Incorrect email or password'}), mimetype='application/json')

    return Response(json.dumps({'status':'error', 'message': 'Invalid request method'}), mimetype='application/json')

@app.route('/api/item', methods=['POST'])
def api_item():
    if request.method == 'POST':
        print('REQUEST FORM:', request.form)
        is_validated, body = validate_user(request)

        if not is_validated:
            return Response(json.dumps(body), mimetype='application/json')
        
        user = body

        item_id = request.form['item_id']

        if item_id is None:
            return Response(json.dumps({'status':'error', 'message': 'Invalid request: No item ID supplied.'}), mimetype='application/json')
        
        if not user_has_access_to_item(user, ObjectId(item_id)):
            return Response(json.dumps({'status':'error', 'message': 'You are not authorized to view this item'}), mimetype='application/json')

        item = db.items.find_one({'_id': ObjectId(item_id)})

        item['_id'] = str(item['_id'])
        return Response(json.dumps({'status':'success', 'item': item}), mimetype='application/json')    

@app.route('/api/assigned_items', methods=['POST'])
def api_assigned_items():
    if request.method == 'POST':
        is_validated, body = validate_user(request)

        if not is_validated:
            return Response(json.dumps(body), mimetype='application/json')
        
        user = body
        assigned_items = user['assigned_items']

        for item in assigned_items:
            item['item_id'] = str(item['item_id'])
        
        return Response(json.dumps({'status':'success', 'assigned_items': assigned_items}), mimetype='application/json')

@app.route('/api/transactions', methods=['POST'])
def api_transactions():
    if request.method == 'POST':
        is_validated, body = validate_user(request)

        if not is_validated:
            return Response(json.dumps(body), mimetype='application/json')
        
        user = body

        transactions_list = list(db.transactions.find({'user_id': user['_id']}).sort('date', pymongo.DESCENDING))

        for transaction in transactions_list:
            transaction['user_name'] = db.users.find_one({'_id': transaction['user_id']})['name']
            transaction['item_name'] = db.items.find_one({'_id': transaction['item_id']})['name']

        for transaction in transactions_list:
            transaction['_id'] = str(transaction['_id'])
            transaction['item_id'] = str(transaction['item_id'])
            transaction['user_id'] = str(transaction['user_id'])
        
        return Response(json.dumps({'status':'success', 'transactions': transactions_list}), mimetype='application/json')

@app.route('/api/return_item', methods=['POST'])
def return_item():
    is_validated, body = validate_user(request)

    if not is_validated:
        return Response(json.dumps(body), mimetype='application/json')
    
    user = body
    item_id = ObjectId(request.form['item_id'])
    return_amount = int(request.form['return_amount'])
    return_reason = request.form['return_reason']

    if return_amount <= 0:
        return Response(json.dumps({'status': 'error', 'message': 'Invalid quantity'}), mimetype='application/json')

    # Find the assigned item in the user's assigned_items list
    assigned_item = next((item for item in user['assigned_items'] if item['item_id'] == item_id), None)

    if not assigned_item:
        return Response(json.dumps({'status': 'error', 'message': 'Item not assigned to user'}), mimetype='application/json')

    if assigned_item['quantity'] < return_amount:
        return Response(json.dumps({'status': 'error', 'message': 'Return quantity exceeds assigned quantity'}), mimetype='application/json')

    # Decrease the quantity of the assigned item
    db.users.update_one(
        {'_id': user['_id'], 'assigned_items.item_id': item_id},
        {'$inc': {'assigned_items.$.quantity': -return_amount}}
    )

    # Remove the item from the assigned_items list if the quantity becomes 0
    db.users.update_one(
        {'_id': user['_id']},
        {'$pull': {'assigned_items': {'item_id': item_id, 'quantity': 0}}}
    )

    # Increase the quantity of the item in the inventory
    db.items.update_one(
        {'_id': item_id},
        {'$inc': {'quantity': return_amount}}
    )

    db.transactions.insert_one({'item_id': item_id, 'user_id': user['_id'], 'quantity': return_amount, 'reason': return_reason, 'date': datetime.now().strftime('%Y-%m-%d'), 'type': 'return'})

    return Response(json.dumps({'status':'success', 'message': 'Item successfully returned'}), mimetype='application/json')
    

app.run(host='0.0.0.0', debug=True)