part of dart_coco.reporter;

const REPORT_SOURCE_TEMPLATE = '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta content="text/html;charset=UTF-8" http-equiv="Content-Type">
    <title>Dart-CoCo: Reporting tools for Dart</title>
    <!HEAD_LINKS!>
</head>
<body onload="window['PR_TAB_WIDTH']=4;">
<div class="breadcrumb" id="breadcrumb">
    <!BREADCRUMB!>
</div>
<h1>Dart-CoCo</h1>

<!SOURCE!>

<div class="mallbery-ext-normal"
     style="z-index: 2147483647 !important; text-transform: none !important; position: fixed;"></div>
<div class="mallbery-caa"
     style="z-index: 2147483647 !important; text-transform: none !important; position: fixed;"></div>
</body>
</html>
''';
