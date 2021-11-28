from flask import request, g
import uuid
import datetime
import json
from flask_restful import Resource
from bson import ObjectId
from functools import wraps
import config
import requests
def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        if 'x-access-token' in request.headers:
            token = request.headers['x-access-token']
        if not token:
            return 'Token not present', 401

        try:
            current_user = g.db.Sessions.find_one({'token': token})
            if not current_user:
                return 'Unauthorized Access!', 401
        except:
            return 'Internal Server Error', 500
        
        return f(*args, **kwargs, current_user=current_user)

    return decorated


class Auth(Resource):
    # def get(self):
    #     res={
    #         "success": False,
    #         "message":"Insufficient query parameters",
    #         "details" :{},
    #     }
        
    #     username = request.form.get('username',None)
    #     password = request.form.get('password',None)
    #     if (username is None) or (password is None):
    #         return res,400
        
    #     try:
    #         profile_data=g.db.profile.find_one({"username":username})
    #         print(profile_data)
    #         if profile_data==None:
    #             res["message"]="user does not exist"
    #             return res,200
    #         data=profile_data["password"]
    #         if password==data:
    #             res["message"]="successful"
    #             res["details"]=profile_data.__str__()
    #             res["success"]=True
    #             return res,200
    #         res["message"]="password does not match"
    #         return res,300
    #     except:
    #         res["message"]="Internal Server Error"
    #         return res,500

    def post(self):
        res={
            "success": False,
            "message":"Insufficient query parameters",
            "details" :{},
        }
        
        username = request.form.get('username',None)
        password = request.form.get('password',None)
        first_name = request.form.get('first_name',None)
        last_name = request.form.get('last_name',None)
        gender = request.form.get('gender',None)
        friends=[]
        interests=[]
        posts=[]

        type= request.form.get('type',None)
        
        if (username is None) or (password is None) or (type is None):
            return res,400

        if(type == 'register'):

            first_name = request.form.get('first_name',None)
            profile_picture = request.form.get('profile_picture',None)
            last_name = request.form.get('last_name',None)
            gender = request.form.get('gender',None)
            friends=[]
            bio="zzzzz"
            posts=[]
            
            if (first_name is None) or (last_name is None) or (gender is None):
                return res,400

            try:
                profile_data=g.db.profile.find_one({"username":username})
                print(profile_data)
                if profile_data!=None:
                    res["message"]="user already exists"
                    return res,300
            
                element=g.db.profile.insert_one({"username":username, "password":password,"first_name":first_name,"last_name":last_name,'gender':gender,'interests':interests,'friends':friends,"posts":posts,"chats":[]})
                res["message"]="successful"
                res["success"]=True
                res["details"]={
                                "_id":str(element.inserted_id),
                                "username":username,
                                "password":password,
                                "first_name":first_name,
                                "last_name":last_name,
                                "gender":gender,
                                "friends":friends,
                                "interests":interests,
                                "posts":posts,
                                "chat_groups":[],
                                }
                return res,200
            except:
                res["message"]="Internal Server Error"
                return res,500

        elif(type == 'login'):
            try:
                profile_data=g.db.profile.find_one({"username":username})

                if profile_data==None:
                    res["message"]="user does not exist"
                    return res,300
                
                data=profile_data["password"]
                if password==data:
                    res["message"]="successful"
                    res["details"]=profile_data
                    res["details"]["_id"]=str(res["details"]["_id"])
                    res["success"]=True
                    return res,200
                res["message"]="password does not match"
                return res,300
            except:
                res["message"]="Internal Server Error"
                return res,500
        else:
            res["message"]="Invalid Type"
            return res,300
        
