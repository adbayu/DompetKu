import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';

String tr(BuildContext context, String id, String en) {
  final isEn = context.watch<AppProvider>().languagePref == 'en';
  return isEn ? en : id;
}
