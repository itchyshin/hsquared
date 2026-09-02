# Broadened known-truth DGP recovery study for the hsquared / HSquared.jl
# MULTIVARIATE (t = 3) REML estimator -- the MV-5 campaign PRE-REGISTERED in
# docs/design/40-mv-broadened-recovery-predeclaration.md. Extends the t = 2,
# single-truth-point, half-sib study (data-raw/multivariate-recovery-study.R) to
# **t = 3**, **TWO (G0, R0) truth points** (low and high genetic correlation),
# and a **FULL-SIB** design, lifting the covered scope from "bi-trait, single
# truth point" to genuine multi-trait recovery. The DGP is a faithful t = 3
# generalization of the verified t = 2 study (Cov(vec B) = G0 (x) A, Cov(vec E)
# = R0 (x) I; cold start from the identity).
#
# STATUS 2026-09-02 (A25): SUPERSEDED — do not run for 0.6. Engine full-sib /
# 3-trait / C8 already banked; doc 40 header SUPERSEDED. Gate env retained for
# historical integrity only.
# PRE-DECLARED GATE (doc 40; this file is committed at a SHA BEFORE any run, no
# post-hoc relaxation, 2026-06-14/06-22 rule): every INTERIOR G0/R0 element
# satisfies |bias| <= 2*MCSE at the screen seed count, in BOTH truth points.
# Derived r_g / per-trait h2 are checked by identity (MV-3), NOT separately
# bias-gated. Per-seed Frobenius is a diagnostic, NOT the gate. Screen tier =
# 48 seeds/cell; confirm tier = 500 on any cell that passes; a screen fail is
# banked negative (no re-seeded rescue).
#
# COMPUTE (doc 40): Totoro (384-core, no queue), OPENBLAS_NUM_THREADS=1,
# parallelism capped <= 96 cores; DRAC fir is the confirm-tier fallback.
# Requires local Julia + HSquared.jl + JuliaCall.
#
# PARALLELISM -- IMPORTANT. This R data-raw driver is the SERIAL reference DGP.
# Do NOT parallelize it with parallel::mclapply: mclapply FORKS R, and each fork
# embeds its own JuliaCall Julia -- fork + embedded Julia is segfault-prone (the
# known JuliaCall back-to-back-fit gotcha) and never uses Julia's native
# threading, where the speed actually is. The confirm-tier (500 seeds x 2 cells)
# should run as a PURE-JULIA sim in the twin: extend
# HSquared.jl/sim/phase4_multivariate_reml_recovery.jl to this t=3 /
# 2-truth-point / full-sib design and parallelize the SEED loop with Julia
# threading -- `julia -t 96 --project=.` + `Threads.@threads` (or
# Distributed/`pmap` with `addprocs(96)`), keeping OPENBLAS_NUM_THREADS=1 so BLAS
# does not oversubscribe against the seed threads. That is a Julia-lane hand-off
# (Codex or the user runs it; never concurrent with Claude). This R driver stays
# serial -- fine for the small screen, and it is the DGP oracle the Julia sim
# must match element-for-element.
# Run (screen):
#   HSQUARED_RUN_MV_BROADENED=true Rscript data-raw/multivariate-recovery-broadened-study.R
# Run (confirm):
#   HSQUARED_RUN_MV_BROADENED=true HSQUARED_MV_SEEDS=500 Rscript data-raw/multivariate-recovery-broadened-study.R
# Results land in a docs/dev-log/recovery-checkpoints/ file that cites this
# file's committed SHA. NOTE: a quick ADEMP / simulation-check review of the two
# truth points + full-sib design is owed before the confirm tier.

suppressWarnings(suppressMessages(library(hsquared)))

# -- Full-sib pedigree: n_sire x n_dam mating pairs, n_off full sibs per pair --
make_fullsib_pedigree <- function(
  n_sire = 12L,
  n_dam = 12L,
  n_off = 3L,
  seed = 20260711L
) {
  set.seed(seed)
  sires <- paste0("s", seq_len(n_sire))
  dams <- paste0("d", seq_len(n_dam))
  ids <- c(sires, dams)
  sire <- rep(NA_character_, length(ids))
  dam <- rep(NA_character_, length(ids))
  k <- 1L
  for (s in sires) {
    for (d in dams) {
      off <- paste0("o", k, "_", seq_len(n_off))
      ids <- c(ids, off)
      sire <- c(sire, rep(s, n_off))
      dam <- c(dam, rep(d, n_off))
      k <- k + 1L
    }
  }
  data.frame(id = ids, sire = sire, dam = dam, stringsAsFactors = FALSE)
}

# -- t = 3 multi-trait simulation (one record per animal) --
simulate_t3 <- function(ped, A, G0, R0, mu = c(5, 3, 4), seed = 1L) {
  set.seed(seed)
  n <- nrow(ped)
  t <- 3L
  U <- chol(A) # A = U'U
  LG <- t(chol(G0))
  LR <- t(chol(R0))
  Zg <- matrix(stats::rnorm(n * t), n, t)
  Ze <- matrix(stats::rnorm(n * t), n, t)
  B <- crossprod(U, Zg) %*% t(LG) # Cov(vec B) = G0 (x) A
  E <- Ze %*% t(LR) # Cov(vec E) = R0 (x) I
  Y <- sweep(B + E, 2L, mu, "+")
  list(
    data = data.frame(
      id = ped$id,
      y1 = Y[, 1L],
      y2 = Y[, 2L],
      y3 = Y[, 3L],
      stringsAsFactors = FALSE
    ),
    bv = B
  )
}

