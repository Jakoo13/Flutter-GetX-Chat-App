// ignore_for_file: avoid_print

import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_chat/chat/MessageModel.dart';

import '../auth/UserModel.dart';

class ChatController extends GetxController with StateMixin {
  final users = [].obs;

  //Get Current UserModel
  var currentUserEmail = FirebaseAuth.instance.currentUser!.email;

  var sendMessageTo = ''.obs;

  @override
  void onInit() async {
    users.bindStream(lista());
    super.onInit();
  }

  @override
  void onReady() {
    // messageList.bindStream(messageStream());
  }

//////Get All Messages For Particular Chat ///////////////
  Rx<List<MessageModel>> messageList = Rx<List<MessageModel>>([]);
  List<MessageModel> get messages => messageList.value;

  Stream<List<MessageModel>> messageStream(currUser, sentTo) {
    print("The Current User Email: $currUser");
    return FirebaseFirestore.instance
        .collection('messages')
        .doc(sortAlphabetically(currUser, sentTo))
        .collection('chats')
        .orderBy('timeStamp', descending: false)
        .snapshots()
        .map((QuerySnapshot query) {
      print("Query Docs: ${query.docs}");
      List<MessageModel> messages = [];
      for (var message in query.docs) {
        final messageModel =
            MessageModel.fromDocumentSnapshot(documentSnapshot: message);
        messages.add(messageModel);
      }
      print("Messages: $messages");
      return messages;
    });
  }

///////////// Sending Messages //////////////////////////////////
  final messageController = TextEditingController();
  void sendMessage(sentFrom, sentTo) async {
    await FirebaseFirestore.instance
        .collection('messages/${sortAlphabetically(sentFrom, sentTo)}/chats')
        .doc()
        .set(
      {
        'content': messageController.text,
        'from': sentFrom,
        'to': sentTo,
        'timeStamp': Timestamp.now(),
        'read': false
      },
    );
  }

  String sortAlphabetically(sf, st) {
    final sortedSet = SplayTreeSet.from(
      {"$sf", "$st"},
    );
    print("From SortAlpahbetically Function: ${sortedSet.join()}");
    return sortedSet.join();
  }

  /////////Get List of All Users////////////////
  Stream<List<dynamic>> lista() {
    final usersSnapshot =
        FirebaseFirestore.instance.collection('users').snapshots();
    var changeThis = usersSnapshot.map((qShot) => qShot.docs
        .map(
          (doc) => UserModel(
            firstName: doc['firstName'],
            lastName: doc['lastName'],
            email: doc['email'],
          ),
        )
        .toList());
    change(changeThis, status: RxStatus.success());
    return changeThis;
  }
}
