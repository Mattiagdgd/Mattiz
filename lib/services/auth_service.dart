import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/user.dart';

final authServiceProvider = ChangeNotifierProvider<AuthService>((ref) {
  final service = AuthService();
  service.initialize();
  return service;
});

class AuthService extends ChangeNotifier {
  AuthService();

  static const _storageKey = 'mattiz_current_user';
  final _uuid = const Uuid();
  MattizUser? _currentUser;
  bool _loading = false;

  MattizUser? get currentUser => _currentUser;
  bool get isLoading => _loading;
  bool get isAuthenticated => _currentUser != null;

  Future<void> initialize() async {
    _loading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_storageKey);
    if (stored != null) {
      final json = jsonDecode(stored) as Map<String, dynamic>;
      _currentUser = MattizUser.fromJson(json);
    }

    _loading = false;
    notifyListeners();
  }

  Future<MattizUser> register(String username) async {
    _loading = true;
    notifyListeners();

    final user = MattizUser(
      id: _uuid.v4(),
      username: username,
      createdAt: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(user.toJson()));

    _currentUser = user;
    _loading = false;
    notifyListeners();

    return user;
  }

  Future<void> login(String username) async {
    _loading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_storageKey);

    if (stored == null) {
      throw StateError('Nessun account registrato trovato.');
    }

    final json = jsonDecode(stored) as Map<String, dynamic>;
    final storedUser = MattizUser.fromJson(json);

    if (storedUser.username != username) {
      throw ArgumentError('Username non valido.');
    }

    _currentUser = storedUser;
    _loading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    _currentUser = null;
    notifyListeners();
  }
}
