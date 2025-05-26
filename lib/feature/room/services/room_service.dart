// lib/features/room/services/room_service.dart
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/providers/firebase_providers.dart';
import 'package:petverse/feature/pet/model/pet.dart';
import 'package:petverse/feature/room/model/message.dart';
import 'package:petverse/feature/room/model/room.dart';

class RoomService {
  final Ref _ref;
  late final FirebaseFirestore _firestore;
  late final FirebaseDatabase _realtimeDb;
  late final FirebaseAuth _auth;

  RoomService(this._ref) {
    _firestore = _ref.read(firebaseFirestoreProvider);
    _realtimeDb = _ref.read(firebaseDatabaseProvider);
    _auth = _ref.read(firebaseAuthProvider);
  }

  // Gerar código único para sala
  String _generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  // Criar nova sala
  Future<Room> createRoom() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    String code;
    bool codeExists = true;

    // Garantir código único
    do {
      code = _generateRoomCode();
      final existing = await _firestore
          .collection('rooms')
          .where('code', isEqualTo: code)
          .where('status', isEqualTo: 'waiting')
          .limit(1)
          .get();
      codeExists = existing.docs.isNotEmpty;
    } while (codeExists);

    // Criar sala no Firestore
    final roomData = {
      'code': code,
      'status': RoomStatus.waiting.name,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': user.uid,
      'parentIds': [user.uid],
      'petId': null,
      'matchedAt': null,
      'settings': {
        'notifications': true,
        'language': 'pt-BR',
      },
    };

    final roomRef = await _firestore.collection('rooms').add(roomData);

    // Criar entrada no Realtime Database para chat
    await _realtimeDb.ref('rooms/${roomRef.id}/info').set({
      'code': code,
      'createdAt': ServerValue.timestamp,
    });

    // Adicionar mensagem do sistema
    await _realtimeDb.ref('rooms/${roomRef.id}/messages').push().set({
      'text': 'Sala criada! Compartilhe o código: $code',
      'type': 'system',
      'timestamp': ServerValue.timestamp,
    });

