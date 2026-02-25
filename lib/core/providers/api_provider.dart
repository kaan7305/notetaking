import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_notebook/core/api/api_client.dart';
import 'package:study_notebook/core/providers/supabase_provider.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return ApiClient(supabaseClient: supabaseClient);
});
