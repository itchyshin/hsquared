#!/usr/bin/env Rscript

# Independent source-safe seed-space verifier for recovery-v3. This tool does
# not source a campaign driver or load hsquared.

v07s_lock_columns <- c(
  "contract_id",
  "source_docs",
  "formula_kind",
  "seed_base",
  "cell_indices",
  "offset_start",
  "offset_end",
  "disposition"
)

v07s_expected_lock <- data.frame(
  contract_id = c(
    "doc44_fixture",
    "doc44_pilot",
    "doc44_confirmation",
    "doc47_holdout",
    "doc48_holdout_complement",
    "doc47_boundary_holdout",
    "doc48_boundary_complement",
    "doc48_failed_environment",
    "doc48_precision_blocker",
    "doc48_successor_pilot",
    "doc48_successor_confirmation"
  ),
  source_docs = c(
    "doc44",
    "doc44",
    "doc44",
    "doc47",
    "doc48",
    "doc47",
    "doc48",
    "doc48",
    "doc48",
    "doc48",
    "doc48"
  ),
  formula_kind = c("exact", rep("cell_offset", 10L)),
  seed_base = c(20270701, rep(2027120000, 10L)),
  cell_indices = c(
    "0",
    "1:9",
    "1:9",
    "1,2,3,7,9",
    "4,5,6,8",
    "1,2,3,7,9",
    "4,5,6,8",
    "1:9",
    "1:9",
    "1:9",
    "1:9"
  ),
  offset_start = c(0, 1, 1001, 5001, 5001, 6001, 6001, 7001, 7101, 7201, 8001),
  offset_end = c(0, 48, 3000, 5048, 5048, 6048, 6048, 7048, 7148, 7248, 10000),
  disposition = c(
    "spent",
    "spent",
    "spent_or_reserved",
    "spent",
    "reserved",
    "spent",
    "reserved",
    "spent",
    "spent",
    "reserved",
    "reserved"
  ),
  stringsAsFactors = FALSE
)
v07s_expected_lock[] <- lapply(v07s_expected_lock, as.character)

v07s_loaded_source_path <- local({
  file_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  frame_files <- vapply(
    sys.frames(),
    function(frame) {
      value <- frame$ofile
      if (is.null(value)) "" else as.character(value[[1L]])
    },
    character(1L)
  )
  candidates <- c(
    sub("^--file=", "", file_arg),
    rev(frame_files[nzchar(frame_files)])
  )
  if (!length(candidates)) {
    NULL
  } else {
    normalizePath(
      candidates[[1L]],
      winslash = "/",
      mustWork = TRUE
    )
  }
})

v07s_abort <- function(...) stop(sprintf(...), call. = FALSE)

v07s_option <- function(args, key, default = NULL) {
  prefix <- paste0("--", key, "=")
  hit <- args[startsWith(args, prefix)]
  if (!length(hit)) {
    return(default)
  }
  if (length(hit) != 1L) {
    v07s_abort("option --%s must occur exactly once", key)
  }
  sub(prefix, "", hit[[1L]], fixed = TRUE)
}

v07s_source_path <- function() {
  v07s_loaded_source_path
}

v07s_default_lock <- function() {
  script <- v07s_source_path()
  if (is.null(script)) {
    v07s_abort("--lock is required when the source path is unavailable")
  }
  file.path(
    dirname(dirname(script)),
    "docs",
    "design",
    "historical_seed_lock.tsv"
  )
}

v07s_parse_indices <- function(value) {
  if (length(value) != 1L || is.na(value) || !nzchar(value)) {
    v07s_abort("cell_indices must be one nonempty token")
  }
  pieces <- strsplit(value, ",", fixed = TRUE)[[1L]]
  out <- unlist(
    lapply(pieces, function(piece) {
      if (grepl("^[0-9]+$", piece)) {
        return(as.numeric(piece))
      }
      if (grepl("^[0-9]+:[0-9]+$", piece)) {
        ends <- as.numeric(strsplit(piece, ":", fixed = TRUE)[[1L]])
        if (ends[[1L]] > ends[[2L]]) {
          v07s_abort("descending cell_indices range: %s", piece)
        }
        return(seq.int(ends[[1L]], ends[[2L]]))
      }
      v07s_abort("invalid cell_indices token: %s", piece)
    }),
    use.names = FALSE
  )
  if (anyDuplicated(out)) {
    v07s_abort("cell_indices contains a duplicate")
  }
  out
}

