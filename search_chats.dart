import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:heyther/datamodels/user.dart';
import 'package:heyther/views/home.dart';
import 'package:heyther/views/profile_page.dart';
import 'package:heyther/widgets/ProgressWidget.dart';
//import 'package:heyther/credentials.dart';



class ChatSearchPage extends StatefulWidget {
  @override
  ChatSearchPageState createState() => ChatSearchPageState();

}



class ChatSearchPageState extends State<ChatSearchPage> with AutomaticKeepAliveClientMixin<ChatSearchPage>{

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
            prefixIcon: IconButton(
              icon:Icon( Icons.search, color: Colors.black, size: 30.0),
              onPressed: controlSearching(searchTextEditingController.text),
            ),
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

  UserResult({this.eachUser});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            GestureDetector(
                onTap: () =>
                    displayUserProfile(context, userProfileId: eachUser.id),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: CachedNetworkImageProvider(eachUser.url),
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
                )
            )
          ],
        ),
      ),
    );
  }

  displayUserProfile(BuildContext context, {String userProfileId}) {
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => ProfilePage(userProfileId: userProfileId,)));
  }
}


/*
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:heyther/widgets/header_widget.dart';
import 'package:heyther/datamodels/user.dart';
import 'package:heyther/views/home.dart';
import 'package:heyther/views/profile_page.dart';
import 'package:heyther/widgets/ProgressWidget.dart';
import 'package:heyther/services/Database.dart';


class ChatSearch extends StatefulWidget{
  @override
  _ChatSearchState createState() => _ChatSearchState();
}

class _ChatSearchState extends State<ChatSearch>{

  DatabaseMethods databaseMethods= new DatabaseMethods();
  TextEditingController searchTextEditingController= new TextEditingController();
  Future<QuerySnapshot> futureSearchResults;

  controlSearching(String str) async {
    print('started search');
    String input = str.toLowerCase();
    Future<QuerySnapshot> allUsers = userReference.where("displayname", isGreaterThanOrEqualTo: input).get();
    print('finished search');
    setState(() {
      futureSearchResults = allUsers;
    });
    print("state set");
  }

  emptyTheTextFormField() {
    searchTextEditingController.clear();
  }

  //initiateSearch(){
  //  databaseMethods.getUserByUsername(searchTextEditingController.text).then((value) {
  //    print(value.toString());
  //    setState(() {
  //      searchSnapshot = value;
  //    });
  //  });
  //}



  Widget searchList(){
    return futureSearchResults!=null ? FutureBuilder(
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
    )
    : Flexible(
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

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
      appBar: header(context,strTitle: "Search in Chats", isAppTitle: false),
      body: Container(
        child: Column(
          children:[
            //filled: true,
            Container(
              color: Colors.grey,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                        controller: searchTextEditingController,
                        autofocus: true,
                        decoration: InputDecoration(
                          //fillColor: Colors.grey,
                          //hoverColor: Colors.lightBlueAccent,
                            hintText: "Search username",
                            hintStyle: TextStyle(
                                color: Colors.black,
                                textBaseline: TextBaseline.alphabetic
                            ),
                            border: InputBorder.none
                        ),
                      )
                  ),
                  GestureDetector(
                        child:
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    const Color(0x36FFFFFF),
                                    const Color(0x0FFFFFFF)
                                  ]
                              ),
                          ),
                          padding: EdgeInsets.all(8),
                          child:
                          Icon(Icons.clear, color: Colors.black),
                        ),
                        onTap: () {
                          emptyTheTextFormField();
                        },
                      ),
                  SizedBox(width:20),
                  GestureDetector(
                      onTap: (){
                        controlSearching(searchTextEditingController.text);
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  const Color(0x36FFFFFF),
                                  const Color(0x0FFFFFFF)
                                ]
                            ),
                            borderRadius: BorderRadius.circular(40)
                        ),
                        padding: EdgeInsets.all(8),
                        child:Icon(Icons.search_sharp),
                      )
                  )
                ],
              ),
            ),
            searchList()
          ]
        )

      ),
   );
  }
}


class UserResult extends StatelessWidget {
  final User eachUser;

  UserResult({this.eachUser});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Container(
        color: Colors.white,
        child:
        Row(
          children: [
            ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: CachedNetworkImageProvider(eachUser.url),
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
                 ),
            GestureDetector(
                child:
                  Text("Message"),
                onTap: () =>
                 createChatRoomAndStartConversation(context, userProfileId: eachUser.id),
            )
          ]
        )
        ),
    );
  }
  createChatRoomAndStartConversation(BuildContext context,{String userProfileId} ){
    //List<String> users= [username,];
    //databaseMethods.createChatRoom(id ,users);
  }
}
*/