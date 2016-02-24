import 'dart:async';
import '../request_response.dart';
import '../middleware.dart';
import '../pipeline.dart';
import 'package:stack_trace/stack_trace.dart';
import 'dart:convert';
import 'dart:io';
import '../../util/trace_formatting.dart';
import '../../util/nothing.dart';
import 'dart:mirrors';
import 'package:embla/src/http/helpers.dart';

class ErrorHandlerMiddleware extends Middleware {
  final ErrorHandlerCollection _emptyCollection = new ErrorHandlerCollection();

  Future<Response> handle(Request request) async {
    return await _emptyCollection.call(super.handle)(request);
  }

  static ErrorHandlerCollection on(Type errorType, middlewareA, [middlewareB = nothing, middlewareC = nothing,
      middlewareD = nothing, middlewareE = nothing, middlewareF = nothing, middlewareG = nothing,
      middlewareH = nothing, middlewareI = nothing, middlewareJ = nothing, middlewareK = nothing,
      middlewareL = nothing, middlewareM = nothing, middlewareN = nothing, middlewareO = nothing,
      middlewareP = nothing, middlewareQ = nothing, middlewareR = nothing, middlewareS = nothing,
      middlewareT = nothing, middlewareU = nothing, middlewareV = nothing, middlewareW = nothing,
      middlewareX = nothing, middlewareY = nothing, middlewareZ = nothing]) {
    final Iterable middlewareTokens = [middlewareA, middlewareB,
    middlewareC, middlewareD, middlewareE, middlewareF, middlewareG, middlewareH,
    middlewareI, middlewareJ, middlewareK, middlewareL, middlewareM, middlewareN,
    middlewareO, middlewareP, middlewareQ, middlewareR, middlewareS, middlewareT,
    middlewareU, middlewareV, middlewareW, middlewareX, middlewareY, middlewareZ
    ].where((m) => m != nothing);
    return new ErrorHandlerCollection({errorType: pipeActual(resolveMiddleware(middlewareTokens))});
  }
}

class ErrorHandlerCollection extends Middleware {
  final _ErrorTemplate _errorTemplate = new _ErrorTemplate();
  final Map<Type, Pipeline> _catches;

  ErrorHandlerCollection([this._catches = const {}]);

  Future<Response> handle(Request request) {
    return super.handle(request).catchError((e, s) => _catch(request, e, s)) as Future<Response>;
  }

  Future<Response> _catch(Request request, error, StackTrace stack) async {
    final mirror = reflect(error);
    for (final type in _catches.keys) {
      if (mirror.type.isAssignableTo(reflectType(type))) {
        return applyInjections({
          error.runtimeType: error,
          type: error,
          StackTrace: stack,
          Chain: new Chain.forTrace(stack)
        })(_catches[type])(request);
      }
    }
    return _errorTemplate.catchError(error, stack);
  }

  ErrorHandlerCollection on(Type errorType, middlewareA, [middlewareB = nothing, middlewareC = nothing,
      middlewareD = nothing, middlewareE = nothing, middlewareF = nothing, middlewareG = nothing,
      middlewareH = nothing, middlewareI = nothing, middlewareJ = nothing, middlewareK = nothing,
      middlewareL = nothing, middlewareM = nothing, middlewareN = nothing, middlewareO = nothing,
      middlewareP = nothing, middlewareQ = nothing, middlewareR = nothing, middlewareS = nothing,
      middlewareT = nothing, middlewareU = nothing, middlewareV = nothing, middlewareW = nothing,
      middlewareX = nothing, middlewareY = nothing, middlewareZ = nothing]) {
    final Iterable middlewareTokens = [middlewareA, middlewareB,
    middlewareC, middlewareD, middlewareE, middlewareF, middlewareG, middlewareH,
    middlewareI, middlewareJ, middlewareK, middlewareL, middlewareM, middlewareN,
    middlewareO, middlewareP, middlewareQ, middlewareR, middlewareS, middlewareT,
    middlewareU, middlewareV, middlewareW, middlewareX, middlewareY, middlewareZ
    ].where((m) => m != nothing);
    for (final type in _catches.keys) {
      if (reflectType(type).isSubtypeOf(reflectType(errorType))) {
        throw new BadErrorHandlerOrderException(
          "$type is a subtype of $errorType and should therefore be "
          "added after $errorType in the handler chain.\n\n"
          "    ErrorHandlerMiddleware\n"
          "      .on($errorType, _handle$errorType)\n"
          "      .on($type, _handle$type);\n"
        );
      }
    }
    return new ErrorHandlerCollection(
      <Type, Pipeline>{}
      ..addAll(_catches)
      ..addAll({errorType: pipeActual(resolveMiddleware(middlewareTokens))})
    );
  }
}

