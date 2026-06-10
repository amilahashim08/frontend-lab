import 'package:flutter/material.dart';

import 'app.dart';
import 'core/services/tts_platform_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Auto-configure TTS + max volume on Android (no manual Settings).
  TtsPlatformService.autoSetup();
  runApp(const FrontendLabApp());
}
