import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category_model.dart';
import '../providers/app_provider.dart';
import '../utils/icon_constants.dart';
import '../utils/localization.dart';
import '../widgets/app_shell.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: tr(context, 'Kategori', 'Categories'),
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
                  child: Icon(
                    IconConstants.getIcon(item.icon),
                    color: Color(item.color),
                  ),
                ),
                title: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  ' • ',
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) => v == 'edit'
                      ? _showCategoryForm(context, item)
                      : provider.deleteCategory(item.id!),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(tr(context, 'Edit', 'Edit')),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(tr(context, 'Hapus', 'Delete')),
                    ),
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
    String selectedIcon = item?.icon ?? 'restaurant';
    String selectedType = item?.type ?? 'expense';
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
                    tr(
                      context,
                      item == null ? 'Tambah Kategori' : 'Edit Kategori',
                      item == null ? 'Add Category' : 'Edit Category',
                    ),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: name,
                    decoration: InputDecoration(
                      labelText: tr(context, 'Nama', 'Name'),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? tr(context, 'Nama wajib diisi', 'Name is required')
                        : null,
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<String>(
                    segments: [
                      ButtonSegment(
                        value: 'expense',
                        label: Text(tr(context, 'Pengeluaran', 'Expense')),
                      ),
                      ButtonSegment(
                        value: 'income',
                        label: Text(tr(context, 'Pemasukan', 'Income')),
                      ),
                    ],
                    selected: {selectedType},
                    onSelectionChanged: (value) =>
                        setState(() => selectedType = value.first),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedIcon,
                    decoration: InputDecoration(
                      labelText: tr(context, 'Pilih Icon', 'Choose Icon'),
                    ),
                    items: IconConstants.availableIcons.map((icon) {
                      return DropdownMenuItem<String>(
                        value: icon.name,
                        child: Row(
                          children: [
                            Icon(IconConstants.getIcon(icon.name), size: 24),
                            const SizedBox(width: 12),
                            Text(icon.label),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedIcon = value);
                      }
                    },
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
                          icon: selectedIcon,
                          color: color.toARGB32(),
                          type: selectedType,
                        ),
                      );
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: Text(tr(context, 'Simpan', 'Save')),
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
