import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.response?.statusCode) {
        case 400:
          final data = error.response?.data;
          if (data is Map && data['message'] is List) {
            final messages = data['message'] as List;
            if (messages.isNotEmpty) {
              final firstError = messages.first.toString();
              if (firstError.contains('fullName')) return 'Please enter your full name (at least 2 characters)';
              if (firstError.contains('phone')) return 'Please enter a valid phone number (at least 7 digits)';
              if (firstError.contains('email')) return 'Please enter a valid email address';
              if (firstError.contains('password')) return 'Password must be at least 8 characters';
            }
          }
          return data?['message']?.toString() ?? 'Invalid request. Please check your input.';
        case 401:
          return 'Session expired. Please login again.';
        case 403:
          return 'Access denied. You don\'t have permission.';
        case 404:
          return 'Resource not found.';
        case 409:
          return error.response?.data['message'] ?? 'Conflict occurred.';
        case 422:
          return 'Validation failed. Please check your input.';
        case 500:
          return 'Server error. Please try again later.';
        case 503:
          return 'Service unavailable. Please try again later.';
        default:
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout) {
            return 'Connection timeout. Please check your internet.';
          }
          if (error.type == DioExceptionType.connectionError) {
            return 'No internet connection.';
          }
          return error.response?.data['message'] ?? 'Something went wrong.';
      }
    }
    return error.toString().contains('Exception') 
        ? 'An error occurred. Please try again.' 
        : error.toString();
  }

  static void showError(BuildContext context, dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(getErrorMessage(error)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
