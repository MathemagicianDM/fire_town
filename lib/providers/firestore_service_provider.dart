import 'package:riverpod/riverpod.dart';
import '../services/firestore_service.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});