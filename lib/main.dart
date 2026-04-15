import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:solid_lints/src/lints/avoid_debug_print_in_release/avoid_debug_print_in_release_rule.dart';
import 'package:solid_lints/src/lints/avoid_global_state/avoid_global_state_rule.dart';

/// create plugin
final plugin = SolidLintsPlugin();

/// create plugin class
class SolidLintsPlugin extends Plugin {
  @override
  String get name => 'solid_lints';

  @override
  void register(PluginRegistry registry) {
    registry.registerLintRule(
      AvoidGlobalStateRule(),
    );
    registry.registerLintRule(
      AvoidDebugPrintInReleaseRule(),
    );
  }
}
