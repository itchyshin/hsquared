# Cross-engine parity (parity map cell 39, HSquared.jl#8): the R hs_data()
# container and data_status() against the HSquared.jl HSData / id_map() /
# data_status() values for the SAME input. The input exercises every component
# and every diagnostic: a duplicated phenotype ID, an ungenotyped phenotype, a
# genotype-only ID, a pedigree-only ID, a missing known parent, a missing
# genotype value, an expression feature without annotation, and an environment
# key with and without metadata.
#
# Two intentional representation differences are normalised, not hidden:
# `component_type` is the host-language class name ("data.frame" in R,
# "table" in Julia), and numeric position values are compared as numbers
# (R "5", Julia "5.0").

hs_hsdata_parity_input <- function() {
  list(
    ped = data.frame(
      id = c("a", "b", "c", "d", "e"),
      sire = c(NA, NA, "a", "a", "c"),
      dam = c(NA, NA, "b", "x", "d")
    ),
    dat = data.frame(
      id = c("a", "c", "d", "e", "e"),
      y = c(1, 2, 3, 4, 5),
      env = c("E1", "E2", "E1", "E3", "E3")
    ),
    geno = data.frame(
      id = c("a", "c", "z"),
      m1 = c(0, 2, NA),
      m2 = c(1, 1, 2),
      m3 = c(2, 0, 1)
    ),
    mk = data.frame(
      marker = c("m1", "m2", "m3"),
      chr = c("1", "1", "2"),
      pos = c(10, 20, 5)
    ),
    expr = data.frame(id = c("a", "d"), g1 = c(0.1, 0.2), g2 = c(0.3, 0.4)),
    ann = data.frame(feature = c("g1", "g3"), type = c("x", "y")),
    envd = data.frame(env = c("E1", "E4"), temp = c(1, 2))
  )
}

hs_hsdata_julia_status_pairs <- function(field) {
  JuliaCall::julia_eval(paste0(
    "hsq_status.",
    field,
    " === nothing ? String[] : ",
    "[string(r.metric, \"\\t\", getproperty(r, propertynames(r)[2])) ",
    "for r in hsq_status.",
    field,
    "]"
  ))
}

hs_hsdata_r_status_pairs <- function(tbl) {
  if (is.null(tbl)) {
    return(character(0))
  }
  paste(tbl$metric, tbl[[2L]], sep = "\t")
}

test_that("hs_data() container and data_status() match the Julia HSData value [live]", {
  hs_skip_live_julia()
  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required for live HSData parity."
  )

  x <- hs_hsdata_parity_input()
  bundle <- hs_data(
    phenotypes = x$dat,
    pedigree = x$ped,
    genotypes = x$geno,
    markers = x$mk,
    expression = x$expr,
    annotation = x$ann,
    annotation_id = "feature",
    environment = x$envd,
    environment_id = "env"
  )
  st <- data_status(bundle)

  hsquared:::hs_julia_setup(Sys.getenv("HSQUARED_JULIA_PROJECT"))
  JuliaCall::julia_assign("hsq_p", bundle$phenotypes)
  JuliaCall::julia_assign("hsq_pd", bundle$pedigree)
  JuliaCall::julia_assign("hsq_g", bundle$genotypes)
  JuliaCall::julia_assign("hsq_mk", bundle$markers)
  JuliaCall::julia_assign("hsq_ex", bundle$expression)
  JuliaCall::julia_assign("hsq_an", bundle$annotation)
  JuliaCall::julia_assign("hsq_ev", bundle$environment)
  JuliaCall::julia_command(paste(
    "hsq_hd = HSquared.HSData(hsq_p; id = :id,",
    "pedigree = hsq_pd, pedigree_id = :id,",
    "genotypes = hsq_g, genotype_id = :id,",
    "markers = hsq_mk,",
    "expression = hsq_ex, expression_id = :id,",
    "annotation = hsq_an, annotation_id = :feature,",
    "environment = hsq_ev, environment_id = :env);",
    "hsq_status = HSquared.data_status(hsq_hd);"
  ))

  # id_map: all nine fields, order included
  for (field in names(bundle$id_map)) {
    jl <- JuliaCall::julia_eval(paste0(
      "collect(String, string.(HSquared.id_map(hsq_hd).",
      field,
      "))"
    ))
    expect_identical(
      as.character(bundle$id_map[[field]]),
      jl,
      info = paste("id_map field", field)
    )
  }

  # component presence and order
  expect_identical(
    st$components,
    JuliaCall::julia_eval("string.(hsq_status.components)")
  )

  # every status table, row by row (metric + value), same row order
  for (field in c(
    "id_overlap",
    "pedigree_status",
    "marker_status",
    "genotype_status",
    "expression_status",
    "annotation_status",
    "environment_status"
  )) {
    r <- hs_hsdata_r_status_pairs(st[[field]])
    jl <- hs_hsdata_julia_status_pairs(field)
    drop_type <- function(v) v[!grepl("^component_type\t", v)]
    num_norm <- function(v) {
      pos <- grepl("^position_(min|max)\t", v)
      v[pos] <- vapply(
        strsplit(v[pos], "\t", fixed = TRUE),
        function(p) paste(p[[1L]], format(as.numeric(p[[2L]])), sep = "\t"),
        character(1)
      )
      v
    }
    expect_identical(
      num_norm(drop_type(r)),
      num_norm(drop_type(jl)),
      info = paste("data_status field", field)
    )
  }
})
