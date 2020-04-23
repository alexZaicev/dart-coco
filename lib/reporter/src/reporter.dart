part of dart_coco.reporter;

abstract class Reporter {
  static final _logger = Logger('Reporter');
  static String PROJECT_ROOT = null;

  String get projectRoot {
    if (PROJECT_ROOT == null) {
      PROJECT_ROOT = Platform.script.path;
      if (Platform.isWindows) {
        PROJECT_ROOT = PROJECT_ROOT.replaceAll('/', p.separator).substring(1);
      }
      PROJECT_ROOT = PROJECT_ROOT.replaceAll('${p.separator}bin${p.separator}dart_coco.dart', '');
    }
    return PROJECT_ROOT;
  }

  Directory get outputDir => _outputDir;

  String get root => _root;

  Directory _outputDir;

  String _root;

  Reporter(final Directory outputDir, final String root) {
    _outputDir = outputDir;
    _root = root;
  }

  Future<void> generateReport(final ReportData data);

  static ReportData generateReportData(final AnalysisData analysisData, final LcovData lcovData) {
    final reportData = ReportData(timestamp: DateTime.now().toUtc().toIso8601String(), packages: {});

    // process analysis data
    _processAnalysisData(reportData, analysisData);
    // process LCOV data
    if (lcovData != null) {
      _processLcovData(reportData, lcovData);
    }

    return reportData;
  }

  static void _processAnalysisData(final ReportData report, final AnalysisData analysis) {
    report.summary ??= ReportSummary();
    report.summary.complexity = analysis.summary.complexity;

    for (final package in analysis.packages.keys) {
      final ap = analysis.packages[package];
      report.packages[package] ??= ReportPackage();
      report.packages[package].complexity = ap.complexity;

      for (final clazz in ap.classes.keys) {
        final ac = ap.classes[clazz];
        report.packages[package].classes ??= {};
        report.packages[package].classes[clazz] ??= ReportFile();
        report.packages[package].classes[clazz].complexity = ac.complexity;

        for (final method in ac.methods.keys) {
          final am = ac.methods[method];
          report.packages[package].classes[clazz].methods ??= {};
          report.packages[package].classes[clazz].methods[method] ??= ReportMethod();
          report.packages[package].classes[clazz].methods[method].complexity = am.complexity;
        }
      }
    }
  }

  static void _processLcovData(final ReportData report, final LcovData lcov) {
    report.summary ??= ReportSummary();
    report.summary.linesTotal = lcov.summary.linesTotal;
    report.summary.linesCovered = lcov.summary.linesCovered;
    report.summary.branchesTotal = lcov.summary.branchesTotal;
    report.summary.branchesCovered = lcov.summary.branchesCovered;

    for (final package in lcov.packages.keys) {
      final lp = lcov.packages[package];
      report.packages[package] ??= ReportPackage();
      report.packages[package].linesTotal = lp.linesTotal;
      report.packages[package].linesCovered = lp.linesCovered;
      report.packages[package].branchesTotal = lp.branchesTotal;
      report.packages[package].branchesCovered = lp.branchesCovered;

      for (final clazz in lp.classes.keys) {
        final lc = lp.classes[clazz];
        report.packages[package].classes ??= {};
        report.packages[package].classes[clazz] ??= ReportFile();
        report.packages[package].classes[clazz].linesTotal = lc.linesTotal;
        report.packages[package].classes[clazz].linesCovered = lc.linesCovered;
        report.packages[package].classes[clazz].branchesTotal = lc.branchesTotal;
        report.packages[package].classes[clazz].branchesCovered = lc.branchesCovered;
        report.packages[package].classes[clazz].linesHits = lc.linesHits;

        // TODO: add method coverage
        report.packages[package].classes[clazz].methods ??= {};
      }
    }
  }
}
