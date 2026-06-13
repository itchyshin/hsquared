# hsquared 0.0.0.9000

## New features

* `animal()` is now exported as an inert formula marker, and `hsquared()` now parses the narrow v0.1 formula contract `animal(1 | id, pedigree = ped)` before stopping at the planned Julia bridge boundary (#4, #6).
* Added an internal R-to-Julia bridge payload builder for the v0.1 animal-model contract. It creates `y`, `X`, sparse `Z`, normalized pedigree metadata, and the validated Julia `animal_model_spec()` target, but still does not execute Julia or fit models (#6).
* Added Phase 0 project operating documentation, an honest placeholder `hsquared()` entry point, and `hs_control()` for planned engine controls.
