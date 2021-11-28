import datetime
import re
from flask import Flask, g
from flask_restful import Api
from flask_pymongo import PyMongo
from login_register import Auth, Feed, Interact, Edit, token_required
from chat import Chat
import config
from flask import send_file
import os
import requests
app = Flask(__name__)
api = Api(app)
app.app_context().push()

@app.before_request
def before_request():
    app.config["MONGO_URI"] = config.DATABASE_URI
    mongo = PyMongo(app)
    g.db = mongo.db

api.add_resource(Auth, '/api/auth')
api.add_resource(Chat, '/api/chat')
#api.add_resource(Details, '/api/get_details')
@app.route('/api/protected', methods=['GET','POST'])
@token_required         # add this decorator to authenticate the request
def dummy(current_user):
    return '%s' % current_user['username']


@app.route('/api/users',methods=['GET'])
def get():
    res={
        "success": False,
        "users" : [],
    }
    try:
        res["users"]=list(g.db.profile.find({}))
        
        
        req=res
        for i in range(len(res["users"])):
            req["users"][i]["_id"]=str(res["users"][i]["_id"])
        #print(res["users"])
        print(req["users"])

        req["success"]=True
        return req,200
    except:
        return res,500


@app.route('/api/user/<string:_id>',methods=['GET'])
def get_user(_id):
    from bson.objectid import ObjectId
    _id=ObjectId(_id)
    res={
        "success": False,
        "user" : {},
    }
    try:
        res["user"]=g.db.profile.find_one({"_id":_id})
        res["user"]["_id"]=str(res["user"]["_id"])
        res["success"]=True
        return res,200
    except:
        return res,500


@app.route('/api/health',methods=['GET'])
@token_required
def isTokenExpired(current_user):
    expiry = current_user['expires']
    current_time = datetime.datetime.utcnow()
    if(expiry>current_time):
        time_left = expiry - current_time 
        return {'expiry':time_left.days}
    
    g.db.Sessions.delete_one({'token':current_user['token']})
    return {'expiry':'Token expired'}

api.add_resource(Feed, '/api/feed')
#api.add_resource(Details, '/api/get_details')
@app.route('/api/protected', methods=['GET','POST'])
@token_required         # add this decorator to authenticate the request
def dummy1(current_user):
    return '%s' % current_user['username']


api.add_resource(Interact, '/api/interact')
#api.add_resource(Details, '/api/get_details')
@app.route('/api/protected', methods=['GET','POST'])
@token_required         # add this decorator to authenticate the request
def dummy2(current_user):
    return '%s' % current_user['username']

api.add_resource(Edit, '/api/edit')
#api.add_resource(Details, '/api/get_details')
@app.route('/api/protected', methods=['POST'])
@token_required         # add this decorator to authenticate the request
def dummy3(current_user):
    return '%s' % current_user['username']

# api.add_resource(EditPost, '/api/editpost')
# #api.add_resource(Details, '/api/get_details')
# @app.route('/api/protected', methods=['POST'])
# @token_required         # add this decorator to authenticate the request
# def dummy4(current_user):
#     return '%s' % current_user['username']


if __name__ == '__main__':
   app.run(debug=True)
