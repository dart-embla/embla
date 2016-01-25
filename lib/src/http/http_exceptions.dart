class HttpException implements Exception {
  final int statusCode;
  final body;

  HttpException._(this.statusCode, this.body);

  factory HttpException(int statusCode, [body]) {
    if (statusCode == 400) return new HttpBadRequestException(body);
    if (statusCode == 401) return new HttpUnauthorizedException(body);
    if (statusCode == 402) return new HttpPaymentRequiredException(body);
    if (statusCode == 403) return new HttpForbiddenException(body);
    if (statusCode == 404) return new HttpNotFoundException(body);
    if (statusCode == 405) return new HttpMethodNotAllowedException(body);
    if (statusCode == 406) return new HttpNotAcceptableException(body);
    if (statusCode == 407) return new HttpProxyAuthenticationRequiredException(body);
    if (statusCode == 408) return new HttpRequestTimeoutException(body);
    if (statusCode == 409) return new HttpConflictException(body);
    if (statusCode == 410) return new HttpGoneException(body);
    if (statusCode == 411) return new HttpLengthRequiredException(body);
    if (statusCode == 412) return new HttpPreconditionFailedException(body);
    if (statusCode == 413) return new HttpPayloadTooLargeException(body);
    if (statusCode == 414) return new HttpURITooLongException(body);
    if (statusCode == 415) return new HttpUnsupportedMediaTypeException(body);
    if (statusCode == 416) return new HttpRangeNotSatisfiableException(body);
    if (statusCode == 417) return new HttpExpectationFailedException(body);
    if (statusCode == 418) return new HttpImATeapotException(body);
    if (statusCode == 419) return new HttpAuthenticationTimeoutException(body);
    if (statusCode == 421) return new HttpMisdirectedRequestException(body);
    if (statusCode == 422) return new HttpUnprocessableEntityException(body);
    if (statusCode == 423) return new HttpLockedException(body);
    if (statusCode == 424) return new HttpFailedDependencyException(body);
    if (statusCode == 426) return new HttpUpgradeRequiredException(body);
    if (statusCode == 428) return new HttpPreconditionRequiredException(body);
    if (statusCode == 429) return new HttpTooManyRequestsException(body);
    if (statusCode == 431) return new HttpRequestHeaderFieldsTooLargeException(body);
    if (statusCode == 500) return new HttpInternalServerErrorException(body);
    if (statusCode == 501) return new HttpNotImplementedException(body);
    if (statusCode == 502) return new HttpBadGatewayException(body);
    if (statusCode == 503) return new HttpServiceUnavailableException(body);
    if (statusCode == 504) return new HttpGatewayTimeoutException(body);
    if (statusCode == 505) return new HttpVersionNotSupportedException(body);
    if (statusCode == 506) return new HttpVariantAlsoNegotiatesException(body);
    if (statusCode == 507) return new HttpInsufficientStorageException(body);
    if (statusCode == 508) return new HttpLoopDetectedException(body);
    if (statusCode == 510) return new HttpNotExtendedException(body);
    if (statusCode == 511) return new HttpNetworkAuthenticationRequiredException(body);
    return new HttpException._(statusCode, body);
  }

  String toString() => '$runtimeType: $body';
}

class HttpBadRequestException extends HttpException {
  HttpBadRequestException([body]) : super._(400, body ?? 'Bad Request');
}

class HttpUnauthorizedException extends HttpException {
  HttpUnauthorizedException([body]) : super._(401, body ?? 'Unauthorized');
}

class HttpPaymentRequiredException extends HttpException {
  HttpPaymentRequiredException([body]) : super._(402, body ?? 'Payment Required');
}

class HttpForbiddenException extends HttpException {
  HttpForbiddenException([body]) : super._(403, body ?? 'Forbidden');
}

class HttpNotFoundException extends HttpException {
  HttpNotFoundException([body]) : super._(404, body ?? 'Not Found');
}

class HttpMethodNotAllowedException extends HttpException {
  HttpMethodNotAllowedException([body]) : super._(405, body ?? 'Method Not Allowed');
}

class HttpNotAcceptableException extends HttpException {
  HttpNotAcceptableException([body]) : super._(406, body ?? 'Not Acceptable');
}

class HttpProxyAuthenticationRequiredException extends HttpException {
  HttpProxyAuthenticationRequiredException([body]) : super._(407, body ?? 'Proxy Authentication Required');
}

class HttpRequestTimeoutException extends HttpException {
  HttpRequestTimeoutException([body]) : super._(408, body ?? 'Request Timeout');
}

