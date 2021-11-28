from flask import request, g
import uuid
from datetime import datetime
from flask_restful import Resource
from functools import wraps
import config
import requests
from flask_pymongo import PyMongo
# message_id
# parent_message_id
# sender_id
# reciever_id
# data
# time

class Chat(Resource):

    # if group_id does not exist, we will create and make sender_id as admin, other members listed as members
    # if group_id exists, we will add that particular message with sender_id as sender
    def post(self):
        res={
            "success": False,
            "message":"Insufficient query parameters",
        }
    
        try:
            # both are in form of object id's
            sender_id = request.form.get('sender',None)
            receiver_id= request.form.get('receiver',None)
            content = request.form.get('content',None)
            type = request.form.get('type',None)
            time = request.form.get('time',None)
            if (sender_id or receiver_id) is None:
                return res,400

            chat={
                "sender_id": sender_id,
                "receiver_id" : receiver_id,
                "type": type,
                "content":content,
                "time":str(datetime.now())
            }
            
            
            from bson.objectid import ObjectId
            g.db.profile.update_one({"_id": ObjectId(sender_id)},{"$push":{"chats":chat}})
            
            
            g.db.profile.update_one({"_id": ObjectId(receiver_id)},{"$push":{"chats":chat}})
            
            return {
                "success": True,
                "message": ""
            }

        except:
            res["message"]="Internal Server Error"
            return res,500


    # if is_group, then we send all messages data along with sender_id and date 
    def get(res):
        res={
            "success": False,
            "message":"Insufficient query parameters",
        }
        
        id1 = request.args.get('id1', None)
        id2 = request.args.get('id2',None)
        print(id1)
        print(id2)
        if id1 is None or id2 is None:
            return res,400

        else:
            try:
                from bson.objectid import ObjectId
                group=g.db.profile.find_one({"_id": ObjectId(id1)})
                print(group)
                chats=group["chats"]
                print(chats)
                to_send=[]
                print("ppp")
                for chat in chats:
                    if (chat["sender_id"]==id1 and chat["receiver_id"]==id2) or (chat["sender_id"]==id2 and chat["receiver_id"]==id1):
                        to_send.append(chat)
                print("ooo")
                sorted_date = chats#sorted(to_send, key=lambda x:x['time'])

                # for chat in sorted_date:
                #     sorted_date["time"]=str(sorted_date["time"])
                print(sorted_date)
                return {
                    "success": True,
                    "message": sorted_date
                } 
            except:
                res["message"]="Internal Server Error"
                return res,500