class _ErrorTemplate {
  _ErrorTemplate();

  static final _packagesPath = Platform.packageRoot ?? Directory.current.path + '/packages';

  static const String _hljs =
    r"""!function(e){var n="object"==typeof window&&window||"object"==typeof self&&self;"undefined"!=typeof exports?e(exports):n&&(n.hljs=e({}),"function"==typeof define&&define.amd&&define([],function(){return n.hljs}))}(function(e){function n(e){return e.replace(/&/gm,"&amp;").replace(/</gm,"&lt;").replace(/>/gm,"&gt;")}function t(e){return e.nodeName.toLowerCase()}function r(e,n){var t=e&&e.exec(n);return t&&0==t.index}function a(e){return/^(no-?highlight|plain|text)$/i.test(e)}function i(e){var n,t,r,i=e.className+" ";if(i+=e.parentNode?e.parentNode.className:"",t=/\blang(?:uage)?-([\w-]+)\b/i.exec(i))return w(t[1])?t[1]:"no-highlight";for(i=i.split(/\s+/),n=0,r=i.length;r>n;n++)if(w(i[n])||a(i[n]))return i[n]}function o(e,n){var t,r={};for(t in e)r[t]=e[t];if(n)for(t in n)r[t]=n[t];return r}function u(e){var n=[];return function r(e,a){for(var i=e.firstChild;i;i=i.nextSibling)3==i.nodeType?a+=i.nodeValue.length:1==i.nodeType&&(n.push({event:"start",offset:a,node:i}),a=r(i,a),t(i).match(/br|hr|img|input/)||n.push({event:"stop",offset:a,node:i}));return a}(e,0),n}function c(e,r,a){function i(){return e.length&&r.length?e[0].offset!=r[0].offset?e[0].offset<r[0].offset?e:r:"start"==r[0].event?e:r:e.length?e:r}function o(e){function r(e){return" "+e.nodeName+'="'+n(e.value)+'"'}f+="<"+t(e)+Array.prototype.map.call(e.attributes,r).join("")+">"}function u(e){f+="</"+t(e)+">"}function c(e){("start"==e.event?o:u)(e.node)}for(var s=0,f="",l=[];e.length||r.length;){var g=i();if(f+=n(a.substr(s,g[0].offset-s)),s=g[0].offset,g==e){l.reverse().forEach(u);do c(g.splice(0,1)[0]),g=i();while(g==e&&g.length&&g[0].offset==s);l.reverse().forEach(o)}else"start"==g[0].event?l.push(g[0].node):l.pop(),c(g.splice(0,1)[0])}return f+n(a.substr(s))}function s(e){function n(e){return e&&e.source||e}function t(t,r){return new RegExp(n(t),"m"+(e.cI?"i":"")+(r?"g":""))}function r(a,i){if(!a.compiled){if(a.compiled=!0,a.k=a.k||a.bK,a.k){var u={},c=function(n,t){e.cI&&(t=t.toLowerCase()),t.split(" ").forEach(function(e){var t=e.split("|");u[t[0]]=[n,t[1]?Number(t[1]):1]})};"string"==typeof a.k?c("keyword",a.k):Object.keys(a.k).forEach(function(e){c(e,a.k[e])}),a.k=u}a.lR=t(a.l||/\b\w+\b/,!0),i&&(a.bK&&(a.b="\\b("+a.bK.split(" ").join("|")+")\\b"),a.b||(a.b=/\B|\b/),a.bR=t(a.b),a.e||a.eW||(a.e=/\B|\b/),a.e&&(a.eR=t(a.e)),a.tE=n(a.e)||"",a.eW&&i.tE&&(a.tE+=(a.e?"|":"")+i.tE)),a.i&&(a.iR=t(a.i)),void 0===a.r&&(a.r=1),a.c||(a.c=[]);var s=[];a.c.forEach(function(e){e.v?e.v.forEach(function(n){s.push(o(e,n))}):s.push("self"==e?a:e)}),a.c=s,a.c.forEach(function(e){r(e,a)}),a.starts&&r(a.starts,i);var f=a.c.map(function(e){return e.bK?"\\.?("+e.b+")\\.?":e.b}).concat([a.tE,a.i]).map(n).filter(Boolean);a.t=f.length?t(f.join("|"),!0):{exec:function(){return null}}}}r(e)}function f(e,t,a,i){function o(e,n){for(var t=0;t<n.c.length;t++)if(r(n.c[t].bR,e))return n.c[t]}function u(e,n){if(r(e.eR,n)){for(;e.endsParent&&e.parent;)e=e.parent;return e}return e.eW?u(e.parent,n):void 0}function c(e,n){return!a&&r(n.iR,e)}function g(e,n){var t=N.cI?n[0].toLowerCase():n[0];return e.k.hasOwnProperty(t)&&e.k[t]}function p(e,n,t,r){var a=r?"":E.classPrefix,i='<span class="'+a,o=t?"":"</span>";return i+=e+'">',i+n+o}function h(){if(!k.k)return n(M);var e="",t=0;k.lR.lastIndex=0;for(var r=k.lR.exec(M);r;){e+=n(M.substr(t,r.index-t));var a=g(k,r);a?(B+=a[1],e+=p(a[0],n(r[0]))):e+=n(r[0]),t=k.lR.lastIndex,r=k.lR.exec(M)}return e+n(M.substr(t))}function d(){var e="string"==typeof k.sL;if(e&&!R[k.sL])return n(M);var t=e?f(k.sL,M,!0,y[k.sL]):l(M,k.sL.length?k.sL:void 0);return k.r>0&&(B+=t.r),e&&(y[k.sL]=t.top),p(t.language,t.value,!1,!0)}function b(){L+=void 0!==k.sL?d():h(),M=""}function v(e,n){L+=e.cN?p(e.cN,"",!0):"",k=Object.create(e,{parent:{value:k}})}function m(e,n){if(M+=e,void 0===n)return b(),0;var t=o(n,k);if(t)return t.skip?M+=n:(t.eB&&(M+=n),b(),t.rB||t.eB||(M=n)),v(t,n),t.rB?0:n.length;var r=u(k,n);if(r){var a=k;a.skip?M+=n:(a.rE||a.eE||(M+=n),b(),a.eE&&(M=n));do k.cN&&(L+="</span>"),k.skip||(B+=k.r),k=k.parent;while(k!=r.parent);return r.starts&&v(r.starts,""),a.rE?0:n.length}if(c(n,k))throw new Error('Illegal lexeme "'+n+'" for mode "'+(k.cN||"<unnamed>")+'"');return M+=n,n.length||1}var N=w(e);if(!N)throw new Error('Unknown language: "'+e+'"');s(N);var x,k=i||N,y={},L="";for(x=k;x!=N;x=x.parent)x.cN&&(L=p(x.cN,"",!0)+L);var M="",B=0;try{for(var C,j,I=0;;){if(k.t.lastIndex=I,C=k.t.exec(t),!C)break;j=m(t.substr(I,C.index-I),C[0]),I=C.index+j}for(m(t.substr(I)),x=k;x.parent;x=x.parent)x.cN&&(L+="</span>");return{r:B,value:L,language:e,top:k}}catch(O){if(-1!=O.message.indexOf("Illegal"))return{r:0,value:n(t)};throw O}}function l(e,t){t=t||E.languages||Object.keys(R);var r={r:0,value:n(e)},a=r;return t.forEach(function(n){if(w(n)){var t=f(n,e,!1);t.language=n,t.r>a.r&&(a=t),t.r>r.r&&(a=r,r=t)}}),a.language&&(r.second_best=a),r}function g(e){return E.tabReplace&&(e=e.replace(/^((<[^>]+>|\t)+)/gm,function(e,n){return n.replace(/\t/g,E.tabReplace)})),E.useBR&&(e=e.replace(/\n/g,"<br>")),e}function p(e,n,t){var r=n?x[n]:t,a=[e.trim()];return e.match(/\bhljs\b/)||a.push("hljs"),-1===e.indexOf(r)&&a.push(r),a.join(" ").trim()}function h(e){var n=i(e);if(!a(n)){var t;E.useBR?(t=document.createElementNS("http://www.w3.org/1999/xhtml","div"),t.innerHTML=e.innerHTML.replace(/\n/g,"").replace(/<br[ \/]*>/g,"\n")):t=e;var r=t.textContent,o=n?f(n,r,!0):l(r),s=u(t);if(s.length){var h=document.createElementNS("http://www.w3.org/1999/xhtml","div");h.innerHTML=o.value,o.value=c(s,u(h),r)}o.value=g(o.value),e.innerHTML=o.value,e.className=p(e.className,n,o.language),e.result={language:o.language,re:o.r},o.second_best&&(e.second_best={language:o.second_best.language,re:o.second_best.r})}}function d(e){E=o(E,e)}function b(){if(!b.called){b.called=!0;var e=document.querySelectorAll("pre code");Array.prototype.forEach.call(e,h)}}function v(){addEventListener("DOMContentLoaded",b,!1),addEventListener("load",b,!1)}function m(n,t){var r=R[n]=t(e);r.aliases&&r.aliases.forEach(function(e){x[e]=n})}function N(){return Object.keys(R)}function w(e){return e=(e||"").toLowerCase(),R[e]||R[x[e]]}var E={classPrefix:"hljs-",tabReplace:null,useBR:!1,languages:void 0},R={},x={};return e.highlight=f,e.highlightAuto=l,e.fixMarkup=g,e.highlightBlock=h,e.configure=d,e.initHighlighting=b,e.initHighlightingOnLoad=v,e.registerLanguage=m,e.listLanguages=N,e.getLanguage=w,e.inherit=o,e.IR="[a-zA-Z]\\w*",e.UIR="[a-zA-Z_]\\w*",e.NR="\\b\\d+(\\.\\d+)?",e.CNR="(-?)(\\b0[xX][a-fA-F0-9]+|(\\b\\d+(\\.\\d*)?|\\.\\d+)([eE][-+]?\\d+)?)",e.BNR="\\b(0b[01]+)",e.RSR="!|!=|!==|%|%=|&|&&|&=|\\*|\\*=|\\+|\\+=|,|-|-=|/=|/|:|;|<<|<<=|<=|<|===|==|=|>>>=|>>=|>=|>>>|>>|>|\\?|\\[|\\{|\\(|\\^|\\^=|\\||\\|=|\\|\\||~",e.BE={b:"\\\\[\\s\\S]",r:0},e.ASM={cN:"string",b:"'",e:"'",i:"\\n",c:[e.BE]},e.QSM={cN:"string",b:'"',e:'"',i:"\\n",c:[e.BE]},e.PWM={b:/\b(a|an|the|are|I|I'm|isn't|don't|doesn't|won't|but|just|should|pretty|simply|enough|gonna|going|wtf|so|such|will|you|your|like)\b/},e.C=function(n,t,r){var a=e.inherit({cN:"comment",b:n,e:t,c:[]},r||{});return a.c.push(e.PWM),a.c.push({cN:"doctag",b:"(?:TODO|FIXME|NOTE|BUG|XXX):",r:0}),a},e.CLCM=e.C("//","$"),e.CBCM=e.C("/\\*","\\*/"),e.HCM=e.C("#","$"),e.NM={cN:"number",b:e.NR,r:0},e.CNM={cN:"number",b:e.CNR,r:0},e.BNM={cN:"number",b:e.BNR,r:0},e.CSSNM={cN:"number",b:e.NR+"(%|em|ex|ch|rem|vw|vh|vmin|vmax|cm|mm|in|pt|pc|px|deg|grad|rad|turn|s|ms|Hz|kHz|dpi|dpcm|dppx)?",r:0},e.RM={cN:"regexp",b:/\//,e:/\/[gimuy]*/,i:/\n/,c:[e.BE,{b:/\[/,e:/\]/,r:0,c:[e.BE]}]},e.TM={cN:"title",b:e.IR,r:0},e.UTM={cN:"title",b:e.UIR,r:0},e.METHOD_GUARD={b:"\\.\\s*"+e.UIR,r:0},e});hljs.registerLanguage("dart",function(e){var t={cN:"subst",b:"\\$\\{",e:"}",k:"true false null this is new super"},r={cN:"string",v:[{b:"r'''",e:"'''"},{b:'r"""
    '"""'
    "',e:'"
    '"""'
    r"""'},{b:"r'",e:"'",i:"\\n"},{b:'r"',e:'"',i:"\\n"},{b:"'''",e:"'''",c:[e.BE,t]},{b:'"""
    '"""'
    "',e:'"
    '"""'
    r"""',c:[e.BE,t]},{b:"'",e:"'",i:"\\n",c:[e.BE,t]},{b:'"',e:'"',i:"\\n",c:[e.BE,t]}]};t.c=[e.CNM,r];var n={keyword:"assert async await break case catch class const continue default do else enum extends false final finally for if in is new null rethrow return super switch sync this throw true try var void while with yield abstract as dynamic export external factory get implements import library operator part set static typedef",built_in:"print Comparable DateTime Duration Function Iterable Iterator List Map Match Null Object Pattern RegExp Set Stopwatch String StringBuffer StringSink Symbol Type Uri bool double int num document window querySelector querySelectorAll Element ElementList"};return{k:n,c:[r,e.C("/\\*\\*","\\*/",{sL:"markdown"}),e.C("///","$",{sL:"markdown"}),e.CLCM,e.CBCM,{cN:"class",bK:"class interface",e:"{",eE:!0,c:[{bK:"extends implements"},e.UTM]},e.CNM,{cN:"meta",b:"@[A-Za-z]+"},{b:"=>"}]}});""";

