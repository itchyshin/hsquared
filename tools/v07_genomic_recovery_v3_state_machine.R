#!/usr/bin/env Rscript

# Pure, source-safe recovery-v3 manifest state machine.  It creates no phenotype,
# fit, campaign seal, or evidence file.  The live campaign driver must consume
# these decisions rather than reimplementing adaptive selection.

v3_abort <- function(...) stop(sprintf(...), call. = FALSE)

v3_seed_base <- 2028000000
v3_ridge <- 0.01
v3_ratio_codes <- c(
  `0.5` = "q0500",
  `3.33333333333333` = "q3333",
  `5` = "q5000"
)
v3_n_levels <- c(120L, 300L, 600L, 1200L)
v3_ratio_levels <- c(0.5, 10 / 3, 5)
v3_truth_levels <- c(0.2, 0.5, 0.8)

v3_ratio_code <- function(x) {
  hit <- which(abs(v3_ratio_levels - x) < 1e-12)
  if (length(hit) != 1L) {
    v3_abort("unknown marker ratio: %.17g", x)
  }
  c("q0500", "q3333", "q5000")[[hit]]
}

v3_cell_id <- function(n, m, marker_ratio, truth_ratio) {
  sprintf(
    "n%04d_m%04d_%s_r%03d",
    as.integer(n),
    as.integer(m),
    v3_ratio_code(marker_ratio),
    as.integer(round(100 * truth_ratio))
  )
}

v3_cell_table <- local({
  rows <- vector(
    "list",
    length(v3_n_levels) * length(v3_ratio_levels) * length(v3_truth_levels)
  )
  at <- 0L
  for (n in v3_n_levels) {
    for (ratio in v3_ratio_levels) {
      m <- as.integer(round(n * ratio))
      for (truth in v3_truth_levels) {
        at <- at + 1L
        rows[[at]] <- data.frame(
          cell_id = v3_cell_id(n, m, ratio, truth),
          cell_index = at,
          n = as.integer(n),
          m = m,
          marker_ratio = ratio,
          marker_ratio_code = v3_ratio_code(ratio),
          truth_sigma_g2 = truth,
          truth_sigma_e2 = 1 - truth,
          truth_ratio = truth,
          ridge = v3_ridge,
          stringsAsFactors = FALSE
        )
      }
    }
  }
  out <- do.call(rbind, rows)
  stopifnot(
    nrow(out) == 36L,
    !anyDuplicated(out$cell_id),
    !anyDuplicated(out$cell_index)
  )
  out
})

v3_original_pairs <- data.frame(
  n = c(120L, 300L, 300L),
  m = c(600L, 150L, 1000L),
  stringsAsFactors = FALSE
)

v3_original_cells <- function() {
  hit <- do.call(
    rbind,
    lapply(seq_len(nrow(v3_original_pairs)), function(i) {
      with(
        v3_original_pairs[i, ],
        v3_cell_table[
          v3_cell_table$n == n & v3_cell_table$m == m,
          ,
          drop = FALSE
        ]
      )
    })
  )
  stopifnot(nrow(hit) == 9L)
  hit
}

v3_seed <- function(cell_index, seed_offset) {
  seed <- v3_seed_base + 10000 * as.double(cell_index) + as.double(seed_offset)
  if (
    any(!is.finite(seed)) || any(seed > .Machine$integer.max) || any(seed < 1)
  ) {
    v3_abort("v3 seed outside R integer range")
  }
  as.integer(seed)
}