# -- Two pre-specified positive-definite (G0, R0) truth points --
TRUTHS <- list(
  low_rg = list(
    G0 = matrix(
      c(
        1.00,
        0.10,
        0.05,
        0.10,
        0.80,
        0.08,
        0.05,
        0.08,
        0.60
      ),
      3L,
      3L
    ),
    R0 = matrix(
      c(
        1.00,
        -0.05,
        0.02,
        -0.05,
        1.20,
        -0.03,
        0.02,
        -0.03,
        0.90
      ),
      3L,
      3L
    )
  ),
  high_rg = list(
    G0 = matrix(
      c(
        1.00,
        0.55,
        0.40,
        0.55,
        0.80,
        0.45,
        0.40,
        0.45,
        0.60
      ),
      3L,
      3L
    ),
    R0 = matrix(
      c(
        1.00,
        0.10,
        0.05,
        0.10,
        1.20,
        0.08,
        0.05,
        0.08,
        0.90
      ),
      3L,
      3L
    )
  )
)
# Both truth points must be PD; the pre-declaration forbids post-hoc truth edits.
stopifnot(all(vapply(
  TRUTHS,
  function(z) {
    min(eigen(z$G0, symmetric = TRUE, only.values = TRUE)$values) > 0 &&
      min(eigen(z$R0, symmetric = TRUE, only.values = TRUE)$values) > 0
  },
  logical(1L)
)))

master_seed <- 20260711L

run_cell <- function(truth, n_rep) {
  if (!requireNamespace("nadiv", quietly = TRUE)) {
    stop("nadiv is required to build A for the recovery study.")
  }
  ped <- make_fullsib_pedigree()
  A <- as.matrix(nadiv::makeA(ped))
  A <- A[ped$id, ped$id]
  set.seed(master_seed)
  seeds <- sample.int(.Machine$integer.max, n_rep)
  hats <- vector("list", n_rep)
  for (r in seq_len(n_rep)) {
    sim <- simulate_t3(ped, A, truth$G0, truth$R0, seed = seeds[r])
    dat <- merge(sim$data, ped, by = "id", all.x = TRUE)
    fit <- tryCatch(
      hsquared(
        cbind(y1, y2, y3) ~ 1 + animal(1 | id, pedigree = ped),
        data = dat,
        control = hs_control(
          engine = "julia",
          engine_control = list(
            target = "multivariate",
            initial = list(G0 = diag(3), R0 = diag(3))
          )
        )
      ),
      error = function(e) NULL
    )
    if (is.null(fit) || identical(fit$result$converged, FALSE)) {
      next
    }
    hats[[r]] <- list(
      G0 = genetic_covariance(fit),
      R0 = residual_covariance(fit)
    )
  }
  Filter(Negate(is.null), hats)
}

# -- Pre-declared bias/MCSE gate on the interior (lower-triangle) elements --
score_cell <- function(hats, truth) {
  score_mat <- function(getter, tru) {
    arr <- simplify2array(lapply(hats, getter))
    rows <- list()
    for (i in seq_len(nrow(tru))) {
      for (j in seq_len(i)) {
        x <- arr[i, j, ]
        bias <- mean(x) - tru[i, j]
        mcse <- stats::sd(x) / sqrt(length(x))
        rows[[sprintf("[%d,%d]", i, j)]] <- c(
          truth = tru[i, j],
          mean = mean(x),
          bias = bias,
          mcse = mcse,
          pass = as.numeric(abs(bias) <= 2 * mcse)
        )
      }
    }
    do.call(rbind, rows)
  }
  list(
    G0 = score_mat(function(h) h$G0, truth$G0),
    R0 = score_mat(function(h) h$R0, truth$R0),
    n = length(hats)
  )
}

if (identical(Sys.getenv("HSQUARED_RUN_MV_BROADENED"), "true")) {
  n_rep <- as.integer(Sys.getenv("HSQUARED_MV_SEEDS", "48"))
  overall_pass <- TRUE
  for (nm in names(TRUTHS)) {
    hats <- run_cell(TRUTHS[[nm]], n_rep)
    message(sprintf("[%s] converged %d / %d", nm, length(hats), n_rep))
    if (length(hats) == 0L) {
      overall_pass <- FALSE
      next
    }
    sc <- score_cell(hats, TRUTHS[[nm]])
    cat("\n== truth point:", nm, "(n =", sc$n, ") ==\nG0:\n")
    print(round(sc$G0, 5L))
    cat("R0:\n")
    print(round(sc$R0, 5L))
    cell_pass <- all(sc$G0[, "pass"] == 1) && all(sc$R0[, "pass"] == 1)
    cat("GATE (interior |bias| <= 2*MCSE) PASS:", cell_pass, "\n")
    overall_pass <- overall_pass && cell_pass
  }
  cat("\n==== MV-5 SCREEN GATE OVERALL PASS:", overall_pass, "====\n")
}
