import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods{


  createChatRoom(String chatroomID, chatroomMap){
    FirebaseFirestore.instance.collection("chatrooms").doc(chatroomID).set(chatroomMap)
        .catchError((e){
      print(e.toString());
    });
  }

  getMessages(String chatroomid)async{
    return await FirebaseFirestore.instance.collection("chatrooms").doc(chatroomid).collection('chats')
        .orderBy("timestamp", descending: false).snapshots();

  }

  getChatrooms(String username)async{
    return await FirebaseFirestore.instance.collection("chatrooms").where("users", arrayContains: username).snapshots();
  }

  addMessage(String chatroomid, MessageMap){
    FirebaseFirestore.instance.collection("chatrooms").doc(chatroomid).collection('chats').add(MessageMap)
        .catchError((e){
       print(e.toString());
    });    
  }
  
  deleteMessage(int timestamp, String chatroomid )async{
    await FirebaseFirestore.instance.collection("chatrooms").doc(chatroomid).collection('chats')
        .where("timestamp", isEqualTo: timestamp).get().then((snapshot){
                print("deleting message");
                snapshot.docs.forEach((element) {
                  element.reference.delete();
                  print('message deleted');
                });
          });
  }
}