v3_manifest <- function(stage, cells, counts = NULL) {
  if (!is.data.frame(cells) || !nrow(cells)) {
    v3_abort("manifest cells must be non-empty")
  }
  if (anyDuplicated(cells$cell_id)) {
    v3_abort("manifest cells are duplicated")
  }
  if (!all(cells$cell_id %in% v3_cell_table$cell_id)) {
    v3_abort("manifest contains unknown cell")
  }

  offsets <- switch(
    stage,
    d1 = function(cell, count) 101:148,
    d2 = function(cell, count) {
      start <- c(
        `120` = 1001L,
        `300` = 1101L,
        `600` = 1201L,
        `1200` = 1301L
      )[[as.character(cell$n)]]
      if (is.null(start)) {
        v3_abort("no D2 offset block for n=%d", cell$n)
      }
      start:(start + 47L)
    },
    d3 = function(cell, count) 2001:(2000L + count),
    d4 = function(cell, count) 5001:(5000L + count),
    v3_abort("unknown manifest stage: %s", stage)
  )

  if (stage %in% c("d3", "d4")) {
    if (is.null(counts) || is.null(names(counts))) {
      v3_abort("named confirmation counts are required")
    }
    if (!all(cells$cell_id %in% names(counts))) {
      v3_abort("confirmation count missing for a cell")
    }
    if (any(counts[cells$cell_id] < 200L | counts[cells$cell_id] > 2000L)) {
      v3_abort("confirmation counts must be inside 200:2000")
    }
  }

  rows <- lapply(seq_len(nrow(cells)), function(i) {
    cell <- cells[i, , drop = FALSE]
    count <- if (stage %in% c("d3", "d4")) {
      as.integer(counts[[cell$cell_id]])
    } else {
      48L
    }
    os <- offsets(cell, count)
    data.frame(
      stage = stage,
      cell_id = cell$cell_id,
      cell_index = cell$cell_index,
      seed_offset = os,
      seed = v3_seed(cell$cell_index, os),
      n = cell$n,
      m = cell$m,
      marker_ratio = cell$marker_ratio,
      marker_ratio_code = cell$marker_ratio_code,
      truth_sigma_g2 = cell$truth_sigma_g2,
      truth_sigma_e2 = cell$truth_sigma_e2,
      truth_ratio = cell$truth_ratio,
      ridge = cell$ridge,
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  key <- paste(out$stage, out$cell_id, out$seed, sep = "\r")
  if (anyDuplicated(key) || anyDuplicated(out$seed)) {
    v3_abort("manifest seed collision")
  }
  out
}

v3_d1_manifest <- function() {
  cells <- v3_cell_table[v3_cell_table$truth_ratio == 0.5, , drop = FALSE]
  v3_manifest("d1", cells)
}

v3_validate_decisions <- function(x, stage) {
  needed <- c("stage", "cell_id", "eligible", "required_n")
  if (!is.data.frame(x) || !all(needed %in% names(x))) {
    v3_abort("%s decisions have wrong schema", stage)
  }
  if (any(x$stage != stage)) {
    v3_abort("decision stage mismatch")
  }
  if (anyDuplicated(x$cell_id)) {
    v3_abort("duplicate %s decision", stage)
  }
  if (!all(x$cell_id %in% v3_cell_table$cell_id)) {
    v3_abort("unknown %s decision cell", stage)
  }
  if (identical(stage, "d1")) {
    expected <- v3_cell_table$cell_id[v3_cell_table$truth_ratio == 0.5]
    if (!setequal(x$cell_id, expected)) {
      v3_abort("D1 decisions must cover every and only interior ladder cell")
    }
  }
  if (identical(stage, "d2")) {
    truth <- v3_cell_table$truth_ratio[match(x$cell_id, v3_cell_table$cell_id)]
    if (any(!truth %in% c(0.2, 0.8))) {
      v3_abort("D2 decisions may contain edge cells only")
    }
  }
  if (!is.logical(x$eligible) || anyNA(x$eligible)) {
    v3_abort("eligible must be nonmissing logical")
  }
  if (
    !is.numeric(x$required_n) ||
      any(
        !is.na(x$required_n) &
          (!is.finite(x$required_n) |
            x$required_n < 1 |
            x$required_n != floor(x$required_n))
      )
  ) {
    v3_abort("required_n must be a positive whole number or NA")
  }
  if (
    any(x$eligible & (x$required_n < 200L | x$required_n > 2000L), na.rm = TRUE)
  ) {
    v3_abort("eligible decision has out-of-range required_n")
  }
  if (any(x$eligible & is.na(x$required_n))) {
    v3_abort("eligible cell lacks required_n")
  }
  invisible(TRUE)
}

v3_decision <- function(decisions, cell_id) {
  hit <- decisions$cell_id == cell_id
  if (!any(hit)) {
    return(NULL)
  }
  if (sum(hit) != 1L) {
    v3_abort("decision key is not unique")
  }
  decisions[hit, , drop = FALSE]
}

v3_original_edge_ids <- function(d1) {
  ids <- character()
  for (i in seq_len(nrow(v3_original_pairs))) {
    pair <- v3_original_pairs[i, ]
    interior <- v3_cell_table[
      v3_cell_table$n == pair$n &
        v3_cell_table$m == pair$m &
        v3_cell_table$truth_ratio == 0.5,
      ,
      drop = FALSE
    ]
    z <- v3_decision(d1, interior$cell_id)
    if (!is.null(z) && isTRUE(z$eligible)) {
      ids <- c(
        ids,
        v3_cell_table$cell_id[
          v3_cell_table$n == pair$n &
            v3_cell_table$m == pair$m &
            v3_cell_table$truth_ratio %in% c(0.2, 0.8)
        ]
      )
    }
  }
  unique(ids)
}

v3_d2_next_cells <- function(
  d1,
  d2 = data.frame(
    stage = character(),
    cell_id = character(),
    eligible = logical(),
    required_n = integer()
  )
) {
  v3_validate_decisions(d1, "d1")
  v3_validate_decisions(d2, "d2")
  v3_selected_cells(d1, d2)
  needed <- character()

  for (ratio in v3_ratio_levels) {
    interiors <- v3_cell_table[
      abs(v3_cell_table$marker_ratio - ratio) < 1e-12 &
        v3_cell_table$truth_ratio == 0.5,
      ,
      drop = FALSE
    ]
    interiors <- interiors[order(interiors$n), , drop = FALSE]
    eligible_n <- interiors$n[vapply(
      interiors$cell_id,
      function(id) {
        z <- v3_decision(d1, id)
        !is.null(z) && isTRUE(z$eligible)
      },
      logical(1L)
    )]

    selected <- FALSE
    for (n in eligible_n) {
      edges <- v3_cell_table[
        abs(v3_cell_table$marker_ratio - ratio) < 1e-12 &
          v3_cell_table$n == n &
          v3_cell_table$truth_ratio %in% c(0.2, 0.8),
        ,
        drop = FALSE
      ]
      ed <- lapply(edges$cell_id, v3_decision, decisions = d2)
      present <- !vapply(ed, is.null, logical(1L))
      if (any(present) && !all(present)) {
        v3_abort(
          "partial D2 edge batch for ratio=%s n=%d",
          v3_ratio_code(ratio),
          n
        )
      }
      if (!all(present)) {
        needed <- c(needed, edges$cell_id)
        break
      }
      if (all(vapply(ed, function(z) isTRUE(z$eligible), logical(1L)))) {
        selected <- TRUE
        break
      }
    }
    if (selected) next
  }

  # Mandatory original-cell broad pilots.  An ineligible original interior is
  # already a broad-lane stop, so it does not generate edge data.
  for (i in seq_len(nrow(v3_original_pairs))) {
    pair <- v3_original_pairs[i, ]
    interior <- v3_cell_table[
      v3_cell_table$n == pair$n &
        v3_cell_table$m == pair$m &
        v3_cell_table$truth_ratio == 0.5,
      ,
      drop = FALSE
    ]
    z <- v3_decision(d1, interior$cell_id)
    if (is.null(z) || !isTRUE(z$eligible)) {
      next
    }
    edges <- v3_cell_table[
      v3_cell_table$n == pair$n &
        v3_cell_table$m == pair$m &
        v3_cell_table$truth_ratio %in% c(0.2, 0.8),
      ,
      drop = FALSE
    ]
    ed <- lapply(edges$cell_id, v3_decision, decisions = d2)
    present <- !vapply(ed, is.null, logical(1L))
    if (any(present) && !all(present)) {
      v3_abort("partial original-cell D2 edge batch")
    }
    if (!all(present)) needed <- c(needed, edges$cell_id)
  }

  needed <- unique(needed)
  v3_cell_table[
    match(needed, v3_cell_table$cell_id, nomatch = 0L),
    ,
    drop = FALSE
  ]
}

v3_selected_cells <- function(d1, d2) {
  v3_validate_decisions(d1, "d1")
  v3_validate_decisions(d2, "d2")
  selected <- character()
  allowed <- v3_original_edge_ids(d1)
  for (ratio in v3_ratio_levels) {
    interiors <- v3_cell_table[
      abs(v3_cell_table$marker_ratio - ratio) < 1e-12 &
        v3_cell_table$truth_ratio == 0.5,
      ,
      drop = FALSE
    ]
    interiors <- interiors[order(interiors$n), , drop = FALSE]
    for (i in seq_len(nrow(interiors))) {
      iz <- v3_decision(d1, interiors$cell_id[[i]])
      if (is.null(iz) || !isTRUE(iz$eligible)) {
        next
      }
      triplet <- v3_cell_table[
        v3_cell_table$n == interiors$n[[i]] &
          abs(v3_cell_table$marker_ratio - ratio) < 1e-12,
        ,
        drop = FALSE
      ]
      edge_ids <- triplet$cell_id[triplet$truth_ratio != 0.5]
      ez <- lapply(edge_ids, v3_decision, decisions = d2)
      present <- !vapply(ez, is.null, logical(1L))
      if (any(present) && !all(present)) {
        v3_abort(
          "partial D2 edge batch for ratio=%s n=%d",
          v3_ratio_code(ratio),
          interiors$n[[i]]
        )
      }
      if (!all(present)) {
        break
      }
      allowed <- c(allowed, edge_ids)
      if (all(vapply(ez, function(z) isTRUE(z$eligible), logical(1L)))) {
        selected <- c(selected, triplet$cell_id)
        break
      }
    }
  }
  extra <- setdiff(d2$cell_id, unique(allowed))
  if (length(extra)) {
    v3_abort("D2 decisions contain a post-stop or out-of-order edge batch")
  }
  v3_cell_table[
    match(selected, v3_cell_table$cell_id, nomatch = 0L),
    ,
    drop = FALSE
  ]
}

v3_required_counts <- function(cells, d1, d2) {
  v3_validate_decisions(d1, "d1")
  v3_validate_decisions(d2, "d2")
  counts <- setNames(integer(nrow(cells)), cells$cell_id)
  for (id in cells$cell_id) {
    cell <- v3_cell_table[v3_cell_table$cell_id == id, , drop = FALSE]
    source <- if (cell$truth_ratio == 0.5) d1 else d2
    z <- v3_decision(source, id)
    if (is.null(z) || !isTRUE(z$eligible)) {
      v3_abort("confirmation cell lacks one eligible pilot source")
    }
    counts[[id]] <- as.integer(z$required_n)
  }
  counts
}

v3_d3_manifest <- function(d1, d2) {
  cells <- v3_selected_cells(d1, d2)
  if (!nrow(cells)) {
    v3_abort("no exact triplet is eligible for D3")
  }
  v3_manifest("d3", cells, v3_required_counts(cells, d1, d2))
}

v3_d4_manifest <- function(d1, d2) {
  cells <- v3_original_cells()
  counts <- v3_required_counts(cells, d1, d2)
  v3_manifest("d4", cells, counts)
}

v3_fake_decisions <- function(
  stage,
  cells,
  eligible = TRUE,
  required_n = 200L
) {
  data.frame(
    stage = stage,
    cell_id = cells$cell_id,
    eligible = rep_len(as.logical(eligible), nrow(cells)),
    required_n = rep_len(as.integer(required_n), nrow(cells)),
    stringsAsFactors = FALSE
  )
}

v3_selftest <- function() {
  stopifnot(nrow(v3_cell_table) == 36L, nrow(v3_original_cells()) == 9L)
  d1m <- v3_d1_manifest()
  stopifnot(nrow(d1m) == 576L, !anyDuplicated(d1m$seed))

  d1cells <- v3_cell_table[v3_cell_table$truth_ratio == 0.5, , drop = FALSE]
  d1 <- v3_fake_decisions(
    "d1",
    d1cells,
    eligible = d1cells$n >= 300L,
    required_n = 350L
  )
  d1$required_n[!d1$eligible] <- 16000L
  v3_validate_decisions(d1, "d1")
  stopifnot(inherits(
    try(v3_validate_decisions(d1[-1L, , drop = FALSE], "d1"), silent = TRUE),
    "try-error"
  ))
  bad_required_n <- d1
  bad_required_n$required_n[[1L]] <- 350.5
  stopifnot(inherits(
    try(v3_validate_decisions(bad_required_n, "d1"), silent = TRUE),
    "try-error"
  ))
  interior_d2 <- v3_fake_decisions(
    "d2",
    d1cells[1L, , drop = FALSE],
    eligible = TRUE,
    required_n = 350L
  )
  stopifnot(inherits(
    try(v3_validate_decisions(interior_d2, "d2"), silent = TRUE),
    "try-error"
  ))
  next_cells <- v3_d2_next_cells(d1)
  stopifnot(
    nrow(next_cells) == 6L,
    all(next_cells$n == 300L),
    all(next_cells$truth_ratio %in% c(0.2, 0.8))
  )

  d2 <- v3_fake_decisions("d2", next_cells, eligible = TRUE, required_n = 400L)
  half_batch <- d2[-1L, , drop = FALSE]
  stopifnot(inherits(
    try(v3_d2_next_cells(d1, half_batch), silent = TRUE),
    "try-error"
  ))
  stopifnot(inherits(
    try(v3_selected_cells(d1, half_batch), silent = TRUE),
    "try-error"
  ))

  out_of_order <- v3_fake_decisions(
    "d2",
    v3_cell_table[
      v3_cell_table$n == 600L &
        abs(v3_cell_table$marker_ratio - 0.5) < 1e-12 &
        v3_cell_table$truth_ratio %in% c(0.2, 0.8),
      ,
      drop = FALSE
    ],
    eligible = TRUE,
    required_n = 400L
  )
  stopifnot(inherits(
    try(v3_selected_cells(d1, out_of_order), silent = TRUE),
    "try-error"
  ))
  d1_all <- d1
  d1_all$eligible <- TRUE
  d1_all$required_n <- 350L
  pass_then_extra <- v3_fake_decisions(
    "d2",
    v3_cell_table[
      abs(v3_cell_table$marker_ratio - 10 / 3) < 1e-12 &
        v3_cell_table$n %in% c(120L, 600L) &
        v3_cell_table$truth_ratio %in% c(0.2, 0.8),
      ,
      drop = FALSE
    ],
    eligible = TRUE,
    required_n = 400L
  )
  stopifnot(inherits(
    try(v3_selected_cells(d1_all, pass_then_extra), silent = TRUE),
    "try-error"
  ))
  broad_only <- v3_fake_decisions(
    "d2",
    v3_original_cells()[
      v3_original_cells()$truth_ratio %in% c(0.2, 0.8),
      ,
      drop = FALSE
    ],
    eligible = TRUE,
    required_n = 400L
  )
  stopifnot(
    !inherits(
      try(v3_selected_cells(d1_all, broad_only), silent = TRUE),
      "try-error"
    )
  )
  selected <- v3_selected_cells(d1, d2)
  stopifnot(nrow(selected) == 9L, all(selected$n == 300L))
  d3 <- v3_d3_manifest(d1, d2)
  stopifnot(nrow(d3) == 3L * 350L + 6L * 400L, !anyDuplicated(d3$seed))

  # Force the first ratio's n=300 edge to fail.  The next request must be the
  # n=600 edge pair for that ratio only; failed n=300 is never repeated.
  first_ratio_edge <- abs(next_cells$marker_ratio - 0.5) < 1e-12
  d2$eligible[first_ratio_edge] <- FALSE
  next2 <- v3_d2_next_cells(d1, d2)
  stopifnot(
    nrow(next2) == 2L,
    all(next2$n == 600L),
    all(abs(next2$marker_ratio - 0.5) < 1e-12)
  )

  # D4 requires the exact original cells.  Make all original interiors and
  # edges eligible, independently of the selected ladder triplets.
  original <- v3_original_cells()
  original_interior <- original[original$truth_ratio == 0.5, , drop = FALSE]
  d1$eligible[match(original_interior$cell_id, d1$cell_id)] <- TRUE
  d1$required_n[match(original_interior$cell_id, d1$cell_id)] <- 500L
  original_edges <- original[original$truth_ratio != 0.5, , drop = FALSE]
  d2_original <- v3_fake_decisions(
    "d2",
    original_edges,
    eligible = TRUE,
    required_n = 600L
  )
  d2_all <- rbind(
    d2[!d2$cell_id %in% d2_original$cell_id, , drop = FALSE],
    d2_original
  )
  d4 <- v3_d4_manifest(d1, d2_all)
  stopifnot(nrow(d4) == 3L * 500L + 6L * 600L, !anyDuplicated(d4$seed))
  stopifnot(!length(intersect(d3$seed, d4$seed)))

  partial <- d2_all[
    d2_all$cell_id != original_edges$cell_id[[1L]],
    ,
    drop = FALSE
  ]
  failed <- inherits(
    try(v3_d4_manifest(d1, partial), silent = TRUE),
    "try-error"
  )
  stopifnot(failed)

  message(
    "v0.7 genomic recovery-v3 state-machine selftest: PASS (no data generated)"
  )
  invisible(TRUE)
}

v3_option <- function(args, key, default = NULL) {
  prefix <- paste0("--", key, "=")
  hit <- startsWith(args, prefix)
  if (!any(hit)) {
    return(default)
  }
  if (sum(hit) != 1L) {
    v3_abort("option --%s must appear once", key)
  }
  substring(args[hit], nchar(prefix) + 1L)
}

v3_main <- function(args = commandArgs(trailingOnly = TRUE)) {
  mode <- v3_option(args, "mode", "selftest")
  if (identical(mode, "selftest")) {
    return(v3_selftest())
  }
  if (identical(mode, "print-d1")) {
    utils::write.table(
      v3_d1_manifest(),
      stdout(),
      sep = "\t",
      row.names = FALSE,
      quote = FALSE
    )
    return(invisible(TRUE))
  }
  v3_abort("unknown mode: %s", mode)
}

if (sys.nframe() == 0L) {
  v3_main()
}
