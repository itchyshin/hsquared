# Shared helpers for cbind() + permanent() recovery and comparator (hsquared #237).
# Auto-loaded by testthat. Experimental 0.9.0; public_covered_count stays 7.

hs_237_recovery_truth <- function() {
  list(
    G0 = matrix(c(1.00, 0.30, 0.30, 0.80), 2L, 2L),
    P0 = matrix(c(0.50, 0.10, 0.10, 0.40), 2L, 2L),
    R0 = matrix(c(0.80, 0.15, 0.15, 0.70), 2L, 2L)
  )
}

hs_237_recovery_pedigree <- function(nsire = 8L, ndam = 16L, noff = 48L) {
  sire_ids <- paste0("s", seq_len(nsire))
  dam_ids <- paste0("d", seq_len(ndam))
  off_ids <- paste0("o", seq_len(noff))
  data.frame(
    id = c(sire_ids, dam_ids, off_ids),
    sire = c(
      rep(NA_character_, nsire + ndam),
      sire_ids[((seq_len(noff) - 1L) %% nsire) + 1L]
    ),
    dam = c(
      rep(NA_character_, nsire + ndam),
      dam_ids[((seq_len(noff) - 1L) %% ndam) + 1L]
    ),
    stringsAsFactors = FALSE
  )
}

hs_237_point_julia_recovery <- function() {
  jl_wt <- path.expand("~/local-scratch/lanes/HSquared.jl-237-recovery")
  if (
    !nzchar(Sys.getenv("HSQUARED_JULIA_PROJECT", "")) &&
      file.exists(file.path(jl_wt, "Project.toml"))
  ) {
    Sys.setenv(HSQUARED_JULIA_PROJECT = jl_wt)
  }
  invisible(jl_wt)
}

hs_237_simulate_mvpe <- function(seed = 20260926L, records = 4L) {
  truth <- hs_237_recovery_truth()
  ped <- hs_237_recovery_pedigree()
  set.seed(as.integer(seed))
  q <- nrow(ped)
  u1 <- as.numeric(hs_sim_genedrop_bv(ped, sigma_a2 = truth$G0[1, 1], seed = seed))
  u2_ind <- as.numeric(hs_sim_genedrop_bv(
    ped,
    sigma_a2 = truth$G0[2, 2],
    seed = seed + 1L
  ))
  rg <- truth$G0[2, 1] / sqrt(truth$G0[1, 1] * truth$G0[2, 2])
  u2 <- rg * u1 * sqrt(truth$G0[2, 2] / truth$G0[1, 1]) +
    sqrt(max(0, 1 - rg^2)) * u2_ind
  pe1 <- stats::rnorm(q, 0, sqrt(truth$P0[1, 1]))
  pe2 <- (truth$P0[2, 1] / truth$P0[1, 1]) * pe1 +
    stats::rnorm(
      q,
      0,
      sqrt(max(1e-8, truth$P0[2, 2] - truth$P0[2, 1]^2 / truth$P0[1, 1]))
    )
  ids <- rep(ped$id, each = records)
  e1 <- stats::rnorm(q * records, 0, sqrt(truth$R0[1, 1]))
  e2 <- (truth$R0[2, 1] / truth$R0[1, 1]) * e1 +
    stats::rnorm(
      q * records,
      0,
      sqrt(max(1e-8, truth$R0[2, 2] - truth$R0[2, 1]^2 / truth$R0[1, 1]))
    )
  idx <- match(ids, ped$id)
  dat <- data.frame(
    id = ids,
    y1 = 2 + u1[idx] + pe1[idx] + e1,
    y2 = 2 + u2[idx] + pe2[idx] + e2,
    stringsAsFactors = FALSE
  )
  list(ped = ped, dat = dat, truth = truth)
}

hs_237_fit_mvpe <- function(fx) {
  truth <- fx$truth
  hsquared(
    cbind(y1, y2) ~ animal(1 | id, pedigree = fx$ped) + permanent(1 | id),
    data = fx$dat,
    family = stats::gaussian(),
    REML = TRUE,
    control = hs_control(
      engine = "julia",
      engine_control = list(
        initial = list(G0 = truth$G0, P0 = truth$P0, R0 = truth$R0)
      )
    )
  )
}

hs_237_sommer_mvpe <- function(fx) {
  if (!requireNamespace("nadiv", quietly = TRUE)) {
    stop("nadiv is required for the sommer PE comparator.", call. = FALSE)
  }
  if (!requireNamespace("sommer", quietly = TRUE)) {
    stop("sommer is required for the PE comparator.", call. = FALSE)
  }
  pedn <- fx$ped
  A <- suppressWarnings(as.matrix(nadiv::makeA(pedn)))
  A <- A[pedn$id, pedn$id]
  phe <- fx$dat
  phe$animal <- factor(phe$id, levels = rownames(A))
  phe$pe <- phe$animal
  # sommer 4.4.5 does not export ide(); PE is an identity animal term
  # on a copy of the id factor (same estimand as ide(animal)).
  sm <- suppressWarnings(sommer::mmer(
    cbind(y1, y2) ~ 1,
    random = ~ sommer::vsr(animal, Gu = A, Gtc = sommer::unsm(2)) +
      sommer::vsr(pe, Gtc = sommer::unsm(2)),
    rcov = ~ sommer::vsr(units, Gtc = sommer::unsm(2)),
    data = phe,
    verbose = FALSE,
    dateWarning = FALSE
  ))
  list(
    fit = sm,
    G0 = sm$sigma[["u:animal"]],
    P0 = sm$sigma[["u:pe"]],
    R0 = sm$sigma[["u:units"]]
  )
}

hs_237_vc_diag <- function(fit, component, trait) {
  vc <- variance_components(fit)
  out <- vc$estimate[vc$component == component & vc$trait == trait]
  if (length(out) != 1L) {
    stop(
      "expected one ",
      component,
      " diagonal for ",
      trait,
      "; got ",
      length(out),
      call. = FALSE
    )
  }
  as.numeric(out)
}