class HttpConflictException extends HttpException {
  HttpConflictException([body]) : super._(409, body ?? 'Conflict');
}

class HttpGoneException extends HttpException {
  HttpGoneException([body]) : super._(410, body ?? 'Gone');
}

class HttpLengthRequiredException extends HttpException {
  HttpLengthRequiredException([body]) : super._(411, body ?? 'Length Required');
}

class HttpPreconditionFailedException extends HttpException {
  HttpPreconditionFailedException([body]) : super._(412, body ?? 'Precondition Failed');
}

class HttpPayloadTooLargeException extends HttpException {
  HttpPayloadTooLargeException([body]) : super._(413, body ?? 'Payload Too Large');
}

class HttpURITooLongException extends HttpException {
  HttpURITooLongException([body]) : super._(414, body ?? 'URI Too Long');
}

class HttpUnsupportedMediaTypeException extends HttpException {
  HttpUnsupportedMediaTypeException([body]) : super._(415, body ?? 'Unsupported Media Type');
}

class HttpRangeNotSatisfiableException extends HttpException {
  HttpRangeNotSatisfiableException([body]) : super._(416, body ?? 'Range Not Satisfiable');
}

class HttpExpectationFailedException extends HttpException {
  HttpExpectationFailedException([body]) : super._(417, body ?? 'Expectation Failed');
}

class HttpImATeapotException extends HttpException {
  HttpImATeapotException([body]) : super._(418, body ?? 'I\'m a Teapot');
}

class HttpAuthenticationTimeoutException extends HttpException {
  HttpAuthenticationTimeoutException([body]) : super._(419, body ?? 'Authentication Timeout');
}

class HttpMisdirectedRequestException extends HttpException {
  HttpMisdirectedRequestException([body]) : super._(421, body ?? 'Misdirected Request');
}

class HttpUnprocessableEntityException extends HttpException {
  HttpUnprocessableEntityException([body]) : super._(422, body ?? 'Unprocessable Entity');
}

class HttpLockedException extends HttpException {
  HttpLockedException([body]) : super._(423, body ?? 'Locked');
}

class HttpFailedDependencyException extends HttpException {
  HttpFailedDependencyException([body]) : super._(424, body ?? 'Failed Dependency');
}

class HttpUpgradeRequiredException extends HttpException {
  HttpUpgradeRequiredException([body]) : super._(426, body ?? 'Upgrade Required');
}

class HttpPreconditionRequiredException extends HttpException {
  HttpPreconditionRequiredException([body]) : super._(428, body ?? 'Precondition Required');
}

class HttpTooManyRequestsException extends HttpException {
  HttpTooManyRequestsException([body]) : super._(429, body ?? 'Too Many Requests');
}

class HttpRequestHeaderFieldsTooLargeException extends HttpException {
  HttpRequestHeaderFieldsTooLargeException([body]) : super._(431, body ?? 'Request Header Fields Too Large');
}

class HttpInternalServerErrorException extends HttpException {
  HttpInternalServerErrorException([body]) : super._(500, body ?? 'Internal Server Error');
}

class HttpNotImplementedException extends HttpException {
  HttpNotImplementedException([body]) : super._(501, body ?? 'Not Implemented');
}

class HttpBadGatewayException extends HttpException {
  HttpBadGatewayException([body]) : super._(502, body ?? 'Bad Gateway');
}

class HttpServiceUnavailableException extends HttpException {
  HttpServiceUnavailableException([body]) : super._(503, body ?? 'Service Unavailable');
}

class HttpGatewayTimeoutException extends HttpException {
  HttpGatewayTimeoutException([body]) : super._(504, body ?? 'Gateway Timeout');
}

class HttpVersionNotSupportedException extends HttpException {
  HttpVersionNotSupportedException([body]) : super._(505, body ?? 'HTTP Version Not Supported');
}

class HttpVariantAlsoNegotiatesException extends HttpException {
  HttpVariantAlsoNegotiatesException([body]) : super._(506, body ?? 'Variant Also Negotiates');
}

class HttpInsufficientStorageException extends HttpException {
  HttpInsufficientStorageException([body]) : super._(507, body ?? 'Insufficient Storage');
}

class HttpLoopDetectedException extends HttpException {
  HttpLoopDetectedException([body]) : super._(508, body ?? 'Loop Detected');
}

class HttpNotExtendedException extends HttpException {
  HttpNotExtendedException([body]) : super._(510, body ?? 'Not Extended');
}

class HttpNetworkAuthenticationRequiredException extends HttpException {
  HttpNetworkAuthenticationRequiredException([body]) : super._(511, body ?? 'Network Authentication Required');
}
