part of dart_coco.reporter;

class HtmlReporter extends Reporter {
  HtmlReporter(final Directory output, final String root) : super(output, root);

  static const String TABLE_BODY = '<!TABLE_BODY!>';
  static const String TABLE_FOOT = '<!TABLE_FOOT!>';
  static const String BREADCRUMB = '<!BREADCRUMB!>';
  static const String SOURCE = '<!SOURCE!>';
  static const String HEAD_LINKS = '<!HEAD_LINKS!>';
  static final List<String> DART_LANG_KEYWORDS = [
    'typedef',
    'as',
    'implements',
    'export',
    'library',
    'part',
    'get',
    'mixin',
    'static',
    'factory',
    'import',
    'abstract',
    'assert',
    'await',
    'break',
    'case',
    'catch',
    'class',
    'const',
    'continue',
    'default',
    'do',
    'else',
    'enum',
    'extends',
    'false',
    'final',
    'finally',
    'for',
    'if',
    'in',
    'is',
    'new',
    'null',
    'rethrow',
    'return',
    'super',
    'switch',
    'this',
    'throw',
    'true',
    'try',
    'var',
    'void',
    'while',
    'with',
    'async',
    'show',
    'hide',
    'sync',
    'on',
  ];
  static final Map<String, String> HTML_NAME_CODE = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '\'': '&apos;',
    '\"': '&quot;'
  };
  static final List<String> STRING_IDENTIFIERS = ['\'', '\"'];
  static final List<String> DART_LANG_PRIMITIVES = [
    'int',
    'bool',
    'double',
    'String',
    'List',
    'Map',
    'Set',
    'Function',
    'Object',
    'Exception',
  ];
  static const int COVERAGE_BAR_WIDTH = 150;
  static const int COVERAGE_BAR_HEIGHT = 10;

  static final Logger _logger = Logger('HtmlReporter');

  Future<String> getHtmlTemplate(final String template) async {
    _logger.d('Loading HTML template...');
    final f = File(p.join(projectRoot, 'assets', template));
    final html = f.readAsString();
    return html;
  }

  @override
  Future<void> generateReport(ReportData data) async {
    await _placeResources();

    String template = Assets.getReportTemplate();
    final String headLinks = _placeHeadLink(DisplayType.ROOT);
    _logger.d('Index head link generated:\n$headLinks');
    final String tableBody = _body(data, DisplayType.ROOT);
    _logger.d('Table body generated:\n$tableBody');
    final String tableFoot = _foot(data, DisplayType.ROOT);
    _logger.d('Table foot generated:\n$tableFoot');
    final String breadcrumbs = _breadcrumb(DisplayType.ROOT);
    _logger.d('Breadcrumbs generated:\n$breadcrumbs');

    // replace table tags
    template = template.replaceAll(HEAD_LINKS, headLinks);
    template = template.replaceAll(TABLE_BODY, tableBody);
    template = template.replaceAll(TABLE_FOOT, tableFoot);
    template = template.replaceAll(BREADCRUMB, breadcrumbs);
    _logger.d('Index page generated');

    // create index.html
    final File f = File(p.join(_outputDir.path, 'index.html'));
    _logger.d('Saving index.html [${f.path}]');
    await f.writeAsString(template);
    _logger.d('index.html saved!');
    // create packages
    _logger.d('Generating pakcage report packages...');
    await _createPackages(data);
    _logger.d('Package report packages generated successfully');

    _logger.d('Generating class report...');
    await _createClasses(data);
    _logger.d('Class report generated successfully');

    _logger.d('Generating source code report...');
    await _processSources(data);
    _logger.d('Source code reports gnenerated successfully');
  }

  Future<void> _placeResources() async {
    final Directory resourceDir =
        Directory(p.join(outputDir.path, 'resources'));
    await resourceDir.create();
    _logger.d('Resource directory created');

    for (final res in Assets.getAvailableResources()) {
      if (!res.endsWith('.html')) {
        _logger.d('Copying resource [$res]');
        final File f = File(p.join(resourceDir.path, res));
        _logger.d('Creating resource file [${f.path}]...');
        await f.create();
        await f.writeAsString(Assets.getResource(res));
        _logger.d('Reosurce file copied successfully');
      }
    }
    _logger.d('Resources transferred successfully');
  }

  Future<void> _createClasses(final ReportData data) async {
    final Directory classesDir = Directory(p.join(outputDir.path, 'classes'));
    await classesDir.create();
    _logger.d('Classes directory created');
    for (final package in data.packages.keys) {
      for (final clazz in data.packages[package].classes.keys) {
        _logger.d('Parsing report [$clazz}]');
        String template = Assets.getReportTemplate();

        final String headLinks = _placeHeadLink(DisplayType.CLASS);
        _logger.d('Index head link generated:\n$headLinks');
        final String tableBody =
            _body(data, DisplayType.CLASS, package: package, clazz: clazz);
        _logger.d('Table body generated:\n$tableBody');
        final String tableFoot =
            _foot(data, DisplayType.CLASS, package: package, clazz: clazz);
        _logger.d('Table foot generated:\n$tableFoot');
        final String breadcrumbs =
            _breadcrumb(DisplayType.CLASS, package: package, clazz: clazz);
        _logger.d('Breadcrumbs generated:\n$breadcrumbs');

        // replace table tags
        template = template.replaceAll(HEAD_LINKS, headLinks);
        template = template.replaceAll(TABLE_BODY, tableBody);
        template = template.replaceAll(TABLE_FOOT, tableFoot);
        template = template.replaceAll(BREADCRUMB, breadcrumbs);
        _logger.d('Report [$package] HTML page generated');

        // create class site
        final File f = File(p.join(classesDir.path,
            '${package.replaceAll(p.separator, '.')}.$clazz.html'));
        _logger.d('Saving report site [${f.path}]');
        await f.writeAsString(template);
        _logger.d('Report site [$clazz] saved');
      }
    }
  }

  Future<void> _processSources(final ReportData data) async {
    final Directory sourcesDir = Directory(p.join(outputDir.path, 'sources'));
    await sourcesDir.create();
    _logger.d('Sources directory created');

    for (final package in data.packages.keys) {
      for (final clazz in data.packages[package].classes.keys) {
        _logger.d('Parsing report [$clazz]');
        String template = Assets.getReportSourceTemplate();
        final templateCoverage =
            _sourceCoverageStylesheet(data.packages[package].classes[clazz]);

        _logger.d('Reading source file [$clazz]...');
        String path = '';
        if (root.length > 3) {
          path = root.substring(0, root.length - 4);
        }
        final File sourceFile = File(p.join(path, package, clazz));
        final String sourceCode = await sourceFile.readAsString(
            encoding: Encoding.getByName('utf-8'));
        _logger.d('Generating HTML from source code...');
        final String source =
            _body(null, DisplayType.SOURCE, sourceCode: sourceCode);
        _logger.d('Source code generated');
        final String headLinks = _placeHeadLink(DisplayType.SOURCE,
            '${package.replaceAll(p.separator, '.')}.$clazz');
        _logger.d('Index head link generated:\n$headLinks');
        final String breadcrumbs =
            _breadcrumb(DisplayType.SOURCE, package: package, clazz: clazz);
        _logger.d('Breadcrumbs generated:\n$breadcrumbs');

        // replace table tags
        template = template.replaceAll(HEAD_LINKS, headLinks);
        template = template.replaceAll(SOURCE, source);
        template = template.replaceAll(BREADCRUMB, breadcrumbs);
        _logger.d('Report [$clazz] HTML page generated');

        // create package site
        final File f = File(p.join(sourcesDir.path,
            '${package.replaceAll(p.separator, '.')}.$clazz.html'));
        _logger.d('Saving report site [${f.path}]');
        await f.writeAsString(template);
        _logger.d('Report site [$clazz] saved');
        // create class stylesheet for coverage
        final File f1 = File(p.join(sourcesDir.path,
            '${package.replaceAll(p.separator, '.')}.$clazz.css'));
        await f1.writeAsString(templateCoverage);
      }
    }
  }

  String _sourceCoverageStylesheet(final ReportFile report) {
    String css = '';
    if (report.linesHits != null) {
      for (final line in report.linesHits.keys) {
        if (report.linesHits[line] == 0) {
          css += '''
.L${line - 1} {
  background-color: rgba(255, 0, 0, 0.3);
}
        ''';
        } else {
          css += '''
.L${line - 1} {
  background-color: rgba(0, 255, 0, 0.3);
}
        ''';
        }
      }
    }
    return css;
  }

  String _placeHeadLink(final DisplayType type, [final String name]) {
    String prefix = 'resources';
    if (type != DisplayType.ROOT) {
      prefix = '../$prefix';
    }
    String html = '''
    <link rel="stylesheet" type="text/css" href="$prefix/main.css" />
    <script type="text/javascript" src="$prefix/report.js"></script>
    ''';
    if (type == DisplayType.SOURCE) {
      html += '''
      <link rel="stylesheet" type="text/css" href="$prefix/source.css" />
      <script type="text/javascript" src="$prefix/source.js"></script>
      <link rel="stylesheet" type="text/css" href="$name.css" />
      ''';
    }
    return html;
  }

  String _generateSourceHtmlForLine(final String line, final int id) {
    String html = '<li class="L$id">';
    if (line.replaceAll(' ', '').startsWith('//')) {
      // check if line is comment
      html += _wrapInSpan('com', line);
    } else {
      String buffer = '';
      for (final rune in line.runes) {
        final ch = String.fromCharCode(rune);

        // check if ch indicates start/end of string
        if (STRING_IDENTIFIERS.contains(ch) ||
            _bufferContains(buffer, STRING_IDENTIFIERS)) {
          // check if start of the string
          if (STRING_IDENTIFIERS.contains(ch) &&
              (buffer.isEmpty || !STRING_IDENTIFIERS.contains(buffer[0]))) {
            html += _wrapInSpan('pln', buffer);
            buffer = ch;
          } else if (STRING_IDENTIFIERS.contains(buffer[0]) &&
              ch == buffer[0]) {
            buffer += ch;
            html += _wrapInSpan('str', buffer);
            buffer = '';
          } else {
            buffer += ch;
          }

          continue;
        }

        // check if ch indicates annotation
        if (ch == '@' || buffer.contains('@')) {
          if (buffer.isNotEmpty && !buffer.contains('@')) {
            html += _wrapInSpan('pln', buffer);
            buffer = ch;
          } else if (ch == ' ' || ch == '\r' || ch == '\n') {
            // check end of string
            buffer += ch;
            html += _wrapInSpan('ano', buffer);
            buffer = '';
          } else {
            buffer += ch;
          }
          continue;
        }
        buffer += ch;
        // check for primitives
        final prim_html = _checkInKeywords(buffer, DART_LANG_PRIMITIVES, 'typ');
        if (prim_html.isNotEmpty) {
          buffer = '';
          html += prim_html;
          continue;
        }
        // check if buffered string is Dart.lang keyword
        final kwd_html = _checkInKeywords(buffer, DART_LANG_KEYWORDS, 'kwd');
        if (kwd_html.isNotEmpty) {
          buffer = '';
          html += kwd_html;
          continue;
        }
      }
      if (buffer.isNotEmpty) {
        html += _wrapInSpan('pln', buffer);
      }
    }
    html += '</li>';
    return html;
  }

  String _checkInKeywords(
      final String buffer, final List<String> kwds, final String style) {
    String copy = '$buffer';
    String html = '';
    for (final kwd in kwds) {
      String str = kwd;
      if (copy == kwd || copy.endsWith(' $kwd ')) {
        if (copy.endsWith(' $kwd ')) {
          copy = copy.replaceFirst(' $kwd ', '');
          copy += ' ';
          str += ' ';
        } else {
          copy = copy.replaceFirst('$kwd', '');
        }
        html += _wrapInSpan('pln', copy);
        html += _wrapInSpan(style, str);
        copy = '';
        break;
      }
    }
    return html;
  }

  bool _bufferContains(final String buffer, final List<String> chars) {
    for (final ch in chars) {
      if (buffer.contains(ch)) {
        return true;
      }
    }
    return false;
  }

  String _wrapInSpan(final String style, final String value) {
    // change all code specific operators to HTML name codes
    String str = value;
    for (final k in HTML_NAME_CODE.keys) {
      str = str.replaceAll(k, HTML_NAME_CODE[k]);
    }
    return '<span class="$style">$str</span>';
  }

  Future<void> _createPackages(final ReportData data) async {
    final Directory packagesDir = Directory(p.join(outputDir.path, 'packages'));
    await packagesDir.create();
    _logger.d('Packages directory created');

    for (final package in data.packages.keys) {
      _logger.d('Parsing report [$package]');
      String template = Assets.getReportTemplate();

      final String headLinks = _placeHeadLink(DisplayType.PACKAGE);
      _logger.d('Index head link generated:\n$headLinks');
      final String tableBody =
          _body(data, DisplayType.PACKAGE, package: package);
      _logger.d('Table body generated:\n$tableBody');
      final String tableFoot =
          _foot(data, DisplayType.PACKAGE, package: package);
      _logger.d('Table foot generated:\n$tableFoot');
      final String breadcrumbs =
          _breadcrumb(DisplayType.PACKAGE, package: package);
      _logger.d('Breadcrumbs generated:\n$breadcrumbs');

      // replace table tags
      template = template.replaceAll(HEAD_LINKS, headLinks);
      template = template.replaceAll(TABLE_BODY, tableBody);
      template = template.replaceAll(TABLE_FOOT, tableFoot);
      template = template.replaceAll(BREADCRUMB, breadcrumbs);
      _logger.d('Report [$package] HTML page generated');

      // create package site
      final File f = File(p.join(
          packagesDir.path, '${package.replaceAll(p.separator, '.')}.html'));
      _logger.d('Saving report site [$f.path]');
      await f.writeAsString(template);
      _logger.d('Report site [$package] saved');
    }
  }

  String _breadcrumb(final DisplayType type,
      {final String package, final String clazz}) {
    String breadcrumb = '';

    switch (type) {
      case DisplayType.ROOT:
        {
          breadcrumb = '''
    <a class="el_report" href="index.html">Dart-CoCo</a> 
    ''';
          break;
        }
      case DisplayType.PACKAGE:
        {
          final packageName = package.replaceAll(p.separator, '.');
          breadcrumb = '''
    <a class="el_report" href="../index.html">Dart-CoCo</a>
    >
    <a class="el_package" href="../packages/$packageName.html">$packageName</a> 
    ''';
          break;
        }
      case DisplayType.CLASS:
        {
          final packageName = package.replaceAll(p.separator, '.');
          breadcrumb = '''
    <a class="el_report" href="../index.html">Dart-CoCo</a>
    >
    <a class="el_package" href="../packages/$packageName.html">$packageName</a>
    >
    <a class="el_class" href="../classes/$packageName.$clazz.html">${clazz.split('.')[0]}</a> 
    ''';
          break;
        }
      case DisplayType.SOURCE:
        {
          final packageName = package.replaceAll(p.separator, '.');
          breadcrumb = '''
    <a class="el_report" href="../index.html">Dart-CoCo</a>
    >
    <a class="el_package" href="../packages/$packageName.html">$packageName</a>
    >
    <a class="el_class" href="../classes/$packageName.$clazz.html">${clazz.split('.')[0]}</a> 
    >
    <a class="el_source" href="../sources/$packageName.$clazz.html">$clazz</a> 
    ''';
          break;
        }
    }
    return breadcrumb;
  }

  String _foot(final ReportData data, final DisplayType type,
      {final String package, final String clazz}) {
    String foot;
    switch (type) {
      case DisplayType.ROOT:
        {
          int coveredLinesPrc = 0;
          if (data.summary.linesTotal > 0) {
            coveredLinesPrc =
                ((data.summary.linesCovered / data.summary.linesTotal) * 100)
                    .toInt();
          }
          int coveredBranchesPrc = 0;
          if (data.summary.branchesTotal > 0) {
            coveredBranchesPrc =
                ((data.summary.branchesCovered / data.summary.branchesTotal) *
                        100)
                    .toInt();
          }
          foot = '''
  <tr>
    <td>Total</td>
    <td class="bar">${data.summary.linesCovered} of ${data.summary.linesTotal}</td>
    <td class="ctr2">$coveredLinesPrc%</td>
    <td class="bar">${data.summary.branchesCovered} of ${data.summary.branchesTotal}</td>
    <td class="ctr2">$coveredBranchesPrc%</td>
    <td class="ctr2">${data.summary.complexity}</td>
    <td class="ctr2">${package == null ? data.methods : data.packages[package].methods}</td>
  </tr>
      ''';
          break;
        }
      case DisplayType.PACKAGE:
        {
          final packageData = data.packages[package];
          int coveredLinesPrc = 0;
          if (packageData.linesTotal > 0) {
            coveredLinesPrc =
                ((packageData.linesCovered / packageData.linesTotal) * 100)
                    .toInt();
          }
          int coveredBranchesPrc = 0;
          if (packageData.branchesTotal > 0) {
            coveredBranchesPrc = ((packageData.branchesCovered /
                        data.packages[package].branchesTotal) *
                    100)
                .toInt();
          }
          foot = '''
  <tr>
    <td>Total</td>
    <td class="bar">${data.packages[package].linesCovered} of ${data.packages[package].linesTotal}</td>
    <td class="ctr2">$coveredLinesPrc%</td>
    <td class="bar">${data.packages[package].branchesCovered} of ${data.packages[package].branchesTotal}</td>
    <td class="ctr2">$coveredBranchesPrc%</td>
    <td class="ctr2">${data.packages[package].complexity}</td>
    <td class="ctr2">${data.packages[package].methods}</td>
  </tr>
      ''';
          break;
        }
      case DisplayType.CLASS:
        {
          final classData = data.packages[package].classes[clazz];
          int coveredLinesPrc = 0;
          if (classData.linesTotal > 0) {
            coveredLinesPrc =
                ((classData.linesCovered / classData.linesTotal) * 100).toInt();
          }
          int coveredBranchesPrc = 0;
          if (classData.branchesTotal > 0) {
            coveredBranchesPrc =
                ((classData.branchesCovered / classData.branchesTotal) * 100)
                    .toInt();
          }
          foot = '''
  <tr>
    <td>Total</td>
    <td class="bar">${data.packages[package].classes[clazz].linesCovered} of ${data.packages[package].classes[clazz].linesTotal}</td>
    <td class="ctr2">$coveredLinesPrc%</td>
    <td class="bar">${data.packages[package].classes[clazz].branchesCovered} of ${data.packages[package].classes[clazz].branchesTotal}</td>
    <td class="ctr2">$coveredBranchesPrc%</td>
    <td class="ctr2">${data.packages[package].classes[clazz].complexity}</td>
    <td class="ctr2">${data.packages[package].classes[clazz].methods.length}</td>
  </tr>
      ''';
          break;
        }
      case DisplayType.SOURCE:
        break;
    }
    return foot;
  }

  String _body(final ReportData data, final DisplayType type,
      {final String package, final String clazz, final String sourceCode}) {
    String body = '';

    switch (type) {
      case DisplayType.ROOT:
        {
          for (final package in data.packages.keys) {
            final id =
                data.packages.keys.toList(growable: false).indexOf(package);
            final packageName = package.replaceAll(p.separator, '.');
            final packageData = data.packages[package];
            int coveredLinesPrc = 0;
            if (packageData.linesTotal > 0) {
              coveredLinesPrc =
                  ((packageData.linesCovered / packageData.linesTotal) * 100)
                      .toInt();
            }
            int coveredBranchesPrc = 0;
            if (packageData.branchesTotal > 0) {
              coveredBranchesPrc =
                  ((packageData.branchesCovered / packageData.branchesTotal) *
                          100)
                      .toInt();
            }

            body += '''
  <tr>
    <td id="a$id">
      <a class="el_package" href="packages/$packageName.html">$packageName</a>
    </td>
    ${_getCoverageBarData('b$id', type, coveredLinesPrc)}   
    <td class="ctr2" id="c$id">$coveredLinesPrc%</td>     
    ${_getCoverageBarData('d$id', type, coveredBranchesPrc)}
    <td class="ctr2" id="e$id">$coveredBranchesPrc%</td>         
    <td id="f$id" class="ctr2">${data.packages[package].complexity}</td>
    <td id="g$id" class="ctr2">${data.packages[package].methods}</td>
  </tr>
      ''';
          }
          break;
        }
      case DisplayType.PACKAGE:
        {
          for (final clazz in data.packages[package].classes.keys) {
            final clazzData = data.packages[package].classes[clazz];
            final id = data.packages[package].classes.keys
                .toList(growable: false)
                .indexOf(clazz);
            int coveredLinesPrc = 0;
            if (clazzData.linesTotal > 0) {
              coveredLinesPrc =
                  ((clazzData.linesCovered / clazzData.linesTotal) * 100)
                      .toInt();
            }
            int coveredBranchesPrc = 0;
            if (clazzData.branchesTotal > 0) {
              coveredBranchesPrc =
                  ((clazzData.branchesCovered / clazzData.branchesTotal) * 100)
                      .toInt();
            }
            body += '''
  <tr>
    <td id="a$id">
      <a class="el_class" href="../classes/${package.replaceAll(p.separator, '.')}.$clazz.html">$clazz</a>
    </td>
    ${_getCoverageBarData('b$id', type, coveredLinesPrc)}
    <td class="ctr2" id="c$id">$coveredLinesPrc%</td>     
    ${_getCoverageBarData('d$id', type, coveredBranchesPrc)}
    <td class="ctr2" id="e$id">$coveredBranchesPrc%</td>             
    <td id="f$id" class="ctr2">${clazzData.complexity}</td>
    <td id="g$id" class="ctr2">${clazzData.methods.length}</td>
  </tr>
      ''';
          }
          break;
        }
      case DisplayType.CLASS:
        {
          for (final method
              in data.packages[package].classes[clazz].methods.keys) {
            final methodData =
                data.packages[package].classes[clazz].methods[method];
            final id = data.packages[package].classes[clazz].methods.keys
                .toList(growable: false)
                .indexOf(method);
            // TODO: coverage of the method is not provided in the report data
            body += '''
  <tr>
    <td id="a$id">
      <a class="el_method" href="../sources/${package.replaceAll(p.separator, '.')}.$clazz.html">$method</a>
    </td>
    ${_getCoverageBarData('b$id', type, 0)} 
    <td class="ctr2" id="c$id">0%</td>      
    ${_getCoverageBarData('d$id', type, 0)}
    <td class="ctr2" id="e$id">0%</td>     
    <td id="f$id" class="ctr2">${methodData.complexity}</td>
    <td id="g$id" class="ctr2">1</td>
  </tr>
      ''';
          }
          break;
        }
      case DisplayType.SOURCE:
        {
          body = '<pre class="source lang-dart linenums"><ol class="linenums">';
          final lines = sourceCode.split('\n');
          int id = 0;
          for (final line in lines) {
            body += _generateSourceHtmlForLine(line, id);
            id += 1;
          }
          body += '</ol></pre>';
          break;
        }
    }
    return body;
  }

  String _getCoverageBarData(
      final String id, final DisplayType type, final int coveragePrc) {
    String body = '';
    String resourcePrefix = 'resources';
    if (type != DisplayType.ROOT) {
      resourcePrefix = '../$resourcePrefix';
    }
    // populate data about line coverage
    if (coveragePrc == 100) {
      body += '''
    <td class="bar" id="$id">
      <img src="$resourcePrefix/greenbar.svg" title="0" alt="0" width="$COVERAGE_BAR_WIDTH" height="$COVERAGE_BAR_HEIGHT">
    </td>
              ''';
    } else if (coveragePrc > 0 && coveragePrc < 100) {
      body += '''
    <td class="bar" id="$id">
      <img style="margin: 0; padding: 0;" src="$resourcePrefix/redbar.svg" title="0" alt="0" width="${(100 - coveragePrc) * (COVERAGE_BAR_WIDTH - 5) ~/ 100}" height="$COVERAGE_BAR_HEIGHT">
      <img style="margin: 0; padding: 0;" src="$resourcePrefix/greenbar.svg" title="0" alt="0" width="${coveragePrc * (COVERAGE_BAR_WIDTH - 5) ~/ 100}" height="$COVERAGE_BAR_HEIGHT">
    </td>
              ''';
    } else {
      body += '''
    <td class="bar" id="$id">
      <img src="$resourcePrefix/redbar.svg" title="0" alt="0" width="$COVERAGE_BAR_WIDTH" height="$COVERAGE_BAR_HEIGHT">
    </td>
              ''';
    }
    return body;
  }
}
