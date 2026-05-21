import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/portfolio_data.dart';

class CloudSync {
  CloudSync(this._client);

  final SupabaseClient _client;
  static const _table = 'user_financial_states';

  Future<PortfolioData?> pull(String userId) async {
    final row = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (row == null) return null;
    final payload = row['payload'];
    if (payload == null) return null;
    final map = payload is String
        ? jsonDecode(payload) as Map<String, dynamic>
        : Map<String, dynamic>.from(payload as Map);
    return PortfolioData.fromJson(map);
  }

  Future<void> push(String userId, PortfolioData data) async {
    final payload = data.toJson();
    await _client.from(_table).upsert({
      'user_id': userId,
      'payload': payload,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }
}
