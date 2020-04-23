part of dart_coco.reporter;

const MAIN_CSS = '''
body, td {
    font-family: sans-serif;
    font-size: 10pt;
    background-color: rgb(28, 40, 52);
}

/* unvisited link */
a:link {
    color: #FAFAFA;
    text-decoration: none;
}

/* visited link */
a:visited {
    color: #FAFAFA;
    text-decoration: none;
}

/* mouse over link */
a:hover {
    color: #FAFAFA;
    text-decoration: none;
}

/* selected link */
a:active {
    color: #FAFAFA;
    text-decoration: none;
}

h1 {
    font-weight: bold;
    font-size: 21pt;
    color: #FFF;
}

.breadcrumb {
    font-size: 16px;
    font-weight: bold;
    border: #d6d3ce 1px solid;
    padding: 8px 12px;
}

.breadcrumb .info {
    float: right;
}

.breadcrumb .info a {
    margin-left: 8px;
}

.el_report {
    padding-left: 18px;
    background-image: url(https://raw.githubusercontent.com/jacoco/jacoco/master/org.jacoco.report/src/org/jacoco/report/internal/html/resources/report.gif);
    background-position: left center;
    background-repeat: no-repeat;
}

.el_group {
    padding-left: 18px;
    background-image: url(https://raw.githubusercontent.com/jacoco/jacoco/master/org.jacoco.report/src/org/jacoco/report/internal/html/resources/group.gif);
    background-position: left center;
    background-repeat: no-repeat;
}

.el_bundle {
    padding-left: 18px;
    background-image: url(https://raw.githubusercontent.com/jacoco/jacoco/master/org.jacoco.report/src/org/jacoco/report/internal/html/resources/bundle.gif);
    background-position: left center;
    background-repeat: no-repeat;
}

.el_package {
    padding-left: 18px;
    background-image: url(https://raw.githubusercontent.com/jacoco/jacoco/master/org.jacoco.report/src/org/jacoco/report/internal/html/resources/package.gif);
    background-position: left center;
    background-repeat: no-repeat;
}

.el_class {
    padding-left: 18px;
    background-image: url(https://raw.githubusercontent.com/jacoco/jacoco/master/org.jacoco.report/src/org/jacoco/report/internal/html/resources/class.gif);
    background-position: left center;
    background-repeat: no-repeat;
}

.el_source {
    padding-left: 18px;
    background-image: url(https://raw.githubusercontent.com/jacoco/jacoco/master/org.jacoco.report/src/org/jacoco/report/internal/html/resources/source.gif);
    background-position: left center;
    background-repeat: no-repeat;
}

.el_method {
    padding-left: 18px;
    background-image: url(https://raw.githubusercontent.com/jacoco/jacoco/master/org.jacoco.report/src/org/jacoco/report/internal/html/resources/method.gif);
    background-position: left center;
    background-repeat: no-repeat;
}

.el_session {
    padding-left: 18px;
    background-image: url(https://raw.githubusercontent.com/jacoco/jacoco/master/org.jacoco.report/src/org/jacoco/report/internal/html/resources/session.gif);
    background-position: left center;
    background-repeat: no-repeat;
}

pre.source {
    border: #d6d3ce 1px solid;
    font-family: monospace;
}

pre.source ol {
    margin-bottom: 0px;
    margin-top: 0px;
}

pre.source li {
    border-left: 3px solid #222;
    color: #A0A0A0;
    padding-left: 0px;
}

pre.source span.fc {
    background-color: #ccffcc;
}

pre.source span.nc {
    background-color: #ffaaaa;
}

pre.source span.pc {
    background-color: #ffffcc;
}

pre.source span.bfc {
    background-image: url(https://raw.githubusercontent.com/jacoco/jacoco/master/org.jacoco.report/src/org/jacoco/report/internal/html/resources/branchfc.gif);
    background-repeat: no-repeat;
    background-position: 2px center;
}

ol {
    background-color: rgb(18, 32, 47);
}

pre.source span.bfc:hover {
    background-color: #80ff80;
}

pre.source span.bnc {
    background-image: url(https://raw.githubusercontent.com/jacoco/jacoco/master/org.jacoco.report/src/org/jacoco/report/internal/html/resources/branchnc.gif);
    background-repeat: no-repeat;
    background-position: 2px center;
}

pre.source span.bnc:hover {
    background-color: #ff8080;
}

pre.source span.bpc {
    background-image: url(https://raw.githubusercontent.com/jacoco/jacoco/master/org.jacoco.report/src/org/jacoco/report/internal/html/resources/branchpc.gif);
    background-repeat: no-repeat;
    background-position: 2px center;
}

pre.source span.bpc:hover {
    background-color: #ffff80;
}

table.coverage {
    empty-cells: show;
    border-collapse: collapse;
}

table.coverage thead {
    background-color: #e0e0e0;
}

table.coverage thead td {
    white-space: nowrap;
    padding: 2px 14px 0px 6px;
    border-bottom: #b0b0b0 1px solid;
}

table.coverage thead td.bar {
    border-left: #cccccc 1px solid;
}

table.coverage thead td.ctr1 {
    text-align: right;
    border-left: #cccccc 1px solid;
}

table.coverage thead td.ctr2 {
    text-align: right;
    padding-left: 2px;
}

table.coverage thead td.sortable {
    cursor: pointer;
    background-image: url(https://raw.githubusercontent.com/jacoco/jacoco/master/org.jacoco.report/src/org/jacoco/report/internal/html/resources/sort.gif);
    background-position: right center;
    background-repeat: no-repeat;
}

table.coverage thead td.up {
    background-image: url(https://raw.githubusercontent.com/jacoco/jacoco/master/org.jacoco.report/src/org/jacoco/report/internal/html/resources/up.gif);
}

table.coverage thead td.down {
    background-image: url(https://raw.githubusercontent.com/jacoco/jacoco/master/org.jacoco.report/src/org/jacoco/report/internal/html/resources/down.gif);
}

table.coverage tbody td {
    white-space: nowrap;
    padding: 2px 6px 2px 6px;
    border-bottom: #d6d3ce 1px solid;
}

table.coverage tbody tr:hover {
    background: #f0f0d0 !important;
}

table.coverage tbody td.bar {
    border-left: #e8e8e8 1px solid;
}

table.coverage tbody td.ctr1 {
    text-align: right;
    padding-right: 14px;
    border-left: #e8e8e8 1px solid;
}

table.coverage tbody td.ctr2 {
    text-align: right;
    padding-right: 14px;
    padding-left: 2px;
}

table.coverage tfoot td {
    white-space: nowrap;
    padding: 2px 6px 2px 6px;
}

table.coverage tfoot td.bar {
    border-left: #e8e8e8 1px solid;
}

table.coverage tfoot td.ctr1 {
    text-align: right;
    padding-right: 14px;
    border-left: #e8e8e8 1px solid;
}

table.coverage tfoot td.ctr2 {
    text-align: right;
    padding-right: 14px;
    padding-left: 2px;
}

.footer {
    margin-top: 20px;
    border-top: #d6d3ce 1px solid;
    padding-top: 2px;
    font-size: 8pt;
    color: #a0a0a0;
}

.footer a {
    color: #a0a0a0;
}

.right {
    float: right;
}

table {
    color: #006666;
}

tbody {
    color: #FFFFFF;
}

td {
    font-size: 16px;
    font-weight: bolder;
}
''';
