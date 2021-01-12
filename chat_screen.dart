import 'package:flutter/material.dart';
import 'package:heyther/views/conversation_screen.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:heyther/widgets/chat_widget.dart';
import 'package:heyther/widgets/header_widget.dart';
import 'package:heyther/views/home.dart';
import 'package:heyther/views/search_page.dart';
import 'package:heyther/services/Database.dart';
//import 'package:timeago/timeago.dart' as tAgo;
//import 'package:heyther/widgets/posts_widget.dart';

class ChatRoom extends StatefulWidget{
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom>{

  DatabaseMethods databaseMethods= new DatabaseMethods();
  Stream chatRoomsStream;

   Widget chatroomList(){
    return StreamBuilder(
      stream: chatRoomsStream,
        builder: (context,snapshot){
          return snapshot.hasData ? ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context,index){
                //print(snapshot.data.docs[index].data()["chatroomID"]);
                return ChatTile(
                    snapshot.data.docs[index].data()["chatroomID"].toString().replaceAll("_${currentUser.username}", "")
                        .replaceAll("${currentUser.username}_",""),
                    snapshot.data.docs[index].data()["chatroomID"].toString()
                );
              }
          ):
          Container();
        }
    );
}

  @override
  void initState(){
    databaseMethods.getChatrooms(currentUser.username).then((value){
      setState((){
        chatRoomsStream=value;
      });
    });
    super.initState();
  }


  displaySearchPage() {
    Navigator.push(context, MaterialPageRoute(builder: (context)=>SearchPage()
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, strTitle: "Chats", isAppTitle: false),
      body: Container(
        color:Colors.grey,
        child:chatroomList()
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child:
        FloatingActionButton(
          heroTag: "btn1",
          child: Icon(Icons.search),
          onPressed: ()=>displaySearchPage()
          /*{
            Navigator.push(context, MaterialPageRoute(
                builder: (context)=> ChatSearchPage()
            ));
          }*/,
        ),
      )
    );
  }
}

class ChatTile extends StatelessWidget{

  final String username;
  final String chatroomid;
  ChatTile(this.username, this.chatroomid);

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(
          builder: (context)=> ConversationScreen(chatroomid, username)
        ));
      },
      child: Container(
          margin: EdgeInsets.symmetric(vertical:1),
          padding: EdgeInsets.symmetric(horizontal:24, vertical:16 ),
          color: Colors.black26,
          child: Row(
              children:[
                Container(
                    alignment: Alignment.center,
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(40)
                    ),
                    child:
                    Text("${username.substring(0,1).toUpperCase()}", style:TextStyle(color:Colors.white))
                ),
                SizedBox(width: 8),
                Text(username, style: TextStyle(color: Colors.white, fontSize: 16))
              ]
          )
      )
    );

  }
}