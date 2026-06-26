import 'package:analysis_server_plugin/edit/correction_utils.dart';
import 'package:analyzer/source/source_range.dart';

/// Extension on [CorrectionUtils] to provide utilities for creating [SourceRange]s.
extension CorrectionUtilsExtension on CorrectionUtils {
  /// Creates a [SourceRange] from [start] and [end] offsets.
  SourceRange createRange(int start, int end) =>
      SourceRange(start, end - start);

  /// Returns the text of the range from [start] to [end].
  String getTextRange(int start, int end) =>
      getRangeText(createRange(start, end));
}
