import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:collection/collection.dart';
import '../providers/barrel_of_providers.dart';
import '../models/rumor_template_model.dart';
import '../globals.dart';
import '../screens/person_detail_view.dart';
import '../screens/rumor_management_page.dart';

class TalkOfTownCard extends ConsumerStatefulWidget {
  const TalkOfTownCard({super.key});

  @override
  ConsumerState<TalkOfTownCard> createState() => _TalkOfTownCardState();
}

class _TalkOfTownCardState extends ConsumerState<TalkOfTownCard> {
  List<GeneratedRumor> _displayedRumors = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshRumors());
  }

  void _refreshRumors() {
    final allRumors = ref.read(allRumorsProvider);
    final shuffledRumors = [...allRumors]..shuffle();
    setState(() {
      _displayedRumors = shuffledRumors.take(4).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch for changes in rumors
    ref.listen(allRumorsProvider, (previous, next) {
      if (mounted) _refreshRumors();
    });

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.chat_bubble_outline, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Talk of the Town',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _navigateToRumorManagement(context),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Manage'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _refreshRumors,
                  tooltip: 'Refresh rumors',
                  iconSize: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_displayedRumors.isEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.sentiment_neutral, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No rumors are circulating at the moment...',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              ..._displayedRumors.map((rumor) => _RumorItem(rumor: rumor)),
          ],
        ),
      ),
    );
  }

  void _navigateToRumorManagement(BuildContext context) {
    navigatorKey.currentState?.pushNamed(RumorManagementPage.routeName);
  }
}

class _RumorItem extends ConsumerWidget {
  final GeneratedRumor rumor;

  const _RumorItem({required this.rumor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: rumor.isCustom ? Colors.blue.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: rumor.isCustom ? Colors.blue.shade200 : Colors.grey.shade200,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              rumor.isCustom ? Icons.edit : Icons.chat,
              size: 16,
              color: rumor.isCustom ? Colors.blue : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  children: _buildRumorTextSpans(rumor, ref),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<InlineSpan> _buildRumorTextSpans(GeneratedRumor rumor, WidgetRef ref) {
    final people = ref.read(peopleProvider);
    final spans = <InlineSpan>[];

    String content = rumor.content;

    // Make referenced NPC names clickable
    for (final npcId in rumor.referencedNPCs) {
      final person = people.firstWhereOrNull((p) => p.id == npcId);
      if (person != null) {
        final nameIndex = content.indexOf(person.firstName);
        if (nameIndex != -1) {
          // Add text before name
          if (nameIndex > 0) {
            spans.add(TextSpan(text: content.substring(0, nameIndex)));
          }

          // Add clickable name
          spans.add(TextSpan(
            text: person.firstName,
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w500,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _navigateToPersonDetail(person.id),
          ));

          // Update content to remaining text
          content = content.substring(nameIndex + person.firstName.length);
        }
      }
    }

    // Add any remaining text
    if (content.isNotEmpty) {
      spans.add(TextSpan(text: content));
    }

    // If no spans were added, add the original content
    if (spans.isEmpty) {
      spans.add(TextSpan(text: rumor.content));
    }

    return spans;
  }

  void _navigateToPersonDetail(String personId) {
    navigatorKey.currentState!.restorablePushNamed(
      PersonDetailView.routeName,
      arguments: {'myID': personId},
    );
  }
}