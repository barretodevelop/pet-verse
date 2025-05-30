import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/backup/room/model/message.dart';
import 'package:petverse/backup/room/model/room.dart';
import 'package:petverse/backup/room/services/room_service.dart';

// Provider do serviço
final roomServiceProvider = Provider<RoomService>((ref) {
  return RoomService(ref);
});

// StateNotifier para gerenciar o estado da sala
class RoomController extends StateNotifier<AsyncValue<Room?>> {
  final RoomService _service;

  RoomController(this._service) : super(const AsyncLoading()) {
    loadUserRoom();
  }

  Future<void> loadUserRoom() async {
    try {
      final room = await _service.getUserActiveRoom();
      state = AsyncData(room);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> createRoom() async {
    state = const AsyncLoading();
    try {
      final room = await _service.createRoom();
      state = AsyncData(room);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> joinRoom(String code) async {
    state = const AsyncLoading();
    try {
      final room = await _service.joinRoom(code);
      state = AsyncData(room);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> leaveRoom() async {
    final currentRoom = state.valueOrNull;
    if (currentRoom == null) return;

    state = const AsyncLoading();
    try {
      await _service.leaveRoom(currentRoom.id);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() async {
    await loadUserRoom();
  }
}

// Provider principal da sala
final roomControllerProvider =
    StateNotifierProvider<RoomController, AsyncValue<Room?>>((ref) {
  final service = ref.watch(roomServiceProvider);
  return RoomController(service);
});

// Provider para stream da sala específica
final roomStreamProvider = StreamProvider.family<Room?, String>((ref, roomId) {
  final service = ref.watch(roomServiceProvider);
  return service.streamRoom(roomId);
});

// Provider para mensagens de uma sala específica
final roomMessagesProvider =
    StreamProvider.family<List<Message>, String>((ref, roomId) {
  final service = ref.watch(roomServiceProvider);
  return service.streamMessages(roomId);
});
