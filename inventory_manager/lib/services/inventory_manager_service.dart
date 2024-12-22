import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:inventory_manager/auth/auth_service.dart';

class InventoryManagerService {
  static const String _baseUrl = 'http://192.168.1.17:5000/api';

  static Future<Either> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    const url = '$_baseUrl/signup';
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode != 200) {
      return const Left('Failed to connect to the server.');
    }

    dynamic responseJson = jsonDecode(response.body);

    if (responseJson['status'] == 'success') {
      AuthService authService = AuthService();
      await authService.saveSession(responseJson['account'], password);
      return Right(responseJson['message']);
    } else {
      return Left(responseJson['message']);
    }
  }

  static Future<Either> login({
    required String email,
    required String password,
  }) async {
    const url = '$_baseUrl/login';
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode != 200) {
      return const Left('Failed to connect to the server.');
    }

    dynamic responseJson = jsonDecode(response.body);

    if (responseJson['status'] == 'success') {
      AuthService authService = AuthService();
      await authService.saveSession(responseJson['account'], password);
      return Right(responseJson['message']);
    } else {
      return Left(responseJson['message']);
    }
  }

  static Future<Either<String, List<dynamic>>> getAssignedItems() async {
    AuthService authService = AuthService();
    final session = await authService.getCredentials();

    const url = '$_baseUrl/assigned_items';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'email': session['email'],
        'password': session['password'],
      },
    );

    if (response.statusCode != 200) {
      return const Left('Failed to connect to the server.');
    }

    dynamic responseJson = jsonDecode(response.body);

    if (responseJson['status'] == 'success') {
      return Right(responseJson['assigned_items']);
    } else {
      return Left(responseJson['message']);
    }
  }

  static Future<Either<String, Map<String, dynamic>>> getItem(String id) async {
    AuthService authService = AuthService();
    final session = await authService.getCredentials();

    const url = '$_baseUrl/item';

    final response = await http.post(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: {
      'email': session['email'],
      'password': session['password'],
      'item_id': id,
    },
  );

    if (response.statusCode != 200) {
      return const Left('Failed to connect to the server.');
    }

    dynamic responseJson = jsonDecode(response.body);

    if (responseJson['status'] == 'success') {
      return Right(responseJson['item']);
    } else {
      return Left(responseJson['message']);
    }
  }

  static Future<Either<String, String>> returnItem({
    required String itemId,
    required String returnReason,
    required String returnAmount,
  }) async {
    AuthService authService = AuthService();
    final session = await authService.getCredentials();

    const url = '$_baseUrl/return_item';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'email': session['email'],
        'password': session['password'],
        'item_id': itemId,
        'return_reason': returnReason,
        'return_amount': returnAmount,
      },
    );

    if (response.statusCode != 200) {
      return const Left('Failed to connect to the server.');
    }

    dynamic responseJson = jsonDecode(response.body);

    if (responseJson['status'] == 'success') {
      return Right(responseJson['message']);
    } else {
      return Left(responseJson['message']);
    }
  }

  static Future<Either<String, List<dynamic>>> getTransactions() async {
    AuthService authService = AuthService();
    final session = await authService.getCredentials();

    const url = '$_baseUrl/transactions';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'email': session['email'],
        'password': session['password'],
      },
    );

    if (response.statusCode != 200) {
      return const Left('Failed to connect to the server.');
    }

    dynamic responseJson = jsonDecode(response.body);

    if (responseJson['status'] == 'success') {
      return Right(responseJson['transactions']);
    } else {
      return Left(responseJson['message']);
    }
  }
}