v07s_read_lock <- function(path) {
  if (!file.exists(path) || isTRUE(file.info(path)$isdir)) {
    v07s_abort("historical seed lock is missing: %s", path)
  }
  out <- utils::read.delim(
    path,
    sep = "\t",
    quote = "",
    comment.char = "",
    check.names = FALSE,
    stringsAsFactors = FALSE,
    colClasses = "character"
  )
  if (
    !identical(names(out), v07s_lock_columns) ||
      !identical(out, v07s_expected_lock)
  ) {
    v07s_abort("historical seed lock schema, order, or frozen content drift")
  }
  out
}

v07s_expand_historical <- function(lock) {
  rows <- vector("list", nrow(lock))
  for (i in seq_len(nrow(lock))) {
    row <- lock[i, , drop = FALSE]
    seed_base <- as.numeric(row$seed_base)
    offset_start <- as.numeric(row$offset_start)
    offset_end <- as.numeric(row$offset_end)
    if (row$formula_kind == "exact") {
      if (row$cell_indices != "0" || offset_start != 0 || offset_end != 0) {
        v07s_abort("exact historical seed row has nonzero formula coordinates")
      }
      seeds <- seed_base
    } else if (row$formula_kind == "cell_offset") {
      cells <- v07s_parse_indices(row$cell_indices)
      if (any(cells < 1) || offset_start > offset_end) {
        v07s_abort("invalid historical cell-offset range")
      }
      seeds <- unlist(
        lapply(cells, function(cell) {
          seed_base + 10000 * cell + seq.int(offset_start, offset_end)
        }),
        use.names = FALSE
      )
    } else {
      v07s_abort("unknown historical formula kind: %s", row$formula_kind)
    }
    rows[[i]] <- data.frame(
      contract_id = row$contract_id,
      seed = seeds,
      stringsAsFactors = FALSE
    )
  }
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  if (anyDuplicated(out$seed)) {
    v07s_abort("historical lock expands to duplicate exact seeds")
  }
  out
}

v07s_v3_cells <- function() {
  design <- data.frame(
    n = c(120, 120, 120, 300, 300, 300, 600, 600, 600, 1200, 1200, 1200),
    m = c(60, 400, 600, 150, 1000, 1500, 300, 2000, 3000, 600, 4000, 6000),
    stringsAsFactors = FALSE
  )
  rows <- lapply(seq_len(nrow(design)), function(i) {
    data.frame(
      n = design$n[[i]],
      m = design$m[[i]],
      truth_ratio = c(0.2, 0.5, 0.8)
    )
  })
  out <- do.call(rbind, rows)
  out$cell_index <- seq_len(nrow(out))
  out$cell_id <- sprintf(
    "n%d_m%d_r%03d",
    out$n,
    out$m,
    as.integer(round(100 * out$truth_ratio))
  )
  out[c("cell_id", "cell_index", "n", "m", "truth_ratio")]
}

