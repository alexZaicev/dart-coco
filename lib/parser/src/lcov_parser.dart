part of dart_coco.parser;

class LcovParser extends Parser {
  static final _logger = Logger('LcovParser');
  static const String SOURCE_FILE = 'SF';
  static const String FUNCTION_DATA = 'FN';
  static const String FUNCTION_COVERAGE = 'FNDA';
  static const String BRANCH_COVERAGE = 'BRDA';
  static const String BRANCH_FOUND = 'BRF';
  static const String BRANCH_HIT = 'BRH';
  static const String COVERAGE = 'DA';
  static const String LINES_FOUND = 'LF';
  static const String LINES_HIT = 'LH';
  static const String END_OF_RECORD = 'end_of_record';

  String packageName;
  String className;
  int linesTotal = 0;
  int linesCovered = 0;
  int branchTotal = 0;
  int branchCovered = 0;

  final Map<int, int> linesHits = {};

  @override
  Future<LcovData> convert(final String lcov) async {
    final Map<String, LcovPackage> packages = {};
    final LcovSummary summary = LcovSummary();

    for (String line in lcov.split('\n')) {
      // remove unnecessary spacings from line
      line = line.replaceAll(' ', '');
      // check if coverage record ended
      if (line == END_OF_RECORD) {
        // save record & reset
        _saveRecord(packages, summary);
        _reset();
      }
      // process LCOV line
      final tokens = line.split(':');
      final data = tokens.last;
      switch (tokens.first) {
        case SOURCE_FILE:
          {
            _sourceFileAction(data);
            break;
          }
        case COVERAGE:
          {
            _coverageAction(data);
            break;
          }
        case LINES_FOUND:
          {
            _linesFoundAction(data);
            break;
          }
        case LINES_HIT:
          {
            _linesHitAction(data);
            break;
          }
        case BRANCH_FOUND:
        case BRANCH_COVERAGE:
        case BRANCH_HIT:
        case FUNCTION_DATA:
        case FUNCTION_COVERAGE:
          break;
      }
    }

    return LcovData(timestamp: DateTime.now().toUtc().toIso8601String(), packages: packages, summary: summary);
  }

  void _linesFoundAction(final String data) {
    final int total = int.tryParse(data);
    if (total == null) {
      _logger.e('Lines found data contained invalid integer value [$data]');
      return;
    }
    linesTotal = total;
  }

  void _linesHitAction(final String data) {
    final int total = int.tryParse(data);
    if (total == null) {
      _logger.e('Lines hit data contained invalid integer value [$data]');
      return;
    }
    linesCovered = total;
  }

  void _sourceFileAction(final String data) {
    final pathTokens = data.split(p.separator);
    packageName ??= '';
    className = pathTokens.last;
    for (int i = 0; i < pathTokens.length - 1; ++i) {
      packageName = p.join(packageName, pathTokens[i]);
    }
  }

  void _coverageAction(final String data) {
    final tokens = data.split(',');
    final int lineNum = int.tryParse(tokens.first);
    final int hits = int.tryParse(tokens.last);
    if (lineNum == null || hits == null) {
      _logger.e('Coverage data contained invalid integer values [$data]');
      return;
    }
    linesHits[lineNum] ??= 0;
    linesHits[lineNum] += hits;
  }

  void _saveRecord(final Map<String, LcovPackage> packages, final LcovSummary summary) {
    packages[packageName] ??= LcovPackage();
    packages[packageName].linesTotal += linesTotal;
    packages[packageName].linesCovered += linesCovered;

    packages[packageName].classes ??= Map<String, LcovFile>();
    packages[packageName].classes[className] ??= LcovFile();
    packages[packageName].classes[className].linesTotal += linesTotal;
    packages[packageName].classes[className].linesCovered += linesCovered;
    packages[packageName].classes[className].branchesTotal += branchTotal;
    packages[packageName].classes[className].branchesCovered += branchCovered;

    packages[packageName].classes[className].linesHits ??= {};
    for (final lineNum in linesHits.keys) {
      packages[packageName].classes[className].linesHits[lineNum] ??= 0;
      packages[packageName].classes[className].linesHits[lineNum] += linesHits[lineNum];
    }

    summary.linesTotal += linesTotal;
    summary.linesCovered += linesCovered;
    summary.branchesTotal += branchTotal;
    summary.branchesCovered += branchCovered;
  }

  void _reset() {
    linesTotal = 0;
    linesCovered = 0;
    branchTotal = 0;
    branchCovered = 0;

    linesHits.clear();

    packageName = null;
    className = null;
  }
}

class LcovData {
  String timestamp;
  LcovSummary summary;
  Map<String, LcovPackage> packages;

  LcovData({this.timestamp, this.summary, this.packages});
}

class LcovPackage {
  int linesTotal;
  int linesCovered;
  int branchesTotal;
  int branchesCovered;
  Map<String, LcovFile> classes;

  LcovPackage({this.linesTotal = 0, this.linesCovered = 0, this.branchesTotal = 0, this.branchesCovered = 0, this.classes});
}

class LcovFile {
  int linesTotal;
  int linesCovered;
  Map<int, int> linesHits;
  int branchesTotal;
  int branchesCovered;

  LcovFile({this.linesTotal = 0, this.linesCovered = 0, this.linesHits, this.branchesTotal = 0, this.branchesCovered = 0});
}

class LcovSummary {
  int linesTotal;
  int linesCovered;
  int branchesTotal;
  int branchesCovered;

  LcovSummary({this.branchesCovered = 0, this.branchesTotal = 0, this.linesCovered = 0, this.linesTotal = 0});
}
