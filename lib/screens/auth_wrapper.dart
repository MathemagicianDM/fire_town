import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';
// import 'home_screen.dart';
import 'login_screen.dart';
import 'home.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    return authState.when(
      data: (user) {
        if (user != null) {
          return const Home();
        } else {
          return const LoginScreen();
        }
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) {
        // Display a more user-friendly error message
        final errorMessage = error is String 
            ? error 
            : 'An authentication error occurred. Please try again.';
        
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(errorMessage),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Force refresh of the auth state
                    // ignore: unused_result
                    ref.refresh(authStateProvider);
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}