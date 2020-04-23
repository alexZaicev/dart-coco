part of dart_coco.analyzer;

class CyclomaticAnalysisRecorder extends AnalysisRecorder {
  CyclomaticAnalysisRecorder() : _records = <Map<String, dynamic>>[];

  Map<String, dynamic> _activeRecordGroup;

  bool get _hasStartedGroup => _activeRecordGroup != null;

  final List<Map<String, dynamic>> _records;

  @override
  bool canRecord(String recordName) {
    // records everything
    return true;
  }

  @override
  List<Map<String, dynamic>> getRecords() {
    return _records;
  }

  @override
  void startRecordGroup(String groupName) {
    if (_hasStartedGroup) {
      throw StateError(
          'Cannot start a group while another one is started. Use `endRecordGroup` to close the opened one.');
    }
    if (groupName == null) {
      throw ArgumentError.notNull('groupName');
    }
    final recordGroup = <String, dynamic>{};
    _records.add(<String, dynamic>{
      groupName: recordGroup,
    });
    _activeRecordGroup = recordGroup;
  }

  @override
  void endRecordGroup() {
    _activeRecordGroup = null;
  }

  @override
  void record(final String recordName, final dynamic value) {
    if (!_hasStartedGroup) {
      throw StateError(
          'No record groups have been started. Use `startRecordGroup` before `record`');
    }
    if (recordName == null) {
      throw ArgumentError.notNull('recordName');
    }
    _activeRecordGroup[recordName] = value;
  }
}

class CyclomaticAnalyzer extends Analyzer<CyclomaticAnalysisRecorder> {
  CyclomaticAnalysisRecorder _recorder;

  @override
  void runAnalysis(String filePath, CyclomaticAnalysisRecorder recorder) {
    _recorder = recorder;
    final declarations = _getDeclarations(filePath);
    if (declarations.isNotEmpty) {
      recorder.startRecordGroup(filePath);
      _recordDeclarationNamesFor(declarations);
      _runComplexityAnalysisFor(declarations);
      recorder.endRecordGroup();
    }
  }

  BuiltList<ScopedDeclaration> _getDeclarations(String filePath) {
    final compUnit =
        parseFile(path: filePath, featureSet: FeatureSet.fromEnableFlags([]));
    final callableVisitor = CallableAstVisitor();
    compUnit.unit.visitChildren(callableVisitor);
    return callableVisitor.declarations;
  }

  void _runComplexityAnalysisFor(BuiltList<ScopedDeclaration> declarations) {
    for (ScopedDeclaration dec in declarations) {
      final controlFlowVisitor = _visitDeclaration(dec.declaration);
      final complexity = _getCyclomaticComplexity(controlFlowVisitor);
      _recordDeclarationComplexity(dec, complexity);
    }
  }

  ControlFlowVisitor _visitDeclaration(Declaration dec) {
    final controlFlowVisitor = ControlFlowVisitor(DEFAULT_CYCLOMATIC_CONFIG);
    dec.visitChildren(controlFlowVisitor);
    return controlFlowVisitor;
  }

  void _recordDeclarationNamesFor(Iterable<ScopedDeclaration> declarations) {
    _recorder.record(
        'callables',
        declarations
            .map((ScopedDeclaration dec) => _getQualifiedName(dec))
            .toList(growable: false));
  }

  void _recordDeclarationComplexity(ScopedDeclaration dec, int complexity) {
    _recorder.record(_getQualifiedName(dec), complexity);
  }

  String _getQualifiedName(ScopedDeclaration dec) {
    final declaration = dec.declaration;
    if (declaration is FunctionDeclaration) {
      return declaration.name.toString();
    } else if (declaration is MethodDeclaration) {
      return '${dec.enclosingClass.name}.${declaration.name}';
    }
    return null;
  }

  int _getCyclomaticComplexity(ControlFlowVisitor visitor) {
    return visitor.complexity;
  }
}

class CyclomaticAnalysisRunner extends AnalysisRunner {
  CyclomaticAnalysisRunner(final AnalysisRecorder recorder,
      final Analyzer analyzer, final List<String> filePaths)
      : super(recorder, analyzer, filePaths);

  @override
  void run() {
    for (String path in _filePaths) {
      analyzer.runAnalysis(path, recorder);
    }
  }

  @override
  AnalysisData getResults(final String root) {
    final List<Map<String, dynamic>> records = recorder.getRecords();

    // populate analysis packages
    final Map<String, AnalysisPackage> packages = {};
    for (final data in records) {
      for (final file in data.keys) {
        int complexity = 0;
        final Map<String, AnalysisMethod> methods = {};
        for (final callable in data[file]['callables']) {
          complexity += data[file][callable];
          final String method = callable.split('.').last;
          methods[method] = AnalysisMethod(complexity: data[file][callable]);
        }
        final fullName =
            p.join('lib', file.replaceAll('$root${p.separator}', ''));
        final clazz = fullName.split(p.separator).last;
        String package = fullName.replaceAll('${p.separator}$clazz', '');
        // check if some files are in root
        // If true then create package of empty string name
        if (package.endsWith('.dart')) {
          package = 'lib';
        }

        packages[package] ??=
            AnalysisPackage(classes: <String, AnalysisFile>{});
        packages[package].classes[clazz] =
            AnalysisFile(complexity: complexity, methods: methods);
        packages[package].complexity += complexity;
      }
    }
    // create analysis summary
    final AnalysisSummary summary = AnalysisSummary();
    for (final p in packages.values.toList(growable: false)) {
      summary.complexity += p.complexity;
    }
    return AnalysisData(
        timestamp: DateTime.now().toUtc().toIso8601String(),
        summary: summary,
        packages: packages);
  }
}

class AnalysisData {
  AnalysisData({this.timestamp, this.summary, this.packages});

  String timestamp;
  AnalysisSummary summary;
  Map<String, AnalysisPackage> packages;

  int get methods {
    if (packages == null || packages.isEmpty) {
      return 0;
    }
    int m = 0;
    for (final p in packages.values) {
      m += p.methods;
    }
    return m;
  }
}

class AnalysisPackage {
  AnalysisPackage({this.complexity = 0, this.classes});

  int complexity;
  Map<String, AnalysisFile> classes;

  int get methods {
    if (classes == null || classes.isEmpty) {
      return 0;
    }
    int m = 0;
    for (final c in classes.values) {
      m += c.methods.length;
    }
    return m;
  }
}

class AnalysisFile {
  AnalysisFile({this.complexity = 0, this.methods});

  int complexity;
  Map<String, AnalysisMethod> methods;
}

class AnalysisMethod {
  AnalysisMethod({this.complexity});

  int complexity;
}

class AnalysisSummary {
  AnalysisSummary({this.complexity = 0});

  int complexity;
}
