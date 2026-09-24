# Solid Lints
[![style: solid](https://img.shields.io/badge/style-solid-orange)](https://pub.dev/packages/solid_lints)
[![$solid_lints](https://nokycucwgzweensacwfy.supabase.co/functions/v1/get_project_badge?projectId=211)](https://nokycucwgzweensacwfy.supabase.co/functions/v1/get_project_url?projectId=211)


Flutter/Dart lints configuration based on software engineering industry standards (ISO/IEC, NIST) and best practices, developed and maintained by [Solid Software](https://solid.software).

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
  solid_lints: <INSERT LATEST VERSION>

solid_lints:
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

---

## Maintained by Solid Software

<div align="center">
  <a href="https://solid.software">
    <img
      src="https://cdn.prod.website-files.com/5d2846ce4f9c9d7eaa10af6f/6ab224b7413668876044fe2b_b2a4a0df6b23cbc8297c7581e979fb22_solid_software_logo_dark.png"
      alt="Solid Software"
      width="250"
    />
  </a>
</div>

Developed and maintained by **[Solid Software](https://solid.software)** - a top Flutter agency and official Flutter consultants focused on high-quality software engineering.

### Why Solid Software?

- Working with Flutter since 2018 - early adopters and experts.
- AI Development and Integration: modern AI-driven development workflows that accelerate time-to-market while ensuring clean, reliable code.
- Full-cycle delivery & team augmentation.

<div align="center">
  <br />

  [💬 Hire Us](https://solid.software/#solid-footer) &nbsp;&nbsp;•&nbsp;&nbsp; [Other packages](https://pub.dev/publishers/solid.software/packages)

</div>
