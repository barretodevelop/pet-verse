// FirestoreService
// lib/services/firestore_service.dart - FirestoreService
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petverse/models/inventory_user_item_model.dart';
import 'package:petverse/models/item_model.dart';

import '../models/chat_message_model.dart';
import '../models/feed_post_model.dart';
import '../models/mission_model.dart';
import '../models/pet_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  // User operations
  Future<UserModel?> getUser(String uid) async {
    try {
      print(
          'ℹ️ [FirestoreService.getUser] Attempting to get user with UID: $uid');
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        print('✅ [FirestoreService.getUser] User found: $uid');
        return UserModel.fromJson(doc.data()!);
      } else {
        print('⚠️ [FirestoreService.getUser] User not found: $uid');
        return null;
      }
    } catch (e) {
      print('❌ [FirestoreService.getUser] Error getting user $uid: $e');
      return null;
    }
  }

  Future<void> createUser(UserModel user) async {
    try {
      print(
          'ℹ️ [FirestoreService.createUser] Attempting to create user: ${user.id} - ${user.username}');
      await _db.collection('users').doc(user.id).set(user.toJson());
      print(
          '✅ [FirestoreService.createUser] User created successfully: ${user.id}');
    } catch (e) {
      print(
          '❌ [FirestoreService.createUser] Error creating user ${user.id}: $e');
      rethrow;
    }
  }

  // ✅ CORREÇÃO: Modificado para aceitar userId e um Map para atualizações parciais
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      print(
          'ℹ️ [FirestoreService.updateUser] Attempting to update user: $userId with data: $data');
      await _db.collection('users').doc(userId).update(data);
      print(
          '✅ [FirestoreService.updateUser] User updated successfully: $userId');
    } catch (e) {
      print(
          '❌ [FirestoreService.updateUser] Error updating user $userId with data $data: $e');
      rethrow; // Re-lança o erro para ser tratado pelo chamador
    }
  }

  // Pet operations
  Stream<List<PetModel>> getUserPets(String userId) {
    print(
        'ℹ️ [FirestoreService.getUserPets] Setting up stream for user pets: $userId');
    return _db
        .collection('pets')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      print(
          '🔄 [FirestoreService.getUserPets] Pets data received for user $userId, count: ${snapshot.docs.length}');
      return snapshot.docs.map((doc) => PetModel.fromJson(doc.data())).toList();
    }).handleError((error) {
      print(
          '❌ [FirestoreService.getUserPets] Error in pets stream for user $userId: $error');
      return <PetModel>[];
    });
  }

  Future<void> createPet(PetModel pet) async {
    try {
      print(
          'ℹ️ [FirestoreService.createPet] Attempting to create pet: ${pet.id} - ${pet.name}');
      await _db.collection('pets').doc(pet.id).set(pet.toJson());
      print(
          '✅ [FirestoreService.createPet] Pet created successfully: ${pet.id}');
    } catch (e) {
      print('❌ [FirestoreService.createPet] Error creating pet ${pet.id}: $e');
      rethrow;
    }
  }

  Future<void> updatePet(PetModel pet) async {
    try {
      print(
          'ℹ️ [FirestoreService.updatePet] Attempting to update pet: ${pet.id} - ${pet.name}');
      await _db.collection('pets').doc(pet.id).update(pet.toJson());
      print(
          '✅ [FirestoreService.updatePet] Pet updated successfully: ${pet.id}');
    } catch (e) {
      print('❌ [FirestoreService.updatePet] Error updating pet ${pet.id}: $e');
      rethrow;
    }
  }

  Future<void> deletePet(String petId) async {
    try {
      print('ℹ️ [FirestoreService.deletePet] Attempting to delete pet: $petId');
      await _db.collection('pets').doc(petId).delete();
      print('✅ [FirestoreService.deletePet] Pet deleted successfully: $petId');
    } catch (e) {
      print('❌ [FirestoreService.deletePet] Error deleting pet $petId: $e');
      rethrow;
    }
  }

  // Feed operations
  Stream<List<FeedPostModel>> getFeedPosts() {
    print(
        'ℹ️ [FirestoreService.getFeedPosts] Setting up stream for feed posts.');
    return _db
        .collection('feed')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedPostModel.fromJson(doc.data()))
            .toList())
        .handleError((error) {
      print(
          '❌ [FirestoreService.getFeedPosts] Error in feed posts stream: $error');
      return <FeedPostModel>[];
    });
  }

  Future<void> addFeedPost(FeedPostModel post) async {
    try {
      print(
          'ℹ️ [FirestoreService.addFeedPost] Attempting to add feed post: ${post.id}');
      await _db.collection('feed').doc(post.id).set(post.toJson());
      print(
          '✅ [FirestoreService.addFeedPost] Feed post added successfully: ${post.id}');
    } catch (e) {
      print(
          '❌ [FirestoreService.addFeedPost] Error adding feed post ${post.id}: $e');
      rethrow;
    }
  }

  // Chat operations
  Stream<List<ChatMessageModel>> getChatMessages(String petId) {
    print(
        'ℹ️ [FirestoreService.getChatMessages] Setting up stream for chat messages for pet: $petId');
    return _db
        .collection('chats')
        .where('petId', isEqualTo: petId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessageModel.fromJson(doc.data()))
            .toList())
        .handleError((error) {
      print(
          '❌ [FirestoreService.getChatMessages] Error in chat messages stream for pet $petId: $error');
      return <ChatMessageModel>[];
    });
  }

  Future<void> sendChatMessage(ChatMessageModel message) async {
    try {
      print(
          'ℹ️ [FirestoreService.sendChatMessage] Attempting to send chat message: ${message.id}');
      await _db.collection('chats').doc(message.id).set(message.toJson());
      print(
          '✅ [FirestoreService.sendChatMessage] Chat message sent successfully: ${message.id}');
    } catch (e) {
      print(
          '❌ [FirestoreService.sendChatMessage] Error sending chat message ${message.id}: $e');
      rethrow;
    }
  }

  // Mission operations
  Future<List<MissionModel>> getUserMissions(String userId) async {
    try {
      print(
          'ℹ️ [FirestoreService.getUserMissions] Attempting to get missions for user: $userId');
      final snapshot = await _db
          .collection('user_missions')
          .where('userId', isEqualTo: userId)
          .get();
      final missions = snapshot.docs
          .map((doc) => MissionModel.fromJson(doc.data()))
          .toList();
      print(
          '✅ [FirestoreService.getUserMissions] Missions fetched for user $userId, count: ${missions.length}');
      return missions;
    } catch (e) {
      print(
          '❌ [FirestoreService.getUserMissions] Error getting missions for user $userId: $e');
      return [];
    }
  }

  Future<void> updateMission(String userId, MissionModel mission) async {
    final missionDocId = '${userId}_${mission.id}';
    try {
      print(
          'ℹ️ [FirestoreService.updateMission] Attempting to update mission: $missionDocId for user: $userId');
      await _db
          .collection('user_missions')
          .doc(missionDocId)
          .set({...mission.toJson(), 'userId': userId});
      print(
          '✅ [FirestoreService.updateMission] Mission updated successfully: $missionDocId');
    } catch (e) {
      print(
          '❌ [FirestoreService.updateMission] Error updating mission $missionDocId: $e');
      rethrow;
    }
  }

  // Inventory operations (as a subcollection under 'users')
  Future<void> addUserInventoryItem(String userId, ItemModel item,
      {int quantity = 1}) async {
    try {
      print(
          'ℹ️ [FirestoreService.addUserInventoryItem] Attempting to add item ${item.id} to inventory for user: $userId');

      final inventoryCollection =
          _db.collection('users').doc(userId).collection('inventory');

      // Query for existing item
      final querySnapshot = await inventoryCollection
          .where('itemId', isEqualTo: item.id)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Item exists, update quantity
        final doc = querySnapshot.docs.first;
        final currentQuantity = doc.data()['quantity'] as int? ?? 0;
        await doc.reference.update({'quantity': currentQuantity + quantity});
        print(
            '✅ [FirestoreService.addUserInventoryItem] Updated quantity for item ${item.id} to ${currentQuantity + quantity} for user $userId');
      } else {
        // Item does not exist, add new document
        await inventoryCollection.add({
          'itemId': item.id, // Store the ID of the base item
          'quantity': quantity,
          'acquiredAt': DateTime.now().millisecondsSinceEpoch,
        });
        print(
            '✅ [FirestoreService.addUserInventoryItem] Added new item ${item.id} (qty: $quantity) for user $userId');
      }
    } catch (e) {
      print(
          '❌ [FirestoreService.addUserInventoryItem] Error adding/updating item ${item.id} for user $userId: $e');
      rethrow;
    }
  }

  Future<void> removeUserInventoryItem(String userId, String inventoryDocId,
      {int quantityToRemove = 1}) async {
    try {
      print(
          'ℹ️ [FirestoreService.removeUserInventoryItem] Attempting to remove $quantityToRemove of inventory item: $inventoryDocId for user: $userId');
      final docRef = _db
          .collection('users')
          .doc(userId)
          .collection('inventory')
          .doc(inventoryDocId);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final currentQuantity = docSnapshot.data()?['quantity'] as int? ?? 0;
        if (currentQuantity > quantityToRemove) {
          await docRef.update({'quantity': currentQuantity - quantityToRemove});
          print(
              '✅ [FirestoreService.removeUserInventoryItem] Decremented quantity for $inventoryDocId to ${currentQuantity - quantityToRemove}');
        } else {
          await docRef.delete();
          print(
              '✅ [FirestoreService.removeUserInventoryItem] Removed item document $inventoryDocId as quantity reached zero or less.');
        }
      } else {
        print(
            '⚠️ [FirestoreService.removeUserInventoryItem] Item document $inventoryDocId not found for removal.');
      }
    } catch (e) {
      print(
          '❌ [FirestoreService.removeUserInventoryItem] Error removing user inventory item $inventoryDocId for user $userId: $e');
      rethrow;
    }
  }

  Stream<List<InventoryUserItem>> getUserInventory(String userId) {
    print(
        'ℹ️ [FirestoreService.getUserInventory] Setting up stream for user inventory: $userId');
    return _db
        .collection('users')
        .doc(userId)
        .collection('inventory')
        .orderBy('acquiredAt', descending: true) // Optional: order items
        .snapshots()
        .map((snapshot) {
      print(
          '🔄 [FirestoreService.getUserInventory] Inventory data received for user $userId, count: ${snapshot.docs.length}');
      return snapshot.docs
          .map((doc) => InventoryUserItem.fromJson(doc.id, doc.data()))
          .toList();
    }).handleError((error) {
      print(
          '❌ [FirestoreService.getUserInventory] Error in user inventory stream for $userId: $error');
      return <InventoryUserItem>[];
    });
  }
}
