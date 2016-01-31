class RouteExpander {

  String expand(String input, {bool excludeStar: false}) {
    return [input]
        .map(_normalizeSlashes)
        .map((_) => _expandStars(_, excludeStar))
        .map(_expandWildcards)
        .map((_) => _exact(_, excludeStar))
        .first;
  }

  String _exact(String input, bool excludeStar) {
    if (excludeStar)
      return '^$input';
    return '^$input\$';
  }

  String _expandWildcards(String input) {
    return input.replaceAll(new RegExp(r':\w+'), r'([^/]+)');
  }

  String _normalizeSlashes(String input) {
    return input.split('/').where((s) => s.isNotEmpty).join(r'\/');
  }

  String _expandStars(String input, bool exclude) {
    return input
        .replaceAll(new RegExp(r'^\*$'), exclude ? '' : r'\/?(.*)')
        .replaceAll(new RegExp(r'\\\/\*$'), exclude ? '' : r'\/?(.*)');
  }

  String prefix(String pattern, String path) {
    final regex = new RegExp(expand(pattern));
    final regexWithoutStar = new RegExp(expand(pattern, excludeStar: true));
    final match = regex.firstMatch(path);
    if (match == null) throw new Exception('The route doesn\'t match');
    return regexWithoutStar.firstMatch(path)[0];
  }

  Map<String, String> parseWildcards(String pattern, String url) {
    final patterns = pattern.split('/').iterator;
    final parts = url.split('/').iterator;
    final output = {};
    while(patterns.moveNext()) {
      if (!parts.moveNext()) break;
      if (!patterns.current.startsWith(':')) continue;

      output[patterns.current.substring(1)] = parts.current;
    }
    return new Map<String, String>.unmodifiable(output);
  }
}