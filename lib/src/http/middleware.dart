import 'dart:async';

import 'package:shelf/shelf.dart' as shelf hide Request, Response;

import 'http_exceptions.dart';
import 'response_maker.dart';

export 'http_exceptions.dart';
export 'request_response.dart';
import 'request_response.dart';

import 'context.dart' as http_context;

class Middleware {
  final ResponseMaker _responseMaker = new ResponseMaker();
  shelf.Handler _innerHandler;

  http_context.HttpContext get context => http_context.context;

  abort([int statusCode = 500, body = 'Something went wrong']) {
    throw new HttpException(statusCode, body);
  }

  abortAuthenticationTimeout([body = 'Authentication Timeout']) {
    throw new HttpAuthenticationTimeoutException(body);
  }

  abortBadGateway([body = 'Bad Gateway']) {
    throw new HttpBadGatewayException(body);
  }

  abortBadRequest([body = 'Bad Request']) {
    throw new HttpBadRequestException(body);
  }

  abortConflict([body = 'Conflict']) {
    throw new HttpConflictException(body);
  }

  abortExpectationFailed([body = 'Expectation Failed']) {
    throw new HttpExpectationFailedException(body);
  }

  abortFailedDependency([body = 'Failed Dependency']) {
    throw new HttpFailedDependencyException(body);
  }

  abortForbidden([body = 'Forbidden']) {
    throw new HttpForbiddenException(body);
  }

  abortGatewayTimeout([body = 'Gateway Timeout']) {
    throw new HttpGatewayTimeoutException(body);
  }

  abortGone([body = 'Gone']) {
    throw new HttpGoneException(body);
  }

  abortImATeapot([body = 'I\'m a Teapot']) {
    throw new HttpImATeapotException(body);
  }

  abortInsufficientStorage([body = 'Insufficient Storage']) {
    throw new HttpInsufficientStorageException(body);
  }

  abortInternalServerError([body = 'Internal Server Error']) {
    throw new HttpInternalServerErrorException(body);
  }

  abortLengthRequired([body = 'Length Required']) {
    throw new HttpLengthRequiredException(body);
  }

  abortLocked([body = 'Locked']) {
    throw new HttpLockedException(body);
  }

  abortLoopDetected([body = 'Loop Detected']) {
    throw new HttpLoopDetectedException(body);
  }

  abortMethodNotAllowed([body = 'Method Not Allowed']) {
    throw new HttpMethodNotAllowedException(body);
  }

  abortMisdirectedRequest([body = 'Misdirected Request']) {
    throw new HttpMisdirectedRequestException(body);
  }

  abortNetworkAuthenticationRequired(
      [body = 'Network Authentication Required']) {
    throw new HttpNetworkAuthenticationRequiredException(body);
  }

  abortNotAcceptable([body = 'Not Acceptable']) {
    throw new HttpNotAcceptableException(body);
  }

  abortNotExtended([body = 'Not Extended']) {
    throw new HttpNotExtendedException(body);
  }

  abortNotFound([body = 'Not Found']) {
    throw new HttpNotFoundException(body);
  }

  abortNotImplemented([body = 'Not Implemented']) {
    throw new HttpNotImplementedException(body);
  }

  abortPayloadTooLarge([body = 'Payload Too Large']) {
    throw new HttpPayloadTooLargeException(body);
  }

  abortPaymentRequired([body = 'Payment Required']) {
    throw new HttpPaymentRequiredException(body);
  }

  abortPreconditionFailed([body = 'Precondition Failed']) {
    throw new HttpPreconditionFailedException(body);
  }

  abortPreconditionRequired([body = 'Precondition Required']) {
    throw new HttpPreconditionRequiredException(body);
  }

  abortProxyAuthenticationRequired([body = 'Proxy Authentication Required']) {
    throw new HttpProxyAuthenticationRequiredException(body);
  }

  abortRangeNotSatisfiable([body = 'Range Not Satisfiable']) {
    throw new HttpRangeNotSatisfiableException(body);
  }

  abortRequestHeaderFieldsTooLarge([body = 'Request Header Fields Too Large']) {
    throw new HttpRequestHeaderFieldsTooLargeException(body);
  }

  abortRequestTimeout([body = 'Request Timeout']) {
    throw new HttpRequestTimeoutException(body);
  }

  abortServiceUnavailable([body = 'Service Unavailable']) {
    throw new HttpServiceUnavailableException(body);
  }

  abortTooManyRequests([body = 'Too Many Requests']) {
    throw new HttpTooManyRequestsException(body);
  }

  abortUnauthorized([body = 'Unauthorized']) {
    throw new HttpUnauthorizedException(body);
  }

  abortUnprocessableEntity([body = 'Unprocessable Entity']) {
    throw new HttpUnprocessableEntityException(body);
  }

  abortUnsupportedMediaType([body = 'Unsupported Media Type']) {
    throw new HttpUnsupportedMediaTypeException(body);
  }

  abortUpgradeRequired([body = 'Upgrade Required']) {
    throw new HttpUpgradeRequiredException(body);
  }

  abortURITooLong([body = 'URI Too Long']) {
    throw new HttpURITooLongException(body);
  }

  abortVariantAlsoNegotiates([body = 'Variant Also Negotiates']) {
    throw new HttpVariantAlsoNegotiatesException(body);
  }

  abortVersionNotSupported([body = 'HTTP Version Not Supported']) {
    throw new HttpVersionNotSupportedException(body);
  }

  shelf.Handler call(shelf.Handler innerHandler) {
    _innerHandler = innerHandler;
    return handle;
  }

  Future<Response> handle(Request request) async {
    return await _innerHandler(request);
  }

  Response ok(anything) {
    return _responseMaker.parse(anything).status(200);
  }

  Response redirect(String location) {
    return new Response.found(location);
  }

  Response redirectPermanently(String location) {
    return new Response.movedPermanently(location);
  }
}