    // Retornar room criada
    final roomDoc = await roomRef.get();
    return Room.fromFirestore(roomDoc);
  }

  // Entrar em sala existente
  Future<Room> joinRoom(String code) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    // Buscar sala pelo código
    final roomQuery = await _firestore
        .collection('rooms')
        .where('code', isEqualTo: code.toUpperCase())
        .where('status', isEqualTo: RoomStatus.waiting.name)
        .limit(1)
        .get();

    if (roomQuery.docs.isEmpty) {
      throw Exception('Código inválido ou sala não encontrada');
    }

    final roomDoc = roomQuery.docs.first;
    final room = Room.fromFirestore(roomDoc);

    // Verificar se usuário já está na sala
    if (room.parentIds.contains(user.uid)) {
      throw Exception('Você já está nesta sala');
    }

    // Verificar se sala está cheia
    if (room.isFull) {
      throw Exception('Sala já está cheia');
    }

    // Adicionar usuário à sala (transação para evitar condições de corrida)
    await _firestore.runTransaction((transaction) async {
      final freshRoomDoc = await transaction.get(roomDoc.reference);
      final freshRoom = Room.fromFirestore(freshRoomDoc);

      if (freshRoom.isFull) {
        throw Exception('Sala foi preenchida por outro usuário');
      }

      final updatedParents = [...freshRoom.parentIds, user.uid];
      final isNowFull = updatedParents.length >= 2;

      transaction.update(roomDoc.reference, {
        'parentIds': updatedParents,
        'status': isNowFull ? RoomStatus.active.name : RoomStatus.waiting.name,
        'matchedAt': isNowFull ? FieldValue.serverTimestamp() : null,
      });
    });

    // Adicionar mensagem do sistema no Realtime DB
    final userName = user.displayName ?? user.email?.split('@')[0] ?? 'Usuário';
    await _realtimeDb.ref('rooms/${roomDoc.id}/messages').push().set({
      'text': '$userName entrou na sala!',
      'type': 'system',
      'timestamp': ServerValue.timestamp,
    });

    // Se sala ficou cheia, notificar para criar pet
    final updatedRoom = await roomDoc.reference.get();
    final finalRoom = Room.fromFirestore(updatedRoom);

    if (finalRoom.isActive) {
      await _realtimeDb.ref('rooms/${roomDoc.id}/messages').push().set({
        'text': '🎉 Dupla formada! Vocês podem adotar um pet agora!',
        'type': 'system',
        'timestamp': ServerValue.timestamp,
      });
    }

    return finalRoom;
  }

  // Buscar sala ativa do usuário
  Future<Room?> getUserActiveRoom() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final roomQuery = await _firestore
        .collection('rooms')
        .where('parentIds', arrayContains: user.uid)
        .where('status',
            whereIn: [RoomStatus.waiting.name, RoomStatus.active.name])
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (roomQuery.docs.isEmpty) return null;
    return Room.fromFirestore(roomQuery.docs.first);
  }

  // Stream da sala
  Stream<Room?> streamRoom(String roomId) {
    return _firestore
        .collection('rooms')
        .doc(roomId)
        .snapshots()
        .map((doc) => doc.exists ? Room.fromFirestore(doc) : null);
  }

  // Stream de mensagens (Realtime Database)
  Stream<List<Message>> streamMessages(String roomId) {
    return _realtimeDb
        .ref('rooms/$roomId/messages')
        .orderByChild('timestamp')
        .limitToLast(50) // Limitar para economizar
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return [];

      final messages = <Message>[];
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      data.forEach((key, value) {
        final messageData = Map<String, dynamic>.from(value);
        messages.add(Message.fromRealtimeDB(key, messageData));
      });

      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return messages;
    });
  }

  // Enviar mensagem
  Future<void> sendMessage(String roomId, String text,
      {String type = 'text'}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    final userName = user.displayName ?? user.email?.split('@')[0] ?? 'Usuário';

    await _realtimeDb.ref('rooms/$roomId/messages').push().set({
      'senderId': user.uid,
      'senderName': userName,
      'text': text,
      'type': type,
      'timestamp': ServerValue.timestamp,
    });
  }

  // Enviar mensagem rápida
  Future<void> sendQuickMessage(
      String roomId, String emoji, String text) async {
    await sendMessage(roomId, '$emoji $text', type: 'quick');
  }

  // Sair da sala
  Future<void> leaveRoom(String roomId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    final batch = _firestore.batch();
    final roomRef = _firestore.collection('rooms').doc(roomId);

    // Atualizar sala
    batch.update(roomRef, {
      'parentIds': FieldValue.arrayRemove([user.uid]),
      'status': RoomStatus.ended.name,
    });

    // Mensagem de saída
    await _realtimeDb.ref('rooms/$roomId/messages').push().set({
      'text': '${user.displayName ?? 'Usuário'} saiu da sala',
      'type': 'system',
      'timestamp': ServerValue.timestamp,
    });

    await batch.commit();
  }

  // Criar pet para a sala
  Future<Pet> createPet(String roomId, String petName) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    // Verificar se sala está ativa e tem 2 parents
    final roomDoc = await _firestore.collection('rooms').doc(roomId).get();
    final room = Room.fromFirestore(roomDoc);

    if (!room.isActive || room.parentIds.length < 2) {
      throw Exception('Sala precisa ter 2 participantes');
    }

    // Criar pet
    final now = DateTime.now();
    final petData = {
      'name': petName,
      'roomId': roomId,
      'parentIds': room.parentIds,
      'hunger': 50,
      'happiness': 50,
      'cleanliness': 50,
      'lastFed': FieldValue.serverTimestamp(),
      'lastPlayed': FieldValue.serverTimestamp(),
      'lastCleaned': FieldValue.serverTimestamp(),
      'lastCaredBy': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'customization': {
        'color': 'default',
        'accessories': [],
      },
    };

    final petRef = await _firestore.collection('pets').add(petData);

    // Atualizar sala com ID do pet
    await roomDoc.reference.update({'petId': petRef.id});

    // Mensagem do sistema
    await _realtimeDb.ref('rooms/$roomId/messages').push().set({
      'text': '🎊 $petName nasceu! Cuidem bem dele!',
      'type': 'system',
      'timestamp': ServerValue.timestamp,
    });

    // Retornar pet criado
    final petDoc = await petRef.get();
    return Pet.fromFirestore(petDoc);
  }
}
