// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$todoListHash() => r'ed12db3c4697a350d02ed9fd8ecc1cb56fcf9941';

/// See also [todoList].
@ProviderFor(todoList)
final todoListProvider = AutoDisposeStreamProvider<List<Todo>>.internal(
  todoList,
  name: r'todoListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$todoListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodoListRef = AutoDisposeStreamProviderRef<List<Todo>>;
String _$authStateHash() => r'0d6b8b3380a1cdb4583b13693b7768b7192f89a0';

/// See also [authState].
@ProviderFor(authState)
final authStateProvider = AutoDisposeStreamProvider<User?>.internal(
  authState,
  name: r'authStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthStateRef = AutoDisposeStreamProviderRef<User?>;
String _$filteredTodosHash() => r'2c29ea9dc60b14e9356252d769c6fc8bf5d0ed37';

/// See also [FilteredTodos].
@ProviderFor(FilteredTodos)
final filteredTodosProvider =
    AutoDisposeNotifierProvider<FilteredTodos, List<Todo>>.internal(
      FilteredTodos.new,
      name: r'filteredTodosProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$filteredTodosHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FilteredTodos = AutoDisposeNotifier<List<Todo>>;
String _$todoFilterHash() => r'4104a78f9444c194764d9a030c4fa7af6ad5e3dd';

/// See also [TodoFilter].
@ProviderFor(TodoFilter)
final todoFilterProvider =
    AutoDisposeNotifierProvider<TodoFilter, TodoFilterOption>.internal(
      TodoFilter.new,
      name: r'todoFilterProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$todoFilterHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TodoFilter = AutoDisposeNotifier<TodoFilterOption>;
String _$todoActionsHash() => r'279dfe5d097d38e6814890454d15c5a162822816';

/// See also [TodoActions].
@ProviderFor(TodoActions)
final todoActionsProvider =
    AutoDisposeNotifierProvider<TodoActions, void>.internal(
      TodoActions.new,
      name: r'todoActionsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$todoActionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TodoActions = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
