sealed class Result<T> {
  const Result();
  
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;
  
  T? get data => this is Success<T> ? (this as Success<T>).data : null;
  String? get error => this is Failure<T> ? (this as Failure<T>).message : null;
  
  static Result<T> success<T>(T data) => Success(data);
  static Result<T> failure<T>(String message) => Failure(message);
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  final Exception? exception;
  
  const Failure(this.message, {this.exception});
}