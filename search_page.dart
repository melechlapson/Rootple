import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:heyther/datamodels/user.dart';
import 'package:heyther/views/home.dart';
import 'package:heyther/views/profile_page.dart';
import 'package:heyther/widgets/ProgressWidget.dart';
import 'package:heyther/services/Database.dart';
//import 'package:heyther/credentials.dart';
import 'package:heyther/views/conversation_screen.dart';



class SearchPage extends StatefulWidget {
  @override
  SearchPageState createState() => SearchPageState();
  
}



class SearchPageState extends State<SearchPage> with AutomaticKeepAliveClientMixin<SearchPage>{

  TextEditingController searchTextEditingController = TextEditingController();
  Future<QuerySnapshot> futureSearchResults;

  emptyTheTextFormField() {
    searchTextEditingController.clear();
  }


  controlSearching(String str) async {
    String input = str.toLowerCase();
    Future<QuerySnapshot> allUsers = userReference.where("displayname", isGreaterThanOrEqualTo: input).get();
    setState(() {
      futureSearchResults = allUsers;
    });

  }



  AppBar searchPageHeader() {
    return AppBar(
      backgroundColor: primaryColor,
      title: TextFormField(
        style: TextStyle(fontSize: 18.0, color: Colors.black),
        controller: searchTextEditingController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: "Search for users here...",
          hintStyle: TextStyle(color: Colors.black12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 0),
          prefixIcon: Icon(Icons.search, color: Colors.black, size: 30.0,),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear, color: Colors.black),
            onPressed: emptyTheTextFormField,
          )
        ),
        onFieldSubmitted: controlSearching,

      ),
    );
  }

  Container displayNoSearchResultScreen() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Icon(Icons.group, color: Colors.black, size: 200.0,),
            Text(
              "No Users Found",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 65.0),
            )
          ],
        ),
      )
    );
  }

  FutureBuilder displayUsersFoundScreen() {
    return FutureBuilder(
      future: futureSearchResults,
      builder: (context, dataSnapshot) {
        if(!dataSnapshot.hasData) {
          return circularProgress();
        }

        List<UserResult> searchUserResult = [];
        dataSnapshot.data.documents.forEach((document) {
          User eachUser = User.fromDocument(document);
          UserResult userResult = UserResult(eachUser: eachUser,);
          searchUserResult.add(userResult);
        });
        return ListView(children: searchUserResult,);
      },
    );
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: searchPageHeader(),
      body: futureSearchResults == null ? displayNoSearchResultScreen() : displayUsersFoundScreen(),
    );
  }
  
}

class UserResult extends StatelessWidget {
  final User eachUser;
  DatabaseMethods databaseMethods= new DatabaseMethods();
  UserResult({this.eachUser});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Container(
        color: Colors.white,
        child:
          Column(
            children: <Widget>[
              GestureDetector(
                  onTap: () =>
                      displayUserProfile(context, userProfileId: eachUser.id),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(eachUser.url),
                    ),
                    title: Text(
                      eachUser.displayname,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    subtitle: Text(
                      eachUser.username,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 13.0
                      ),
                    ),
                    trailing:
                        GestureDetector(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(30)
                            ),
                            padding: EdgeInsets.symmetric(horizontal:16, vertical: 16),
                            child:
                            Text("Message",
                              style: TextStyle(
                                  color:Colors.white
                              ),
                              textAlign: TextAlign.center,
                            ),

                        ),
                          onTap: () =>
                              createChatRoomAndStartConversation(context, eachUser.username),
                    )
                  )
              )
            ],
          )
      )
      );
  }

  createChatRoomAndStartConversation(BuildContext context,String username ){
    /*print('creating chatroom for ');
    print(currentUser.username);
    print(" and ");
    print(username);
*/
    String id= getChatroomID(username,currentUser.username);

    List<String> users= [currentUser.username,username];
    Map <String, dynamic> ChatroomMap={
      "users": users,
      "chatroomID": id,
    };
    print(users);
    databaseMethods.createChatRoom(id, ChatroomMap);
    Navigator.push(context, MaterialPageRoute(
        builder: (context)=>ConversationScreen(id, username)
      ));
  }

  displayUserProfile(BuildContext context, {String userProfileId}) {
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => ProfilePage(userProfileId: userProfileId,)));
  }

  getChatroomID(String a, String b){
    if(a.substring(0,1).codeUnitAt(0)>b.substring(0,1).codeUnitAt(0)){
      return "$b\_$a";
    } else{
      return "$a\_$b";
    }
  }


}
