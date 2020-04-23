import 'dart:io';

import 'package:args/args.dart';
import 'package:dart_coco/dart_coco.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

final _logger = Logger('Dart-CoCo');
const String DEFAULT_ROOT = 'lib';
const String DEFAULT_OUT = 'report';
final String DEFAULT_LCOV = 'coverage${p.separator}lcov.info';

Future<void> main(List<String> args) async {
  var parser = new ArgParser();
  parser.addOption('output', abbr: 'o', defaultsTo: DEFAULT_OUT, help: 'Generated report output location');
  parser.addOption('root', abbr: 'r', defaultsTo: DEFAULT_ROOT, help: 'Root path from which all dart files will be analyzed');
  parser.addOption('lcov',
      defaultsTo: DEFAULT_LCOV,
      help: 'Path to [lcov.info] file. If file is provided, report will include coverage data collected inside LCOV file');
  parser.addFlag('verbose', abbr: 'v', help: 'Enable debug logging');
  parser.addFlag('help', abbr: 'h', help: 'Print out help page for Dart-CoCo');
  parser.addFlag('html', help: 'HTML report format');
  parser.addFlag('json', help: 'JSON report format');

  try {
    var arguments = parser.parse(args);
    Logger.logLevel = arguments.wasParsed('verbose') ? LogLevel.DEBUG : LogLevel.INFO;

    if (arguments.wasParsed('help')) {
      _help(parser);
      return;
    }
    if (!arguments.wasParsed('html') && !arguments.wasParsed('json')) {
      _logger.e('Report format not provided. Please see help page (-h) for more details');
      exit(1);
    }
    await _run(arguments);
    _logger.i('Report generated!');
  } catch (ex) {
    _logger.e('Dart-CoCo reporter encountered an unexpeced error..');
    _logger.e(ex.toString());
    exit(1);
  }
}

Future<void> _run(final ArgResults args) async {
  _logger.i('Cleaning report direcotry');
  final out = _createOutputDir(args['output']);

  // get all dart files in analysis root
  final dartFiles = Glob('**.dart').listSync(root: args['root'], followLinks: false);
  dartFiles.removeWhere((FileSystemEntity entity) {
    if (entity is! File) return true;
    if (entity is File) {
      for (String ignoredPathPart in ['.pub', 'packages']) {
        if (entity.path.contains(ignoredPathPart)) return true;
      }
    }
    return false;
  });

  // run cyclomatic analysis tool
  final dartFilePaths = dartFiles.map((FileSystemEntity entity) => entity.path).toList(growable: false);
  CyclomaticAnalysisRunner runner = CyclomaticAnalysisRunner(CyclomaticAnalysisRecorder(), CyclomaticAnalyzer(), dartFilePaths);
  runner.run();
  final AnalysisData analysisData = runner.getResults(args['root']);

  // run lcov parser
  LcovData lcovData;

  if (args.wasParsed('lcov') || File(DEFAULT_LCOV).existsSync()) {
    _logger.i('Parsing LCOV coverage report...');
    final lcovParser = LcovParser();
    final lcov = await _readFile(args['lcov']);
    lcovData = await lcovParser.convert(lcov);
  }

  final ReportData reportData = Reporter.generateReportData(analysisData, lcovData);

  // run HTML reporter
  if (args.wasParsed('html')) {
    _logger.i('Generating HTML codemtrics report...');
    final reporter = HtmlReporter(out, args['root']);
    await reporter.generateReport(reportData);
  }
  // run JSON reporter
  if (args.wasParsed('json')) {
    _logger.i('Generating JSON codemtrics report...');
    final reporter = JsonReporter(out, args['root']);
    await reporter.generateReport(reportData);
  }
}

Directory _createOutputDir(final String output) {
  final Directory out = Directory(output);
  if (out.existsSync()) {
    out.deleteSync(recursive: true);
  }
  out.createSync(recursive: true);
  return out;
}

Future<String> _readFile(final String lcovPath) {
  final lcov = File(lcovPath);
  if (!lcov.existsSync()) {
    throw FileSystemException("Lcov data file not found in provided path [$lcovPath]");
  }
  _logger.i('Parsing LCOV file [$lcovPath]');
  return lcov.readAsString();
}

void _help(final ArgParser parser) {
  print('Help page for Dart-CoCo - Reporting tool for Dart.lang');
  for (final ok in parser.options.keys) {
    final o = parser.options[ok];
    String msg = '\t--$ok ';
    if (o.abbr != null) {
      msg += '(${o.abbr})';
    }
    msg += '\t\t - ${o.help}';
    print(msg);
  }
}