  static const String _style = r"""
body {
  background: #f8f8f8;
  margin: 0;
  font-family: "Roboto Slab", sans-serif;
  color: #333; }

.container {
  background: #fefefe;
  display: flex;
  flex-direction: column;
  max-width: 80em;
  margin: auto;
  height: 100vh;
  box-shadow: 0 -5em 6em -5em black; }
  .container__header {
    padding: 1rem; }
    .container__header__code {
      color: #555;
      font-size: 0.9em;
      font-family: "Cousine", monospace; }
    .container__header__heading {
      margin: 0; }
  .container__content {
    flex: 1;
    display: flex; }

.source {
  flex: 2;
  display: flex; }
  .source__pre {
    overflow: auto;
    padding: 1em;
    border-top: 1px solid rgba(51, 51, 51, 0.1);
    font-family: "Cousine", monospace;
    line-height: 1.4;
    font-size: 1.1em;
    margin: 0;
    background: #f8f8f8;
    flex: 1; }
    .source__pre:not(.active) {
      display: none; }
  .source__highlighted-line {
    background: #de4530;
    display: inline-block;
    width: 100%;
    box-shadow: -1em 0 0 0.3em #de4530, 1em 0 0 0.3em #de4530;
    color: white; }
    .source__highlighted-line * {
      color: white !important; }
  .source__line-number .hljs-number {
    color: #a2a2a2; }

.stack {
  flex: 1;
  overflow: auto; }
  .stack__list {
    margin: 0;
    list-style: none;
    padding: 0;
    font-family: "Cousine", monospace;
    cursor: pointer; }
  .stack__list__item {
    width: 100%;
    border: 0;
    background: #fefefe;
    margin: 0;
    font: inherit;
    text-align: left;
    -webkit-appearance: none;
    -moz-appearance: none;
    -ms-appearance: none;
    -o-appearance: none;
    appearance: none;
    padding: 1em;
    cursor: pointer;
    border-top: 1px solid rgba(51, 51, 51, 0.1); }
    .stack__list__item__file {
      overflow: hidden;
      white-space: nowrap;
      text-overflow: ellipsis;
      position: relative;
      display: block;
      margin-bottom: 0.2em; }
    .active .stack__list__item {
      border: 1px solid rgba(51, 51, 51, 0.1);
      background-color: #3385ff;
      color: #fefefe; }
      .active .stack__list__item:active {
        color: #fefefe; }
    .active + li .stack__list__item {
      border-top: 0; }
    .stack__list__item:active {
      color: #555; }
    .stack__list__item__function {
      margin: 0; }

/* http://jmblog.github.com/color-themes-for-google-code-highlightjs */
/* Tomorrow Comment */
.hljs-comment,
.hljs-quote {
  color: #8e908c; }

/* Tomorrow Red */
.hljs-variable,
.hljs-template-variable,
.hljs-tag,
.hljs-name,
.hljs-selector-id,
.hljs-selector-class,
.hljs-regexp,
.hljs-deletion {
  color: #c82829; }

/* Tomorrow Orange */
.hljs-number,
.hljs-built_in,
.hljs-builtin-name,
.hljs-literal,
.hljs-type,
.hljs-params,
.hljs-meta,
.hljs-link {
  color: #f5871f; }

/* Tomorrow Yellow */
.hljs-attribute {
  color: #eab700; }

/* Tomorrow Green */
.hljs-string,
.hljs-symbol,
.hljs-bullet,
.hljs-addition {
  color: #718c00; }

/* Tomorrow Blue */
.hljs-title,
.hljs-section {
  color: #4271ae; }

/* Tomorrow Purple */
.hljs-keyword,
.hljs-selector-tag {
  color: #8959a8; }

.hljs-emphasis {
  font-style: italic; }

.hljs-strong {
  font-weight: bold; }
  """;

