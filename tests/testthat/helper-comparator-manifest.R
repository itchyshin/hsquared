hs_comparator_manifest_path <- function() {
  normalizePath(
    testthat::test_path("..", "fixtures", "comparator_targets.toml"),
    mustWork = TRUE
  )
}

hs_comparator_fixture_shas_path <- function() {
  normalizePath(
    testthat::test_path("..", "fixtures", "comparator_fixture_shas.csv"),
    mustWork = TRUE
  )
}

# Minimal TOML reader for the comparator manifest schema (schema_version,
# claim_boundary, and [[target]] tables with string/int/bool keys and string
# arrays). Not a general TOML parser.
hs_read_comparator_manifest <- function(path = hs_comparator_manifest_path()) {
  lines <- readLines(path, warn = FALSE)
  lines <- sub("^[[:space:]]*#.*$", "", lines)
  lines <- trimws(lines)
  lines <- lines[nzchar(lines)]

  top <- list()
  targets <- list()
  current <- NULL
  array_key <- NULL
  array_vals <- character()

  flush_array <- function() {
    if (is.null(array_key) || is.null(current)) {
      return()
    }
    current[[array_key]] <<- array_vals
    targets[[length(targets)]] <<- current
    array_key <<- NULL
    array_vals <<- character()
  }

  for (line in lines) {
    if (line == "[[target]]") {
      flush_array()
      current <- list()
      targets[[length(targets) + 1L]] <- current
      next
    }

    if (grepl("^\\[", line)) {
      next
    }

    if (grepl("= *\\[$", line)) {
      flush_array()
      array_key <- sub(" *= *\\[$", "", line)
      next
    }

    if (!is.null(array_key) && line == "]") {
      flush_array()
      next
    }

    if (!is.null(array_key)) {
      val <- trimws(line)
      val <- sub(",$", "", val)
      val <- gsub('^"|"$', "", val)
      array_vals <- c(array_vals, val)
      next
    }

    if (!grepl("=", line)) {
      next
    }

    key <- sub(" *=.*", "", line)
    val <- sub("^[^=]*= *", "", line)
    val <- gsub('^"|"$', "", val)
    val <- sub(",$", "", val)

    parsed <- if (val %in% c("true", "false")) {
      as.logical(val)
    } else if (grepl("^[0-9]+$", val)) {
      as.integer(val)
    } else {
      val
    }

    if (is.null(current)) {
      top[[key]] <- parsed
    } else {
      current[[key]] <- parsed
      targets[[length(targets)]] <- current
    }
  }

  flush_array()
  top$target <- targets
  top
}

hs_sha256_file <- function(path) {
  out <- system2("shasum", c("-a", "256", path), stdout = TRUE)
  sub(" .*", "", out[[1]])
}
