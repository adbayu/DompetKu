import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category_model.dart';
import '../providers/app_provider.dart';
import '../widgets/app_shell.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Kategori',
      fab: FloatingActionButton(
        onPressed: () => _showCategoryForm(context),
        child: const Icon(Icons.add),
      ),
      child: Consumer<AppProvider>(
        builder: (context, provider, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: provider.categories.map((item) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(item.color).withValues(alpha: .16),
                  child: Icon(Icons.category, color: Color(item.color)),
                ),
                title: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(item.icon),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) => v == 'edit'
                      ? _showCategoryForm(context, item)
                      : provider.deleteCategory(item.id!),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Hapus')),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showCategoryForm(BuildContext context, [CategoryModel? item]) {
    final name = TextEditingController(text: item?.name);
    final icon = TextEditingController(text: item?.icon ?? 'category');
    Color color = item == null ? Colors.teal : Color(item.color);
    final formKey = GlobalKey<FormState>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              18,
              18,
              18,
              MediaQuery.of(context).viewInsets.bottom + 18,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item == null ? 'Tambah Kategori' : 'Edit Kategori',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Nama'),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Nama wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: icon,
                    decoration: const InputDecoration(labelText: 'Icon key'),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children:
                        [
                              Colors.teal,
                              Colors.green,
                              Colors.blue,
                              Colors.orange,
                              Colors.purple,
                              Colors.red,
                            ]
                            .map(
                              (c) => ChoiceChip(
                                label: const Text(''),
                                selected: color == c,
                                avatar: CircleAvatar(backgroundColor: c),
                                onSelected: (_) => setState(() => color = c),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      await context.read<AppProvider>().saveCategory(
                        CategoryModel(
                          id: item?.id,
                          name: name.text.trim(),
                          icon: icon.text.trim(),
                          color: color.toARGB32(),
                        ),
                      );
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text('Simpan'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
