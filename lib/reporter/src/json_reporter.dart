part of dart_coco.reporter;

class JsonReporter extends Reporter {
  static final Logger _logger = Logger('JsonReporter');

  JsonReporter(final Directory output, final String root) : super(output, root);

  @override
  Future<void> generateReport(final ReportData data) async {
    _logger.d('Encoding data...');
    final map = data.toMap();
    final jsonStr = jsonEncode(map);
    _logger.d('Data encoded successfully!');
    _logger.d(jsonStr);

    _logger.d('Creating JSON report...');
    final File f = File(p.join(_outputDir.path, 'dart_coco.json'));
    await f.create();
    await f.writeAsString(jsonStr);
    _logger.d('JSON report created successfully!');
  }
}
