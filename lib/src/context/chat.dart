import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:livekit_client/livekit_client.dart';

// topic: lk-chat-topic
class ChatMessage {
  final String message;
  final int timestamp;
  final String id;
  final bool sender;

  final Participant? participant;

  ChatMessage({
    required this.message,
    required this.timestamp,
    required this.id,
    this.participant,
    required this.sender,
  });

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'timestamp': timestamp,
      'id': id,
    };
  }

  String toJson() => const JsonEncoder().convert(toMap());

  factory ChatMessage.fromJsonString(String source, Participant? participant) =>
      ChatMessage.fromMap(const JsonDecoder().convert(source), participant);

  factory ChatMessage.fromMap(
      Map<String, dynamic> map, Participant? participant) {
    return ChatMessage(
      message: map['message'],
      timestamp: map['timestamp'],
      id: map['id'],
      participant: participant,
      sender: false,
    );
  }
}

mixin ChatContextMixin on ChangeNotifier {
  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;
  LocalParticipant? _localParticipant;
  EventsListener<RoomEvent>? _listener;

  void chatContextSetup(
      EventsListener<RoomEvent>? listener, LocalParticipant? localParticipant) {
    _listener = listener;
    _localParticipant = localParticipant;
    if (listener != null) {
      _listener!.on<DataReceivedEvent>((event) {
        if (event.topic == 'lk-chat-topic') {
          addMessageFromMap(
              const Utf8Decoder().convert(event.data), event.participant);
        }
      });
    } else {
      _listener = null;
      _messages.clear();
    }
  }

  void sendMessage(String message) {
    final msg = ChatMessage(
      message: message,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: true,
    );
    addMessage(msg);
    _localParticipant?.publishData(const Utf8Encoder().convert(msg.toJson()),
        topic: 'lk-chat-topic');
  }

  void addMessage(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }

  void addMessageFromMap(String buf, Participant? participant) {
    final message = ChatMessage.fromJsonString(buf, participant);
    addMessage(message);
  }
}