import 'package:solid_lints/src/lints/avoid_duplicate_code/models/body_candidate.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/hash_entry.dart';

/// A record pairing a [BodyCandidate] with its computed [HashEntry].
typedef AnalyzedCandidate = ({
  BodyCandidate candidate,
  HashEntry entry,
});
