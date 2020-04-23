library dart_coco.cyclomatic.test;

import 'package:dart_coco/parser/parser.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

final lcov_1 = '''
SF:lib${p.separator}package2${p.separator}file.dart
DA:1,0
DA:2,2
DA:3,1
DA:4,0
DA:5,6
DA:6,3
DA:7,2
DA:8,1
DA:9,2
LF:9
LH:7
end_of_record
SF:lib${p.separator}package1${p.separator}file.dart
DA:1,4
DA:3,0
DA:4,1
DA:6,0
DA:12,1
DA:34,3
DA:35,1
DA:36,1
DA:37,0
DA:38,0
DA:39,0
DA:40,0
LF:12
LH:6
end_of_record
''';

Future main() async {
  test('LcovParser test lcov_1', _testLcov1);
}

Future _testLcov1() async {
  final parser = LcovParser();
  final data = await parser.convert(lcov_1);

  expect(data, isNotNull);
  expect(data.timestamp, isNotNull);
  expect(data.summary, isNotNull);
  expect(data.summary.linesTotal, 21);
  expect(data.summary.linesCovered, 13);
  expect(data.summary.branchesTotal, 0);
  expect(data.summary.branchesCovered, 0);

  expect(data.packages, isNotNull);
  expect(data.packages.length, 2);

  expect(data.packages['lib${p.separator}package1'], isNotNull);
  expect(data.packages['lib${p.separator}package1'].linesTotal, 12);
  expect(data.packages['lib${p.separator}package1'].linesCovered, 6);
  expect(data.packages['lib${p.separator}package1'].branchesTotal, 0);
  expect(data.packages['lib${p.separator}package1'].branchesCovered, 0);

  expect(data.packages['lib${p.separator}package2'], isNotNull);
  expect(data.packages['lib${p.separator}package2'].linesTotal, 9);
  expect(data.packages['lib${p.separator}package2'].linesCovered, 7);
  expect(data.packages['lib${p.separator}package2'].branchesTotal, 0);
  expect(data.packages['lib${p.separator}package2'].branchesCovered, 0);

  expect(data.packages['lib${p.separator}package1'].classes, isNotNull);
  expect(data.packages['lib${p.separator}package1'].classes.length, 1);

  expect(data.packages['lib${p.separator}package1'].classes['file.dart'], isNotNull);
  expect(data.packages['lib${p.separator}package1'].classes['file.dart'].linesTotal, 12);
  expect(data.packages['lib${p.separator}package1'].classes['file.dart'].linesCovered, 6);
  expect(data.packages['lib${p.separator}package1'].classes['file.dart'].branchesTotal, 0);
  expect(data.packages['lib${p.separator}package1'].classes['file.dart'].branchesCovered, 0);
  expect(data.packages['lib${p.separator}package1'].classes['file.dart'].linesHits, isNotNull);
  expect(data.packages['lib${p.separator}package1'].classes['file.dart'].linesHits.length, 12);
  for (final num in data.packages['lib${p.separator}package1'].classes['file.dart'].linesHits.keys) {
    switch (num) {
      case 3:
      case 6:
      case 37:
      case 38:
      case 39:
      case 40:
        {
          expect(data.packages['lib${p.separator}package1'].classes['file.dart'].linesHits[num], 0);
          break;
        }
      case 4:
      case 12:
      case 35:
      case 36:
        {
          expect(data.packages['lib${p.separator}package1'].classes['file.dart'].linesHits[num], 1);
          break;
        }
      case 34:
        {
          expect(data.packages['lib${p.separator}package1'].classes['file.dart'].linesHits[num], 3);
          break;
        }
      case 1:
        {
          expect(data.packages['lib${p.separator}package1'].classes['file.dart'].linesHits[num], 4);
          break;
        }
      default:
        Exception();
    }
  }

  expect(data.packages['lib${p.separator}package2'].classes, isNotNull);
  expect(data.packages['lib${p.separator}package2'].classes.length, 1);

  expect(data.packages['lib${p.separator}package2'].classes['file.dart'], isNotNull);
  expect(data.packages['lib${p.separator}package2'].classes['file.dart'].linesTotal, 9);
  expect(data.packages['lib${p.separator}package2'].classes['file.dart'].linesCovered, 7);
  expect(data.packages['lib${p.separator}package2'].classes['file.dart'].branchesTotal, 0);
  expect(data.packages['lib${p.separator}package2'].classes['file.dart'].branchesCovered, 0);
  expect(data.packages['lib${p.separator}package2'].classes['file.dart'].linesHits, isNotNull);
  expect(data.packages['lib${p.separator}package2'].classes['file.dart'].linesHits.length, 9);
  for (final num in data.packages['lib${p.separator}package2'].classes['file.dart'].linesHits.keys) {
    switch (num) {
      case 1:
      case 4:
        {
          expect(data.packages['lib${p.separator}package2'].classes['file.dart'].linesHits[num], 0);
          break;
        }
      case 3:
      case 8:
        {
          expect(data.packages['lib${p.separator}package2'].classes['file.dart'].linesHits[num], 1);
          break;
        }
      case 2:
      case 7:
      case 9:
        {
          expect(data.packages['lib${p.separator}package2'].classes['file.dart'].linesHits[num], 2);
          break;
        }
      case 6:
        {
          expect(data.packages['lib${p.separator}package2'].classes['file.dart'].linesHits[num], 3);
          break;
        }
      case 5:
        {
          expect(data.packages['lib${p.separator}package2'].classes['file.dart'].linesHits[num], 6);
          break;
        }
      default:
        throw Exception();
    }
  }
}

