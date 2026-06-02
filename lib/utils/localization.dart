import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';

String tr(BuildContext context, String id, String en) {
  try {
    // Use listen: false to allow calling from callbacks / overlays
    final provider = Provider.of<AppProvider>(context, listen: false);
    final isEn = provider.languagePref == 'en';
    return isEn ? en : id;
  } catch (_) {
    // If provider is not available in this context, fall back to id (default language)
    return id;
  }
}
