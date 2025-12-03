import 'package:firebase_core/firebase_core.dart';
import '/app/data/services/firebase_options.dart';
///./../firebase_options.dart';
/// Service untuk initialize Firebase
class FirebaseService {
static Future<void> initialize() async {
await Firebase.initializeApp(
options: DefaultFirebaseOptions.currentPlatform,
);
}
}
