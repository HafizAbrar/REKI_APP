import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'Connection timed out. Please check your internet and try again.';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'No internet connection. Please check your network and try again.';
      }
      if (error.type == DioExceptionType.unknown) {
        return 'Network error. Please check your internet connection and try again.';
      }

      final serverMessage = error.response?.data is Map
          ? error.response?.data['message']?.toString()
          : null;

      switch (error.response?.statusCode) {
        case 400:
          final data = error.response?.data;
          if (data is Map && data['message'] is List) {
            final messages = data['message'] as List;
            if (messages.isNotEmpty) {
              final firstError = messages.first.toString();
              if (firstError.contains('fullName')) return 'Please enter your full name (at least 2 characters).';
              if (firstError.contains('phone')) return 'Please enter a valid phone number.';
              if (firstError.contains('email')) return 'Please enter a valid email address.';
              if (firstError.contains('password')) return 'Password must be at least 8 characters.';
            }
          }
          return serverMessage ?? 'Invalid request. Please check your input.';
        case 401:
          return 'Your session has expired. Please log in again.';
        case 403:
          return 'You don\'t have permission to perform this action.';
        case 404:
          return serverMessage ?? 'The requested resource was not found.';
        case 409:
          return serverMessage ?? 'This email is already registered.';
        case 422:
          return serverMessage ?? 'Please fill in all required fields correctly.';
        case 429:
          return 'Too many requests. Please wait a moment and try again.';
        case 500:
        case 502:
        case 503:
          return 'Something went wrong on our end. Please try again later.';
        default:
          return serverMessage ?? 'Something went wrong. Please try again.';
      }
    }
    return 'An unexpected error occurred. Please try again.';
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