class Feed(Resource):
    def get(self):
        res={
            "success": False,
            "message":"Insufficient query parameters",
            "details" : {},
        }
        username=request.form.get("username",None)

        #If username is not present return all posts from old to new
        if username is None:
            try:
            
                res["details"]=list(g.db.post.find()).__str__()
                res["success"]=True;
                res["message"]="successful";

                return res,200
            except:
                res["message"]="Internal Server Error"
                return res,500
        
        #If username is present, then give all posts of that user only
        try:    
            post_data=g.db.profile.find_one({"username":username})

            if(post_data is None):
                res["message"]="user does not exist"
                return res,300

            friend_posts=[]

            for user in post_data["friends"]:
                friend_posts.extend(g.db.profile.find_one({"username":user})["posts"])

            friend_posts.sort(key=lambda s:s["created_time"],reverse=True)
            
            res["details"]=friend_posts.__str__()
            
            res["message"]="successful"
            res["success"]=True

            return res,200
        except:
            res["message"]="Internal Server Error"
            return res,500

    def post(self):
        res={
            "success": False,
            "message":"Insufficient query parameters",
            "details" :{},
        }
        username=request.form.get("username",None)

        if username is None:
            return res,400;
        
        try:    
            post_maker=g.db.profile.find_one({"username":username})

            if post_maker is None:
                res["message"]="user does not exist"
                return res,300

            owner=username
            content=request.form.get("content",None)
            description=request.form.get("description",None)
            likes=[]
            comments=[]
            created_time=datetime.datetime.now().__str__();

            if content is None or description is None:
                res["message"]="No content/description"
                return res,400

            post_details={"owner":owner,"content":content,"description":description,"likes":likes,"comments":comments,"created_time":created_time}

            object_id = g.db.post.insert_one(post_details).inserted_id
                
            g.db.profile.update({"username":username},{"$push":{"posts":post_details}})
            
            post_details = g.db.post.find_one({"_id":object_id})
            res["details"]=post_details.__str__()
            res["message"]="successful"
            res["success"]=True

            return res,200

        except:
            res["message"]="Internal Server Error"
            return res,500

class Interact(Resource):
    def get(self):
        res={
            "success": False,
            "message":"Insufficient query parameters",
            "details" :{},
        }
        post_id=request.form.get("post_id",None)

        if post_id is None:
            return res,400;
        
        try:
            post_data=g.db.post.find_one({"_id":ObjectId(post_id)})
            if post_data is None:
                
                res["message"]="No such post exists"
                return res,300

            res["details"]=post_data.__str__()
            res["message"]="successful"
            res["success"]=True

            return res,200
        except:
            res["message"]="Internal Server Error"
            return res,500;

    def post(self):
        res={
            "success": False,
            "message":"Insufficient query parameters",
            "details" :{},
        }
        post_id=request.form.get("post_id",None)
        type=request.form.get("type",None);

        if (post_id or type) is None:
            return res,400;
        
        try:
            post_data=g.db.post.find_one({"_id":ObjectId(post_id)})

            if post_data is None:
                
                res["message"]="No such post exists"
                return res,300

            if type == "inc":

                liker=request.form.get("liker",None)

                if liker is None:
                    
                    res["message"]="Liker not present"
                    return res,400

                check1 = g.db.profile.find({"username":liker}).count()
                check2 = g.db.post.find_one({"_id":ObjectId(post_id)})
                
                if check1!=1:
                    res["message"]="Liker Profile does not exist"
                    return res,400

                if (liker in check2["likes"]):

                    res["message"]="Already Liked"
                    return res,300
                
                g.db.post.update_one({"_id":ObjectId(post_id)},{"$push":{"likes":liker}})
                g.db.profile.update_one({"username":post_data["owner"],"posts._id":ObjectId(post_id)},{"$push":{"posts.$.likes":liker}})
                res["details"]=g.db.post.find_one({"_id":ObjectId(post_id)}).__str__()
                res["message"]="successful"
                res["success"]=True
                return res,200
            elif type == "dec":

                unliker=request.form.get("unliker",None)

                if unliker is None:
                    
                    res["message"]="Unliker not present"
                    return res,400
                
                check1 = g.db.profile.find({"username":unliker}).count()
                check2 = g.db.post.find_one({"_id":ObjectId(post_id)})

                if check1!=1:
                    res["message"]="Unliker Profile does not exist"
                    return res,400
                
                if not (unliker in check2["likes"]):

                    res["message"]="Already Disliked"
                    return res,300

                g.db.post.update_one({"_id":ObjectId(post_id)},{"$pull":{"likes":unliker}})
                g.db.profile.update_one({"username":post_data["owner"],"posts._id":ObjectId(post_id)},{"$pull":{"posts.$.likes":unliker}})
                
                res["details"]=g.db.post.find_one({"_id":ObjectId(post_id)}).__str__()
                res["message"]="successful"
                res["success"]=True
                return res,200
            
            elif type == "comment":

                owner_comment=request.form.get("owner_comment",None)
                content_comment=request.form.get("content_comment",None)
                
                #print(owner_comment,content_comment)
                created_time_comment=datetime.datetime.now().__str__()
                likes=[]

                if (owner_comment is None) or (content_comment is None) or (created_time_comment is None):
                    
                    return res,400
                
                if g.db.profile.find_one({"username":owner_comment}) is None:
                    res["details"]="Username that made comment does not exist"
                    return res,300
                
                comment={"owner":owner_comment,"content":content_comment,"created_time":created_time_comment,"likes":likes}
                g.db.post.update_one({"_id":ObjectId(post_id)},{"$push":{"comments":comment}})
                commented_post=g.db.post.find_one({"_id":ObjectId(post_id)})
                g.db.profile.update_one({"username":commented_post["owner"],"posts._id":ObjectId(post_id)},{"$push":{"posts.$.comments":comment}})
                res["details"]=commented_post.__str__()
                res["message"]="successful"
                res["success"]=True

                return res,200
            else:
                res["message"]="Invalid Type"
                return res,300

        except:
            res["message"]="Internal Server Error"
            return res,500;

