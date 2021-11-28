class UserModel {
  String username;
  String profilePicture;
  String bio;
  String id;
  List<String> posts;
  List<String> friends;
  String firstName;
  String lastName;
  String gender;

  UserModel(
      {this.username,
      this.id,
      this.bio,
      this.firstName,
      this.lastName,
      this.friends,
      this.gender,
      this.posts,
      this.profilePicture});

  UserModel.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    gender = json['gender'];
    profilePicture = json['profile_picture'];
    bio = json['bio'];
    id = json['_id'];
    friends = json['friends'];
    posts = json['posts'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['username'] = this.username;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['gender'] = this.gender;
    data['profile_picture'] = this.profilePicture;
    data['bio'] = this.bio;
    data['_id'] = this.id;
    data['friends'] = this.friends;
    data['posts'] = this.posts;

    return data;
  }
}
