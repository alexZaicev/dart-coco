part of dart_coco.reporter;

class Assets {
  static final Map<String, String> _assetResources = {
    'main.css': MAIN_CSS,
    'report.js': REPORT_SCRIPT,
    'source.css': SOURCE_CSS,
    'source.js': SOURCE_SCRIPT,
    'greenbar.svg': GREENBAR_SVG,
    'redbar.svg': REDBAR_SVG,
    'report_template.html': REPORT_TEMPLATE,
    'report_source_template.html': REPORT_SOURCE_TEMPLATE,
  };

  static String getResource(final String name) {
    if (!_assetResources.containsKey(name)) {
      throw new ArgumentError('Resource [$name] in not present in dart-coco available asset set');
    }
    return _assetResources[name];
  }

  static List<String> getAvailableResources() => _assetResources.keys.toList(growable: false);

  static String getReportTemplate() => getResource('report_template.html');

  static String getReportSourceTemplate() => getResource('report_source_template.html');
}