class Edit(Resource):
    def post(self):
        res={
            "success": False,
            "message":"Insufficient query parameters",
            "details" :{},
        }
        username=request.form.get("username",None)

        if username is None:
            return res,400;
        
        try:    
            profile_edit=g.db.profile.find_one({"username":username})

            if profile_edit is None:
                res["message"]="user does not exist"
                return res,300

            password = request.form.get("password",None)
            first_name = request.form.get("first_name",None)
            last_name = request.form.get("last_name",None)
            profile_picture = request.form.get("profile_picture",None)
            bio = request.form.get("bio",None)
            gender = request.form.get("gender",None)
            add_friend = request.form.get("add_friend",None)
            delete_friend = request.form.get("delete_friend",None)

            if not (password is None):
                g.db.profile.update({"username":username},{"$set":{"password":password}})
            
            if not (first_name is None):
                g.db.profile.update({"username":username},{"$set":{"first_name":first_name}})
            
            if not (last_name is None):
                g.db.profile.update({"username":username},{"$set":{"last_name":last_name}})
            
            if not (profile_picture is None):
                g.db.profile.update({"username":username},{"$set":{"profile_picture":profile_picture}})
            
            if not (bio is None):
                g.db.profile.update({"username":username},{"$set":{"bio":bio}})
            
            if not (gender is None):
                g.db.profile.update({"username":username},{"$set":{"gender":gender}})
            
            if not (add_friend is None):
                
                if username == add_friend:
                    res["message"] = "Cannot friend yourself"
                    return res,300
                
                check = g.db.profile.find({"username": username,"friends": { "$in": [add_friend] }}).count();

                friend_profile = g.db.profile.find_one({"username":add_friend})

                if friend_profile is None:
                    res["message"]="Friend does not exist"
                    return res,400

                if( check == 1):
                    res["message"]="Already Friends"
                    return res,300

                g.db.profile.update({"username":username},{"$push":{"friends":add_friend}})
                g.db.profile.update({"username":add_friend},{"$push":{"friends":username}})
            
            if not (delete_friend is None):
                
                if username == delete_friend:
                    res["message"] = "Cannot unfriend yourself"
                    return res,300

                friend_profile = g.db.profile.find_one({"username":delete_friend})

                if friend_profile is None:
                    res["message"]="Friend does not exist"
                    return res,400
                
                check = g.db.profile.find({"username": username,"friends": { "$in": [delete_friend] }}).count();

                if( check == 0):
                    res["message"]="Already Unfriended"
                    return res,300

                g.db.profile.update({"username":username},{"$pull":{"friends":{"$in": [delete_friend]}}})
                g.db.profile.update({"username":delete_friend},{"$pull":{"friends":{"$in": [username]}}})
            
            res["details"] = g.db.profile.find_one({"username":username}).__str__()
            res["message"]="successful"
            res["success"]=True

            return res,200

        except:
            res["message"]="Internal Server Error"
            return res,500

# class EditPost(Resource):
#     def post(self):
#         res={
#             "success": False,
#             "message":"Insufficient query parameters",
#             "details" :{},
#         }
#         post_id=request.form.get("post_id",None)

#         if post_id is None:
#             return res,400;
        
#         type=request.form.get("type",)

        
# Profile:
# 1. Username 2. First Name 3. Last Name 4. Gender 5. Bio
# 6. Friends 7. Posts 8. Profile Pic (To be added)
# 
# Posts: 
# 1. Content 2. Time of Creation 3. Likes 4. Comments 5.Owner 6. Description
#
# Comments:
# 1. Owner 2. Content 3. Created Time
#
# Feed - Get - get all posts, all posts of a user, Post - and make posts
#
# Interact - Get - get one post by creation time, Post - Increase decrease likes, and add comments
#http://127.0.0.1:5000/api/feed?username=parth&password=abcd&first_name=Parth&last_name=Dwivedi&gender=Male
#