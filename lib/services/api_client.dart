import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  // Set this to your deployed backend URL before building for production
  // e.g. 'https://flowora-api.railway.app/api'
  static const String _prodUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: '',
  );

  static final String _baseUrl = _resolveBaseUrl();

  static String _resolveBaseUrl() {
    if (_prodUrl.isNotEmpty) return _prodUrl;
    if (kIsWeb) return 'http://localhost:8080/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:8080/api';
    return 'http://localhost:8080/api';
  }

  static String? _token;
  static String? _userId;

  static String? get token => _token;
  static String? get userId => _userId;
  static bool get isLoggedIn => _token != null;

  // ─── Auth ────────────────────────────────────────────

  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _userId = prefs.getString('user_id');
  }

  static Future<void> _saveToken(String token, String userId) async {
    _token = token;
    _userId = userId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_id', userId);
  }

  static Future<void> clearToken() async {
    _token = null;
    _userId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
  }

  static Future<Map<String, dynamic>> register(
      String email, String password, String name) async {
    final res = await _post('/auth/register', {
      'email': email,
      'password': password,
      'name': name,
    }, auth: false);
    await _saveToken(res['token'], res['userId']);
    return res;
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final res = await _post('/auth/login', {
      'email': email,
      'password': password,
    }, auth: false);
    await _saveToken(res['token'], res['userId']);
    return res;
  }

  static Future<void> logout() async {
    await clearToken();
  }

  static Future<Map<String, dynamic>> getProfile() async {
    return await _get('/auth/me');
  }

  static Future<Map<String, dynamic>> updateProfile(
      Map<String, String> data) async {
    return await _put('/auth/profile', data);
  }

  // ─── Tasks ───────────────────────────────────────────

  static Future<List<dynamic>> getTasks() async {
    return await _getList('/tasks');
  }

  static Future<List<dynamic>> getTasksByDate(String date) async {
    return await _getList('/tasks/date/$date');
  }

  static Future<List<dynamic>> getOverdueTasks() async {
    return await _getList('/tasks/overdue');
  }

  static Future<Map<String, dynamic>> createTask(
      Map<String, dynamic> data) async {
    return await _post('/tasks', data);
  }

  static Future<Map<String, dynamic>> updateTask(
      String id, Map<String, dynamic> data) async {
    return await _put('/tasks/$id', data);
  }

  static Future<Map<String, dynamic>> toggleTask(String id) async {
    return await _patch('/tasks/$id/toggle');
  }

  static Future<void> deleteTask(String id) async {
    await _delete('/tasks/$id');
  }

  // ─── Recipes ─────────────────────────────────────────

  static Future<List<dynamic>> getRecipes() async {
    return await _getList('/recipes');
  }

  static Future<Map<String, dynamic>> getRecipe(String id) async {
    return await _get('/recipes/$id');
  }

  static Future<Map<String, dynamic>> createRecipe(
      Map<String, dynamic> data) async {
    return await _post('/recipes', data);
  }

  static Future<Map<String, dynamic>> updateRecipe(
      String id, Map<String, dynamic> data) async {
    return await _put('/recipes/$id', data);
  }

  static Future<List<dynamic>> searchRecipesByIngredients(
      List<String> ingredients) async {
    final query = ingredients.map((i) => 'ingredients=$i').join('&');
    return await _getList('/recipes/search?$query');
  }

  static Future<void> deleteRecipe(String id) async {
    await _delete('/recipes/$id');
  }

  // ─── Time Blocks ─────────────────────────────────────

  static Future<List<dynamic>> getTimeBlocks() async {
    return await _getList('/time-blocks');
  }

  static Future<List<dynamic>> getTimeBlocksByDate(String date) async {
    return await _getList('/time-blocks/date/$date');
  }

  static Future<Map<String, dynamic>> createTimeBlock(
      Map<String, dynamic> data) async {
    return await _post('/time-blocks', data);
  }

  static Future<Map<String, dynamic>> updateTimeBlock(
      String id, Map<String, dynamic> data) async {
    return await _put('/time-blocks/$id', data);
  }

  static Future<void> deleteTimeBlock(String id) async {
    await _delete('/time-blocks/$id');
  }

  // ─── Habits ──────────────────────────────────────────

  static Future<List<dynamic>> getHabits() async {
    return await _getList('/habits');
  }

  static Future<Map<String, dynamic>> createHabit(
      Map<String, dynamic> data) async {
    return await _post('/habits', data);
  }

  static Future<Map<String, dynamic>> updateHabit(
      String id, Map<String, dynamic> data) async {
    return await _put('/habits/$id', data);
  }

  static Future<Map<String, dynamic>> toggleHabit(String id) async {
    return await _patch('/habits/$id/toggle');
  }

  static Future<Map<String, dynamic>> logHabit(
      String id, Map<String, dynamic> data) async {
    return await _post('/habits/$id/log', data);
  }

  static Future<void> deleteHabit(String id) async {
    await _delete('/habits/$id');
  }

  // ─── Meal Plans ──────────────────────────────────────

  static Future<List<dynamic>> getMealPlans() async {
    return await _getList('/meal-plans');
  }

  static Future<Map<String, dynamic>?> getMealPlanByDate(String date) async {
    try {
      return await _get('/meal-plans/date/$date');
    } catch (_) {
      return null;
    }
  }

  static Future<List<dynamic>> getMealPlanWeek(String weekStart) async {
    return await _getList('/meal-plans/week/$weekStart');
  }

  static Future<Map<String, dynamic>> upsertMealPlan(
      Map<String, dynamic> data) async {
    return await _post('/meal-plans', data);
  }

  static Future<Map<String, dynamic>> assignMeal(
      Map<String, String> data) async {
    return await _patch('/meal-plans/assign', body: data);
  }

  static Future<void> deleteMealPlan(String id) async {
    await _delete('/meal-plans/$id');
  }

  // ─── Shopping List ───────────────────────────────────

  static Future<List<dynamic>> getShoppingList() async {
    return await _getList('/shopping-list');
  }

  static Future<Map<String, dynamic>> createShoppingItem(
      Map<String, dynamic> data) async {
    return await _post('/shopping-list', data);
  }

  static Future<Map<String, dynamic>> toggleShoppingItem(String id) async {
    return await _patch('/shopping-list/$id/toggle');
  }

  static Future<void> deleteShoppingItem(String id) async {
    await _delete('/shopping-list/$id');
  }

  static Future<void> clearCheckedItems() async {
    await _delete('/shopping-list/clear-checked');
  }

  static Future<List<dynamic>> generateShoppingList(
      List<Map<String, dynamic>> items) async {
    return await _postList('/shopping-list/generate', items);
  }

  // ─── HTTP Helpers ────────────────────────────────────

  static Map<String, String> _headers({bool auth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (auth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  static Future<Map<String, dynamic>> _get(String path) async {
    final res = await http.get(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(),
    );
    return _handleResponse(res);
  }

  static Future<List<dynamic>> _getList(String path) async {
    final res = await http.get(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    throw Exception(_errorMessage(res));
  }

  static Future<Map<String, dynamic>> _post(String path, dynamic data,
      {bool auth = true}) async {
    final res = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(auth: auth),
      body: jsonEncode(data),
    );
    return _handleResponse(res);
  }

  static Future<List<dynamic>> _postList(
      String path, List<dynamic> data) async {
    final res = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(),
      body: jsonEncode(data),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    throw Exception(_errorMessage(res));
  }

  static Future<Map<String, dynamic>> _put(
      String path, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(),
      body: jsonEncode(data),
    );
    return _handleResponse(res);
  }

  static Future<Map<String, dynamic>> _patch(String path,
      {Map<String, dynamic>? body}) async {
    final res = await http.patch(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(res);
  }

  static Future<void> _delete(String path) async {
    final res = await http.delete(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(),
    );
    if (res.statusCode >= 300) {
      throw Exception(_errorMessage(res));
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return {};
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception(_errorMessage(res));
  }

  static String _errorMessage(http.Response res) {
    try {
      final body = jsonDecode(res.body);
      return body['error'] ?? 'Request failed (${res.statusCode})';
    } catch (_) {
      return 'Request failed (${res.statusCode})';
    }
  }
}
