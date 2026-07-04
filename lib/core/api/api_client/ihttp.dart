class IHttp {
  get({String? url, String? token, Map? query}) {}

  post({String? url, dynamic data, Map? query, String? token}) {}

  delete({String? url, String? token}) {}

  patch({String? url, dynamic data, String? token}) {}

  put({String? url, dynamic data, String? token}) {}
}
