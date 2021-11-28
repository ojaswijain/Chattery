# Chattery_backend

# Endpoints
- POST `/api/auth` 
    - username, password, type 
    - If type is "register", first_name, last_name, profile_picture, gender also required. Creates a profile and returns its details
    - If type is "login", returns details of existing profile

- GET `api/feed` 
    - username (optional)
    - If username not present, returns all posts
    - Else returns all posts of the friends of the given user, with recentmost post first

- POST `api/feed`
    - username, content, decription
    - Creates a post by the given user with the given content

- GET `api/interact`
    - post_id
    - Returns post created at given time

- POST `api/interact`
    - post_id, type
    - If type is "inc", liker is required
    - If type is "dec", unliker is required
    - If type is "comment, owner_comment, content_comment also required, and comment is added to given post.

- POST `api/edit`
    - username (Required)
    - password, first_name, last_name, profile_picture, bio, gender, add_friend, delete_friend (all optional) 
    - Whichever parameters are given shall be updated, add_friend and delete_friend will friend and unfriend from both users

- POST `api/editpost`
    - post_id (Required)
    - password, first_name, last_name, profile_picture, bio, gender, add_friend, delete_friend (all optional) 
    - Whichever parameters are given shall be updated, add_friend and delete_friend will friend and unfriend from both users

- GET `/api/health` Returns the expiry time

# Tables
- **post:** Stores the details of a post
```
{
    "owner": <username>,
    "content": <content>,
    "description": <description>,
    "likes": <array of users who liked>,
    "comments": <array of comments>
    "created_time": <created_time>
}
```

- **profile:** Stores details of all the people
```
{
    "username": <username>,
    "password": <password>,
    "profile_picture": <Bindata String>,
    "first_name": <first_name>,
    "last_name": <last_name>,
    "bio": <bio>,
    "gender": <gender>,
    "friends": <array of usernames>,
    "posts": <array of posts>
}
```

- **comment:** Stores details of comments (Not created as a separate collection)
```
{
    "owner": <owner>,
    "content": <content>,
    "created_time": <created_time>,
    "likes": <array of users who liked>
}
```


# Installation instructions

- Install MongoDB using [these](https://docs.mongodb.com/manual/installation/) instructions
- Create a virtual environment using the following commands

```
python3 -m venv env
source env/bin/activate
```

- Install the requirements using the command  `pip install -r requirements.txt`

# Authentication details

- Upon successful login, a JSON response will be returned with HTTP status code 200 having the following structure:
```
{
    "success": true,
    "message": "token generated",
    "token": <token string>
}
```

- However, if the login fails, the `success` field will be set to `false` and the `message` field will contain the description of the issue.

- Attach the received token in the `x-access-token` header of all the subsequent requests for authentication. In the absence of this token, the requests will not be entertained.

# References
- [PyMongo](https://pymongo.readthedocs.io/en/stable/index.html)
- [Flask RESTful](https://flask-restful.readthedocs.io/en/latest/)
