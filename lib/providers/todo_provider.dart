import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/todo.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

// This will be generated via build_runner
part 'todo_provider.g.dart';

// Provider for the FirestoreService
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Todo filter enum - defined before the provider to avoid conflict
enum TodoFilterOption {
  all,
  completed,
  active,
}

// Provider for the todo list stream
@riverpod
Stream<List<Todo>> todoList(ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getTodos();
}

// Provider for filtered todos
@riverpod
class FilteredTodos extends _$FilteredTodos {
  @override
  List<Todo> build() {
    final AsyncValue<List<Todo>> todos = ref.watch(todoListProvider);
    final TodoFilterOption filter = ref.watch(todoFilterProvider);
    
    return todos.when(
      data: (data) {
        switch (filter) {
          case TodoFilterOption.all:
            return data;
          case TodoFilterOption.completed:
            return data.where((todo) => todo.isCompleted).toList();
          case TodoFilterOption.active:
            return data.where((todo) => !todo.isCompleted).toList();
        }
      },
      loading: () => [],
      error: (_, __) => [],
    );
  }
}

// Provider for the current filter
@riverpod
class TodoFilter extends _$TodoFilter {
  @override
  TodoFilterOption build() => TodoFilterOption.all;
  
  void setFilter(TodoFilterOption filter) {
    state = filter;
  }
}

// Provider for todo actions
@riverpod
class TodoActions extends _$TodoActions {
  @override
  void build() {}

  Future<void> addTodo(String title) async {
    if (title.isEmpty) return;
    
    final firestoreService = ref.read(firestoreServiceProvider);
    await firestoreService.addTodo(title);
  }

  Future<void> toggleTodo(String id, bool currentStatus) async {
    final firestoreService = ref.read(firestoreServiceProvider);
    await firestoreService.toggleTodoStatus(id, currentStatus);
  }

  Future<void> deleteTodo(String id) async {
    final firestoreService = ref.read(firestoreServiceProvider);
    await firestoreService.deleteTodo(id);
  }
}

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Auth state provider
@riverpod
Stream<User?> authState(ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
}