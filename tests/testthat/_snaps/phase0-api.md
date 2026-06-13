# hs_control validates engine_control

    Code
      hs_control(engine_control = "not-a-list")
    Condition
      Error:
      ! `engine_control` must be a list.

# hsquared validates basic call shape

    Code
      hsquared()
    Condition
      Error:
      ! `formula` is required.

---

    Code
      hsquared(y ~ x)
    Condition
      Error:
      ! `data` is required.

---

    Code
      hsquared(y ~ x, data = data.frame(y = 1, x = 1), control = list())
    Condition
      Error:
      ! `control` must be created by `hs_control()`.

# hsquared errors honestly before fitting

    Code
      hsquared(y ~ x, data = data.frame(y = 1, x = 1))
    Condition
      Error:
      ! `hsquared()` is a Phase 0 scaffold. Model fitting is not implemented yet. The first planned model is a Gaussian animal model with `animal(1 | id, pedigree = ped)`; see `docs/design/01-v0.1-contract.md`.
