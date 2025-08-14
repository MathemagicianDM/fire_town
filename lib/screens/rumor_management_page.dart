import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/rumor_provider.dart';
import '../models/rumor_template_model.dart';

class RumorManagementPage extends ConsumerStatefulWidget {
  const RumorManagementPage({super.key});
  static const routeName = '/rumor_management';

  @override
  ConsumerState<RumorManagementPage> createState() => _RumorManagementPageState();
}

class _RumorManagementPageState extends ConsumerState<RumorManagementPage> 
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final generatedRumors = ref.watch(generatedRumorsProvider);
    final customRumors = ref.watch(customRumorsProvider);
    final allRumors = ref.watch(allRumorsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Town Rumors'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active Rumors', icon: Icon(Icons.chat)),
            Tab(text: 'Add Custom', icon: Icon(Icons.add)),
            Tab(text: 'Manage Custom', icon: Icon(Icons.edit)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Active rumors tab
          _buildActiveRumorsTab(allRumors),
          // Add custom rumor tab
          _buildAddCustomTab(),
          // Manage custom rumors tab
          _buildManageCustomTab(customRumors),
        ],
      ),
    );
  }

  Widget _buildActiveRumorsTab(List<GeneratedRumor> rumors) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Rumors in Circulation',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'These rumors are currently active based on your town\'s NPCs and roles. Generated rumors update automatically when you refresh.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: rumors.isEmpty
                ? const Center(
                    child: Text(
                      'No rumors available.\nYour town might be too small or missing key NPCs.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: rumors.length,
                    itemBuilder: (context, index) {
                      final rumor = rumors[index];
                      return _RumorCard(rumor: rumor);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCustomTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Custom Rumor',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your own rumors that will appear alongside the generated ones.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter your custom rumor...',
                      helperText: 'Keep it interesting but believable!',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    maxLength: 200,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _addCustomRumor,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Rumor'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => _controller.clear(),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Example rumors section
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Example Rumors',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView(
                        children: const [
                          _ExampleRumor(
                            text: 'A traveling merchant lost a valuable ring near the old well.',
                          ),
                          _ExampleRumor(
                            text: 'Strange lights were seen dancing in the forest last night.',
                          ),
                          _ExampleRumor(
                            text: 'The baker\'s cat has been acting oddly, staring at empty corners.',
                          ),
                          _ExampleRumor(
                            text: 'A mysterious letter arrived for someone who left town years ago.',
                          ),
                          _ExampleRumor(
                            text: 'Children claim they found ancient coins while playing by the river.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManageCustomTab(List<GeneratedRumor> customRumors) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Custom Rumors',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage rumors you\'ve added to your town.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: customRumors.isEmpty
                ? const Center(
                    child: Text(
                      'No custom rumors yet.\nAdd some in the "Add Custom" tab!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: customRumors.length,
                    itemBuilder: (context, index) {
                      final rumor = customRumors[index];
                      return _CustomRumorCard(
                        rumor: rumor,
                        onDelete: () => _deleteCustomRumor(rumor.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _addCustomRumor() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      ref.read(customRumorsProvider.notifier).addCustomRumor(text);
      _controller.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Custom rumor added!'),
          backgroundColor: Colors.green,
        ),
      );
      // Switch to manage tab to see the added rumor
      _tabController.animateTo(2);
    }
  }

  void _deleteCustomRumor(String rumorId) {
    ref.read(customRumorsProvider.notifier).removeCustomRumor(rumorId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Custom rumor deleted'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}

class _RumorCard extends StatelessWidget {
  final GeneratedRumor rumor;

  const _RumorCard({required this.rumor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  rumor.isCustom ? Icons.edit : Icons.auto_awesome,
                  size: 16,
                  color: rumor.isCustom ? Colors.blue : Colors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rumor.content,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            if (rumor.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: rumor.tags.map((tag) => Chip(
                  label: Text(tag),
                  backgroundColor: Colors.grey.shade200,
                  labelStyle: const TextStyle(fontSize: 10),
                  visualDensity: VisualDensity.compact,
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CustomRumorCard extends StatelessWidget {
  final GeneratedRumor rumor;
  final VoidCallback onDelete;

  const _CustomRumorCard({
    required this.rumor,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.edit, size: 16, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                rumor.content,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteDialog(context),
              iconSize: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Custom Rumor?'),
        content: Text('Are you sure you want to delete this rumor?\n\n"${rumor.content}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ExampleRumor extends StatelessWidget {
  final String text;

  const _ExampleRumor({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}