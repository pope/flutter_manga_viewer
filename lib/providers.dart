import 'package:flutter_riverpod/flutter_riverpod.dart';

// By using a provider, this allows us to mock/override the value exposed.
final helloWorldProvider = Provider((_) => 'Hello, World!');
