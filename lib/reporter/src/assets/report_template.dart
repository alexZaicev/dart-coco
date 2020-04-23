part of dart_coco.reporter;

const REPORT_TEMPLATE = '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta content="text/html;charset=UTF-8" http-equiv="Content-Type">
    <title>Dart-CoCO: Reporting tools for Dart</title>
    <!HEAD_LINKS!>
</head>
<body onload="initialSort(['breadcrumb', 'coveragetable'])">
<div class="breadcrumb" id="breadcrumb">
    <!BREADCRUMB!>
</div>
<h1>Dart-CoCo</h1>

<table cellspacing="0" class="coverage" id="coveragetable">
    <thead>
    <tr>
        <td class="sortable" id="a" onclick="toggleSort(this)">Element</td>
        <td class="sortable bar" id="b" onclick="toggleSort(this)">Missed Instructions</td>
        <td class="sortable ctr2" id="c" onclick="toggleSort(this)">Coverage</td>
        <td class="sortable bar" id="d" onclick="toggleSort(this)">Missed Branches</td>
        <td class="sortable ctr2" id="e" onclick="toggleSort(this)">Coverage</td>
        <td class="sortable ctr2" id="f" onclick="toggleSort(this)">Complexity</td>
        <td class="sortable ctr2" id="g" onclick="toggleSort(this)">Methods</td>
    </tr>
    </thead>
    <tfoot>
    <!TABLE_FOOT!>
    </tfoot>
    <tbody>
    <!TABLE_BODY!>
    </tbody>
</table>

</body>
</html>
''';
