import 'package:flutter/material.dart';
import 'package:heyther/views/home.dart';
import 'package:heyther/services/Database.dart';
import 'package:heyther/widgets/header_widget.dart';

class ConversationScreen extends StatefulWidget{

  final String chatroomID;
  final String chatUser;
  ConversationScreen(this.chatroomID, this.chatUser);

  @override
  ConversationScreenState createState()=> ConversationScreenState();
}

class ConversationScreenState extends State<ConversationScreen>{
  DatabaseMethods databaseMethods= new DatabaseMethods();
  TextEditingController MessageController= new TextEditingController();
  Stream ChatMessageStream;

  @override
  void initState(){
    databaseMethods.getMessages(widget.chatroomID).then((value){
      setState(() {
        ChatMessageStream = value;
      });
    });
    super.initState();
  }

  sendMessage(String message){
    Map<String, dynamic> MessageMap={
      "Content": message,
      "sender": currentUser.username,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    };
    databaseMethods.addMessage(widget.chatroomID, MessageMap);
    MessageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, strTitle: "Chat with ${widget.chatUser}", isAppTitle: false),
      body:Container(
        color: Colors.black,
        child:Stack(
          children:[
            ChatMessageList(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(125,125,125,.5),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child:
                  Row(
                      children:[
                        Expanded(
                          child: TextField(
                            controller: MessageController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Message Content",
                              hintStyle: TextStyle(color: Colors.white54),
                              border: InputBorder.none
                            )
                          )
                        ),
                        GestureDetector(
                          onTap: (){
                            print("message sent");
                            sendMessage(MessageController.text);
                            //MessageController.clear();
                          },
                          child: Container(
                            height: 40,
                            width: 40,
                            padding: EdgeInsets.all(12),
                            alignment: Alignment.center,
                            child: Icon(Icons.send)
                          ),
                        ),
                    ]
                  ),
                )
              )
              ]
            ),

        )
      );



  }



  Widget ChatMessageList(){
      return StreamBuilder(
        stream: ChatMessageStream,
        builder: (context,snapshot){
          return snapshot.hasData ? ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context,index){
              print((snapshot.data.docs[index].data()["timestamp"].toString()));
               return MessageTile(snapshot.data.docs[index].data()["Content"],
                   snapshot.data.docs[index].data()["sender"]==currentUser.username,
                   int.parse(snapshot.data.docs[index].data()["timestamp"].toString()),
                   widget.chatroomID
               );
            }
            ):
          Container();
          }

      );
  }
}

class MessageTile extends StatelessWidget{
  final String message;
  MessageTile(this.message, this.isSender, this.timestamp, this.chatroomid);
  final bool isSender;
  final int timestamp;
  final String chatroomid;

  DatabaseMethods databaseMethods= new DatabaseMethods();

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: ()=> isSender? databaseMethods.deleteMessage(timestamp,chatroomid): print("cannot delete other user's messages"),
      child: Container(
      margin:EdgeInsets.symmetric(vertical:4,horizontal:16),
      width: MediaQuery.of(context).size.width,
      alignment: isSender? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical:24,horizontal:24),
        decoration: BoxDecoration(
          color: isSender? Colors.blue : Colors.grey,
          borderRadius: isSender? BorderRadius.only(topLeft:Radius.circular(23),topRight: Radius.circular(23),bottomLeft: Radius.circular(23))
              :BorderRadius.only(topLeft:Radius.circular(23),topRight: Radius.circular(23),bottomRight: Radius.circular(23))
        ),
        child: Text(
          message,
            style: TextStyle(color: Colors.white, fontSize: 16,),
         )
     )
    )
    );
  }
}