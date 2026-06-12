import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDatasource {
  const AdminDatasource(this._supabase);

  final SupabaseClient _supabase;

  Future<Map<String, dynamic>> getDashboardStats() async {
    final res = await _supabase.rpc('get_admin_dashboard_stats');
    return res as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getUsers({
    String? role,
    String? search,
    bool bannedOnly = false,
  }) async {
    var query = _supabase.from('profiles').select('*, companies(id)');

    if (role != null && role != 'all') {
      query = query.eq('role', role);
    }

    if (bannedOnly) {
      query = query.not('banned_until', 'is', null).gt('banned_until', 'now()');
    }

    if (search != null && search.isNotEmpty) {
      query = query.or('full_name.ilike.%$search%,email.ilike.%$search%');
    }

    final res = await query.order('created_at', ascending: false);
    return (res as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getReportStats() async {
    final res = await _supabase
        .from('reports')
        .select('status, target_type')
        .order('created_at', ascending: false);
    final reports = (res as List).cast<Map<String, dynamic>>();

    final statusCounts = <String, int>{};
    final typeCounts = <String, int>{};

    for (final r in reports) {
      final s = r['status'] as String? ?? 'pending';
      final t = r['target_type'] as String? ?? 'unknown';
      statusCounts[s] = (statusCounts[s] ?? 0) + 1;
      typeCounts[t] = (typeCounts[t] ?? 0) + 1;
    }

    return {
      'total': reports.length,
      'byStatus': statusCounts,
      'byType': typeCounts,
    };
  }

  Future<List<Map<String, dynamic>>> getReports({
    String? status,
  }) async {
    var query = _supabase
        .from('reports')
        .select('*, reporter:profiles!reports_reporter_id_fkey(full_name, avatar_url)');

    if (status != null) {
      query = query.eq('status', status);
    }

    final res = await query.order('created_at', ascending: false);
    return (res as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>?> getReportById(String id) async {
    final report = await _supabase
        .from('reports')
        .select('*, reporter:profiles!reports_reporter_id_fkey(*)')
        .eq('id', id)
        .maybeSingle();

    if (report == null) return null;

    // target_id is polymorphic; fetch target user only when target_type == 'user'
    if (report['target_type'] == 'user' && report['target_id'] != null) {
      final targetUser = await _supabase
          .from('profiles')
          .select('*')
          .eq('id', report['target_id'] as String)
          .maybeSingle();
      if (targetUser != null) {
        report['target_user'] = targetUser;
      }
    }

    return report;
  }

  Future<void> updateReportStatus({
    required String reportId,
    required String status,
    String? action,
    String? resolvedBy,
  }) async {
    final updated = await _supabase.from('reports').update({
      'status': status,
      'action': action,
      'resolved_by': resolvedBy,
      'resolved_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', reportId).select('id');
    _ensureUpdated(updated, 'cập nhật báo cáo');
  }

  Future<void> banUser({
    required String userId,
    required DateTime bannedUntil,
  }) async {
    // Serialize as UTC: DateTime.now() is local (UTC+7); a naive
    // toIso8601String() has no offset, so a TIMESTAMPTZ column reads it back as
    // UTC and the ban appears ~7h longer than chosen. toUtc() pins the instant.
    final updated = await _supabase.from('profiles').update({
      'banned_until': bannedUntil.toUtc().toIso8601String(),
    }).eq('id', userId).select('id');
    _ensureUpdated(updated, 'cập nhật trạng thái khóa');
  }

  Future<void> sendWarning(String userId, String message) async {
    // Mark the warning state on the profile (the source of truth for the
    // "Đã cảnh cáo" badge and for un-warning), then notify the user.
    final updated = await _supabase.from('profiles').update({
      'warned_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', userId).select('id');
    _ensureUpdated(updated, 'cập nhật trạng thái cảnh cáo');

    await _supabase.from('notifications').insert({
      'user_id': userId,
      'type': 'warning',
      'title': 'Cảnh cáo từ Quản trị viên',
      'body': message,
      'data_json': {},
    });
  }

  Future<void> removeWarning(String userId) async {
    final updated = await _supabase.from('profiles').update({
      'warned_at': null,
    }).eq('id', userId).select('id');
    _ensureUpdated(updated, 'gỡ cảnh cáo');
  }

  Future<void> closeJobPost(String jobPostId) async {
    final updated = await _supabase.from('job_posts').update({
      'status': 'closed',
    }).eq('id', jobPostId).select('id');
    _ensureUpdated(updated, 'đóng tin tuyển dụng');
  }

  /// Supabase Dart KHÔNG throw khi UPDATE ảnh hưởng 0 dòng (thường do RLS chặn).
  /// Check kết quả .select() để báo lỗi thay vì im lặng bỏ qua.
  void _ensureUpdated(List<Map<String, dynamic>> updated, String action) {
    if (updated.isEmpty) {
      throw PostgrestException(
        message: 'Không thể $action — không có dòng nào được cập nhật.',
      );
    }
  }

  Future<void> changeUserRole({
    required String userId,
    required String role,
  }) async {
    await _supabase.rpc('change_user_role', params: {
      'target_user_id': userId,
      'new_role': role,
    });
  }

  Future<String> createInviteCode({String role = 'admin'}) async {
    final code = _generateCode();
    await _supabase.from('admin_invites').insert({
      'code': code,
      'created_by': _supabase.auth.currentUser!.id,
      'role': role,
      'expires_at': DateTime.now().toUtc().add(const Duration(hours: 24)).toIso8601String(),
    });
    return code;
  }

  Future<List<Map<String, dynamic>>> getInviteCodes() async {
    final res = await _supabase
        .from('admin_invites')
        .select('*')
        .eq('created_by', _supabase.auth.currentUser!.id)
        .order('created_at', ascending: false);
    return (res as List).cast<Map<String, dynamic>>();
  }

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final sb = StringBuffer();
    final rand = DateTime.now().millisecondsSinceEpoch;
    for (var i = 0; i < 8; i++) {
      sb.write(chars[(rand + i * 17) % chars.length]);
    }
    return sb.toString();
  }
}
