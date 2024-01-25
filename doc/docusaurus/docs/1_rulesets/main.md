---
sidebar_label: Main
sidebar_position: 1
---

# Main rule set

This is a pre-configured set of rules meant to be used for static analysis of application code.

Full configuration: [analysis_options.yaml](https://github.com/solid-software/solid_lints/blob/master/lib/analysis_options.yaml)

Below are details on some of the rules; rationale for their usage or configuration.

## cyclomatic_complexity

According to the reference, we use **10** as the baseline value.

Reference:
NIST 500-235 item 2.5


## function_lines_of_code

We use the recommended value of **200** SLoC.

Reference:
McConnell, S. (2004), Chapter 7.4: High-Quality Routines: How Long Can a Routine Be?. Code Complete, Second Edition, Redmond, WA, USA: Microsoft Press. 173-174

## number_of_parameters

We follow the recommendation of maximum **7** routine parameters.

Reference:
McConnell, S. (2004), Chapter 7.5: High-Quality Routines: How To Use Routine Parameters. Code Complete, Second Edition, Redmond, WA, USA: Microsoft Press. 174-180

## prefer_expression_function_bodies

State: **Disabled**.

Not used, as the default app template has a single statement return code generated.
While this could be beneficial for Dart projects and maintaining code style, we are unaware
of any substantial evidence that improves code when using expression function body
vs single statement return. We are considering including this in Dart only lints.


## sort_constructors_first

State: **Disabled**.

We tend to use class organization close to standard Java convention, where fields come first.

Reference:
Martin, R. C. & Coplien, J. O. (2013), Chapter 10: Classes. Clean code: a handbook of agile software craftsmanship , Prentice Hall , Upper Saddle River, NJ [etc.] . 136