  Future<Response> catchError(error, StackTrace stack) async {
    final code = _code(error);
    return new Response(
      code,
      body: _template(error, new Chain.forTrace(stack), code).map(UTF8.encode),
      headers: {
        'Content-Type': ContentType.HTML.toString()
      }
    );
  }

  int _code(error) {
    if (error is HttpBadRequestException) return 400;
    if (error is HttpUnauthorizedException) return 401;
    if (error is HttpPaymentRequiredException) return 402;
    if (error is HttpForbiddenException) return 403;
    if (error is HttpNotFoundException) return 404;
    if (error is HttpMethodNotAllowedException) return 405;
    if (error is HttpNotAcceptableException) return 406;
    if (error is HttpProxyAuthenticationRequiredException) return 407;
    if (error is HttpRequestTimeoutException) return 408;
    if (error is HttpConflictException) return 409;
    if (error is HttpGoneException) return 410;
    if (error is HttpLengthRequiredException) return 411;
    if (error is HttpPreconditionFailedException) return 412;
    if (error is HttpPayloadTooLargeException) return 413;
    if (error is HttpURITooLongException) return 414;
    if (error is HttpUnsupportedMediaTypeException) return 415;
    if (error is HttpRangeNotSatisfiableException) return 416;
    if (error is HttpExpectationFailedException) return 417;
    if (error is HttpImATeapotException) return 418;
    if (error is HttpAuthenticationTimeoutException) return 419;
    if (error is HttpMisdirectedRequestException) return 421;
    if (error is HttpUnprocessableEntityException) return 422;
    if (error is HttpLockedException) return 423;
    if (error is HttpFailedDependencyException) return 424;
    if (error is HttpUpgradeRequiredException) return 426;
    if (error is HttpPreconditionRequiredException) return 428;
    if (error is HttpTooManyRequestsException) return 429;
    if (error is HttpRequestHeaderFieldsTooLargeException) return 431;
    if (error is HttpInternalServerErrorException) return 500;
    if (error is HttpNotImplementedException) return 501;
    if (error is HttpBadGatewayException) return 502;
    if (error is HttpServiceUnavailableException) return 503;
    if (error is HttpGatewayTimeoutException) return 504;
    if (error is HttpVersionNotSupportedException) return 505;
    if (error is HttpVariantAlsoNegotiatesException) return 506;
    if (error is HttpInsufficientStorageException) return 507;
    if (error is HttpLoopDetectedException) return 508;
    if (error is HttpNotExtendedException) return 510;
    if (error is HttpNetworkAuthenticationRequiredException) return 511;
    return 500;
  }

