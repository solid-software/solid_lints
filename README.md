# Solid Lints
[![style: solid](https://img.shields.io/badge/style-solid-orange)](https://pub.dev/packages/solid_lints)
[![$solid_lints](https://nokycucwgzweensacwfy.supabase.co/functions/v1/get_project_badge?projectId=211)](https://nokycucwgzweensacwfy.supabase.co/functions/v1/get_project_url?projectId=211)


Flutter/Dart lints configuration based on software engineering industry standards (ISO/IEC, NIST) and best practices.

# Documentation

For more detailed information and guidelines on using Solid Lints, please refer to the documentation: 
* https://lints.solid.software

# Usage

Add dependency in your pubspec.yaml:

```yaml
dev_dependencies:
  solid_lints: <INSERT LATEST VERSION>
```

Enable the plugin and include `solid_lints` in your project's top-level `analysis_options.yaml`:

```yaml
include: package:solid_lints/analysis_options.yaml

plugins:
  solid_lints: <INSERT LATEST VERSION>
```

Also, you can use a specialized rule set designed for Dart tests.
Add an `analysis_options.yaml` file under the `test/` directory, and include the ruleset:

```yaml
include: package:solid_lints/analysis_options_test.yaml

plugins:
  solid_lints: <INSERT LATEST VERSION>
```

Then you can see suggestions in your IDE or you can run checks manually:

```bash
dart analyze
```

# Configuration

You can customize individual rule settings in your `analysis_options.yaml`:

```yaml
plugins:
  solid_lints:
    version: <INSERT LATEST VERSION>
    diagnostics:
      cyclomatic_complexity:
        max_complexity: 10
      avoid_non_null_assertion: true
```

# Badge

To indicate that your project is using Solid Lints, you can use the following badge:

```markdown
[![style: solid](https://img.shields.io/badge/style-solid-orange)](https://pub.dev/packages/solid_lints)
```
