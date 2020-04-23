part of dart_coco.analyzer;

abstract class Analyzer<T extends AnalysisRecorder> {
  void runAnalysis(String filePath, T recorder);
}

abstract class AnalysisRunner {
  AnalysisRecorder _recorder;
  Analyzer _analyzer;
  List<String> _filePaths;

  AnalysisRecorder get recorder => _recorder;

  Analyzer get analyzer => _analyzer;

  List<String> get filePath => _filePaths;

  AnalysisRunner(final AnalysisRecorder recorder, final Analyzer analyzer, final List<String> filePaths) {
    this._recorder = recorder;
    this._analyzer = analyzer;
    this._filePaths = filePaths;
  }

  AnalysisData getResults(final String root);

  void run();
}

abstract class AnalysisRecorder {
  void startRecordGroup(String groupName);

  void endRecordGroup();

  void record(String recordName, dynamic value);

  bool canRecord(String recordName);

  Iterable<Map<String, dynamic>> getRecords();
}
