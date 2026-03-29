
class Result<T, U> {
  U? _error;
  T? _value;

  Result.success(T value) {
    this._value = value;
  }

  Result.error(U error) {
    this._error = error;
  }

  bool isError() {
    return _value == null;
  }

  bool isSuccess() {
    return _value != null;
  }

  T? getValue() {
    if (_value == null) throw TypeError();
    return _value;
  }

  U? getErrorMsg() {
    if (_error == null) throw TypeError();
    return _error;
  }
}

class DataError {
  final String message;
  final int errorCode;
  final dynamic data;

  DataError(this.message, this.errorCode,this.data);
}