v07s_expand_v3 <- function() {
  cells <- v07s_v3_cells()
  rows <- list()
  add <- function(stage, cell_rows, offsets) {
    pieces <- lapply(seq_len(nrow(cell_rows)), function(i) {
      cell <- cell_rows[i, , drop = FALSE]
      data.frame(
        stage = stage,
        cell_id = cell$cell_id,
        cell_index = cell$cell_index,
        seed_offset = offsets(cell),
        stringsAsFactors = FALSE
      )
    })
    do.call(rbind, pieces)
  }
  rows[[1L]] <- add("D1", cells[cells$truth_ratio == 0.5, ], function(cell) {
    101:148
  })
  rows[[2L]] <- add("D2", cells[cells$truth_ratio != 0.5, ], function(cell) {
    start <- c(
      `120` = 1001,
      `300` = 1101,
      `600` = 1201,
      `1200` = 1301
    )[[as.character(cell$n)]]
    start:(start + 47)
  })
  rows[[3L]] <- add("D3", cells, function(cell) 2001:4000)
  original <- cells[
    paste(cells$n, cells$m) %in% c("120 600", "300 150", "300 1000"),
  ]
  rows[[4L]] <- add("D4", original, function(cell) 5001:7000)
  standard <- do.call(rbind, rows)
  standard$seed <- 2028000000 +
    10000 * standard$cell_index +
    standard$seed_offset

  d0f <- do.call(
    rbind,
    lapply(seq_len(3L), function(design_index) {
      do.call(
        rbind,
        lapply(seq_len(8L), function(panel_rank) {
          data.frame(
            stage = "D0F",
            cell_id = sprintf("design%d_panel%d", design_index, panel_rank),
            cell_index = design_index,
            seed_offset = seq_len(24L),
            seed = 2029000000 +
              100000 * design_index +
              1000 * panel_rank +
              seq_len(24L),
            stringsAsFactors = FALSE
          )
        })
      )
    })
  )
  out <- rbind(standard, d0f)
  rownames(out) <- NULL
  out
}

v07s_validate_spaces <- function(lock, proposed = v07s_expand_v3()) {
  historical <- v07s_expand_historical(lock)
  required <- c("stage", "cell_id", "cell_index", "seed_offset", "seed")
  if (
    !identical(names(proposed), required) ||
      anyNA(proposed) ||
      any(proposed$seed != floor(proposed$seed)) ||
      any(proposed$seed < 1) ||
      any(proposed$seed > .Machine$integer.max)
  ) {
    v07s_abort("v3 seed table schema or integer range is invalid")
  }
  if (anyDuplicated(proposed$seed)) {
    v07s_abort("v3 stages contain an exact seed collision")
  }
  overlap <- intersect(historical$seed, proposed$seed)
  if (length(overlap)) {
    v07s_abort("v3 seed intersects historical lock: %.0f", overlap[[1L]])
  }
  if (2027142001 %in% proposed$seed) {
    v07s_abort("known historical collision 2027142001 was admitted")
  }
  invisible(list(historical = historical, proposed = proposed))
}

v07s_selftest <- function(lock_path = v07s_default_lock()) {
  lock <- v07s_read_lock(lock_path)
  valid <- v07s_validate_spaces(lock)
  stage_counts <- table(valid$proposed$stage)
  stopifnot(
    2027142001 %in% valid$historical$seed,
    nrow(valid$proposed) == 92304L,
    identical(names(stage_counts), c("D0F", "D1", "D2", "D3", "D4")),
    identical(as.integer(stage_counts), c(576L, 576L, 1152L, 72000L, 18000L))
  )
  collision <- valid$proposed
  collision$seed[[1L]] <- 2027142001
  stopifnot(inherits(
    try(v07s_validate_spaces(lock, collision), silent = TRUE),
    "try-error"
  ))
  duplicate <- valid$proposed
  duplicate$seed[[2L]] <- duplicate$seed[[1L]]
  stopifnot(inherits(
    try(v07s_validate_spaces(lock, duplicate), silent = TRUE),
    "try-error"
  ))
  message(sprintf(
    "recovery-v3 seed lock selftest: PASS (%d historical; %d possible v3 seeds)",
    nrow(valid$historical),
    nrow(valid$proposed)
  ))
  invisible(valid)
}

v07s_main <- function(args = commandArgs(trailingOnly = TRUE)) {
  mode <- v07s_option(args, "mode", "verify")
  lock_path <- v07s_option(args, "lock", v07s_default_lock())
  if (mode == "selftest") {
    return(v07s_selftest(lock_path))
  }
  if (mode != "verify") {
    v07s_abort("mode must be verify or selftest")
  }
  valid <- v07s_validate_spaces(v07s_read_lock(lock_path))
  message(sprintf(
    "recovery-v3 seed lock: PASS (%d historical; %d possible v3 seeds)",
    nrow(valid$historical),
    nrow(valid$proposed)
  ))
  invisible(valid)
}

if (sys.nframe() == 0L) {
  v07s_main()
}