  String _esc(input) {
    return input.toString()
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
  }

  Stream<String> _template(error, Chain chain, int statusCode) async* {
    final formatter = new TraceFormatter(chain);
    final List<Frame> frames = formatter.frames.reversed.toList();
    final String message = error.toString() == "Instance of '${error.runtimeType}'"
      ? error.runtimeType.toString()
      : error.toString();

    yield '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width">
  <title>$statusCode – ${_esc(message)}</title>
  <style>$_style</style>
  <link href='https://fonts.googleapis.com/css?family=Roboto+Slab:400,700,300,100|Cousine:400,700italic,700,400italic' rel='stylesheet' type='text/css'>
  <script>$_hljs</script>
  <script>hljs.initHighlightingOnLoad();</script>
</head>
<body>
  <div class="container">
    <header class="container__header">
      <small class="container__header__code">Error $statusCode</small>
      <h1 class="container__header__heading">${_esc(message)}</h1>
    </header>
    <div class="container__content">
      <aside class="stack">
        <ul class="stack__list">
          ${frames.map((Frame frame) {
            final index = frames.indexOf(frame);
            return """<li class="${index == 0 ? 'active' : ''}">
              <button class="stack__list__item" id="stack-frame-$index">
                <small class="stack__list__item__file">
                  ${_esc(frame.uri.path.replaceFirst(Directory.current.path+'/', ''))}
                </small>
                <h5 class="stack__list__item__function">
                  ${_esc(frame.member)}
                </h5>
              </button>
            </li>""";
          }).join()}
        </ul>
      </aside>
      <main class="source">''';

        for (final Frame frame in frames) {
          final index = frames.indexOf(frame);
          final uri = _resolveUri(frame.uri);
          final Stream<String> file = uri == null ? new Stream.empty() : new File.fromUri(uri).openRead().map(UTF8.decode).map((s) => _esc(s));
          yield '<pre class="source__pre ${index == 0 ? 'active' : ''}" id="source-for-stack-frame-$index"><code class="dart">';
          var line = 0;
          final lines = (await file.join()).split('\n');
          final lineColumnWidth = lines.length.toString().length + 1;
          yield lines.map((s) {
            line++;
            final linePrefix = '<span class="source__line-number">${line.toString().padRight(lineColumnWidth)}</span>';
            if (line == frame.line) {
              return '<span class="source__highlighted-line">$linePrefix $s</span>';
            }
            return '$linePrefix $s';
          }).join('\n');
          yield '</code></pre>';
        }

    yield '''
      </main>
    </div>
  </div>

  <script>
    var items = Array.prototype.slice.call(document.querySelectorAll(".stack__list__item"));
    var activeItem = document.querySelector(".stack__list .active");
    var sources = Array.prototype.slice.call(document.querySelectorAll(".source__pre"))
    var activeSource = document.querySelector(".source__pre.active");
    centerHighlight();
    items.forEach(function(i) {
      i.addEventListener("click", function() {
        removeActive(activeItem);
        removeActive(activeSource);
        activeItem = i.parentNode;
        activeSource = document.querySelector("#source-for-" + i.id);
        addActive(activeItem);
        addActive(activeSource);
        centerHighlight();
      });
    });

    function centerHighlight() {
      var highlight;
      if (highlight = activeSource.querySelector('.source__highlighted-line')) {
        activeSource.scrollTop = highlight.getBoundingClientRect().top + activeSource.scrollTop - 200;
      } else {
        activeSource.scrollTop = 0;
      }
    }

    function removeActive(element) {
      element.className = element.className.replace(/active/, '');
    }

    function addActive(element) {
      element.className += " active";
    }
  </script>
</body>
</html>

    ''';
  }

  Uri _resolveUri(Uri input) {
    if (input.scheme == 'dart' || !input.path.endsWith('.dart')) {
      return null;
    }
    if (input.scheme == 'package') {
      return Uri.parse('$_packagesPath/${input.path}');
    }
    return input;
  }
}

class BadErrorHandlerOrderException implements Exception {
  final String message;

  BadErrorHandlerOrderException(this.message);

  String toString() => 'BadErrorHandlerOrderException: $message';
}
