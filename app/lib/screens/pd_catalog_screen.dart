import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/gutenberg_catalog.dart';
import '../state/flick_controller.dart';

class PdCatalogScreen extends StatefulWidget {
  const PdCatalogScreen({super.key});

  @override
  State<PdCatalogScreen> createState() => _PdCatalogScreenState();
}

class _PdCatalogScreenState extends State<PdCatalogScreen> {
  final _client = GutenbergCatalogClient();
  final _searchController = TextEditingController(text: 'melville');
  List<PdCatalogBook> _results = [];
  bool _loading = false;
  String? _error;
  String? _importingId;

  @override
  void dispose() {
    _searchController.dispose();
    _client.close();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final books = await _client.search(query: _searchController.text);
      if (!mounted) return;
      setState(() => _results = books);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _import(PdCatalogBook book) async {
    setState(() => _importingId = '${book.id}');
    final c = context.read<FlickController>();
    final err = await c.importFromCatalog(book);
    if (!mounted) return;
    setState(() => _importingId = null);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err)),
      );
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Public-domain catalog')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search Gutenberg (English)',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _loading ? null : _search,
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final book = _results[index];
                final busy = _importingId == '${book.id}';
                return ListTile(
                  title: Text(book.title),
                  subtitle: Text(book.authorLabel),
                  trailing: busy
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download_outlined),
                  onTap: busy ? null : () => _import(book),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
