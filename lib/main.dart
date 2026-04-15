import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:solid_lints/src/lints/avoid_debug_print_in_release/avoid_debug_print_in_release_rule.dart';
import 'package:solid_lints/src/lints/avoid_global_state/avoid_global_state_rule.dart';

/// The entry point for the Solid Lints analyser server plugin.
///
/// This plugin integrates custom lint rules into the Dart analysis server,
/// allowing them to run during static analysis.
final plugin = SolidLintsPlugin();

/// An analysis server plugin that provides Solid lint rules.
///
/// This plugin registers custom lint rules and enables them to be executed
/// by the Dart analyzer during code analysis.
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
