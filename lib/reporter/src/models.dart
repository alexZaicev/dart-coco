part of dart_coco.reporter;

class ReportData extends Serializable {
  String timestamp;
  ReportSummary summary;
  Map<String, ReportPackage> packages;

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

  ReportData({this.timestamp, this.summary, this.packages});

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'timestamp': timestamp,
      'summary': summary == null ? null : summary.toMap(),
    };
    if (packages != null) {
      final mm = <String, dynamic>{};
      for (final key in packages.keys) {
        mm[key] = packages[key].toMap();
      }
      map['packages'] = mm;
    }
    return map;
  }
}

class ReportPackage implements Serializable {
  int complexity;
  int linesTotal;
  int linesCovered;
  int branchesTotal;
  int branchesCovered;
  Map<String, ReportFile> classes;

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

  ReportPackage({
    this.complexity = 0,
    this.linesTotal = 0,
    this.linesCovered = 0,
    this.branchesTotal = 0,
    this.branchesCovered = 0,
    this.classes,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'complexity': complexity,
      'linesTotal': linesTotal,
      'linesCovered': linesCovered,
      'branchesTotal': branchesTotal,
      'branchesCovered': branchesCovered,
    };
    if (classes != null) {
      final mm = <String, dynamic>{};
      for (final key in classes.keys) {
        mm[key] = classes[key].toMap();
      }
      map['classes'] = mm;
    }
    return map;
  }
}

class ReportFile implements Serializable {
  int complexity;
  int linesTotal;
  int linesCovered;
  Map<int, int> linesHits;
  int branchesTotal;
  int branchesCovered;
  Map<String, ReportMethod> methods;

  ReportFile(
      {this.complexity = 0,
      this.linesTotal = 0,
      this.linesCovered = 0,
      this.linesHits,
      this.branchesTotal = 0,
      this.branchesCovered = 0,
      this.methods});

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'complexity': complexity,
      'linesTotal': linesTotal,
      'linesCovered': linesCovered,
      'branchesTotal': branchesTotal,
      'branchesCovered': branchesCovered,
    };
    if (linesHits != null) {
      final mm = <String, dynamic>{};
      for (final key in linesHits.keys) {
        mm['$key'] = linesHits[key];
      }
      map['linesHits'] = mm;
    }
    if (methods != null) {
      final mm = <String, dynamic>{};
      for (final key in methods.keys) {
        mm[key] = methods[key].toMap();
      }
      map['methods'] = mm;
    }
    return map;
  }
}

class ReportMethod implements Serializable {
  int complexity;

  ReportMethod({this.complexity});

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
        'complexity': complexity,
      };
}

class ReportSummary implements Serializable {
  int complexity;
  int linesTotal;
  int linesCovered;
  int branchesTotal;
  int branchesCovered;

  ReportSummary(
      {this.complexity = 0,
      this.linesTotal = 0,
      this.linesCovered = 0,
      this.branchesTotal = 0,
      this.branchesCovered = 0});

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
        'complexity': complexity,
        'linesTotal': linesTotal,
        'linesCovered': linesCovered,
        'branchesTotal': branchesTotal,
        'branchesCovered': branchesCovered,
      };
}

enum DisplayType { ROOT, PACKAGE, CLASS, SOURCE }
