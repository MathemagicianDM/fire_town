// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';
import '../models/todo.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsyncValue = ref.watch(todoListProvider);
    final currentFilter = ref.watch(todoFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Todo App'),
        actions: [
          PopupMenuButton<TodoFilterOption>(
            initialValue: currentFilter,
            onSelected: (filter) {
              ref.read(todoFilterProvider.notifier).setFilter(filter);
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: TodoFilterOption.all,
                    child: Text('All'),
                  ),
                  const PopupMenuItem(
                    value: TodoFilterOption.active,
                    child: Text('Active'),
                  ),
                  const PopupMenuItem(
                    value: TodoFilterOption.completed,
                    child: Text('Completed'),
                  ),
                ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authServiceProvider).signOut();
            }, ),
        ],
      ),
      body: Column(
        children: [
          const TodoInput(),
          Expanded(
            child: todosAsyncValue.when(
              data: (todos) {
                if (todos.isEmpty) {
                  return const Center(child: Text('No todos yet. Add one!'));
                }

                final filteredTodos = ref.watch(filteredTodosProvider);
                return TodoList(todos: filteredTodos);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stackTrace) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}

class TodoInput extends ConsumerStatefulWidget {
  const TodoInput({super.key});

  @override
  ConsumerState<TodoInput> createState() => _TodoInputState();
}

class _TodoInputState extends ConsumerState<TodoInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Add a new todo...',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                _addTodo();
              },
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(onPressed: _addTodo, child: const Text('Add')),
        ],
      ),
    );
  }

  void _addTodo() {
    if (_controller.text.isNotEmpty) {
      ref.read(todoActionsProvider.notifier).addTodo(_controller.text);
      _controller.clear();
    }
  }
}

class TodoList extends ConsumerWidget {
  final List<Todo> todos;

  const TodoList({super.key, required this.todos});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return TodoItem(todo: todo);
      },
    );
  }
}

class TodoItem extends ConsumerWidget {
  final Todo todo;

  const TodoItem({super.key, required this.todo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(
        todo.title,
        style: TextStyle(
          decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      leading: Checkbox(
        value: todo.isCompleted,
        onChanged: (bool? value) {
          ref
              .read(todoActionsProvider.notifier)
              .toggleTodo(todo.id, todo.isCompleted);
        },
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          ref.read(todoActionsProvider.notifier).deleteTodo(todo.id);
        },
      ),
    );
  }
}
