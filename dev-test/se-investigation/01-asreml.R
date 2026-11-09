# ASReml leg. Never load JuliaCall/hsquared in this process (libomp clash).
#   Rscript dev-test/se-investigation/01-asreml.R
suppressPackageStartupMessages(library(asreml))
inp <- readRDS("dev-test/se-investigation/inputs.rds")

# Ainv as an ASReml "ginv" object built from nadiv::makeAinv(). asreml's own
# ainverse() fails on this host with "Error forming A-inverse; code = 1" in
# some R processes and not others (same pedigree, same code), so it is not used.
# Format (asreml-R 4 docs): 3-column row/col/value lower triangle, row-major,
# with rowNames, inbreeding and logdet attributes.
make_ainv <- function(ped) {
  rownames(ped) <- NULL
  m <- nadiv::makeAinv(ped)
  l <- m$listAinv # already row/column/value, lower triangle, row-major
  structure(as.matrix(l), class = c("matrix", "array", "ginv"),
            rowNames = attr(l, "rowNames"), inbreeding = m$f,
            logdet = m$logDet, geneticGroups = c(0, 0))
}
ainvs <- lapply(inp, function(t) make_ainv(t$ped))

fit_one <- function(d, Ainv) {
  d$animal <- factor(d$animal, levels = attr(Ainv, "rowNames"))
  asreml.options(workspace = "2gb", maxit = 100, trace = FALSE)
  tm <- system.time(
    fit <- asreml(y ~ year_f + round_f + exp_manip + female.age,
                  random = ~ vm(animal, Ainv) + ide(animal),
                  data = d, na.action = na.method(x = "include", y = "omit"))
  )
  # push to a tight optimum so the comparison is not about convergence
  for (i in 1:5) fit <- update(fit)
  vc <- summary(fit)$varcomp
  h2 <- vpredict(fit, h2 ~ V1 / (V1 + V2 + V3))
  list(
    varcomp = data.frame(component = c("animal", "permanent", "residual"),
                         estimate = vc$component, se = vc$std.error,
                         bound = vc$bound),
    h2 = c(estimate = h2$Estimate, se = h2$SE),
    loglik = fit$loglik,
    converge = fit$converge,
    ai_inverse = fit$ai, # ASReml's inverse average-information matrix
    seconds = unname(tm["elapsed"]),
    version = as.character(packageVersion("asreml"))
  )
}

out <- lapply(names(inp), function(n) fit_one(inp[[n]]$data, ainvs[[n]]))
names(out) <- names(inp)
saveRDS(out, "dev-test/se-investigation/res-asreml.rds")
for (n in names(out)) {
  cat("\n==", n, "== loglik", out[[n]]$loglik, " converge", out[[n]]$converge, "\n")
  print(out[[n]]$varcomp, digits = 6)
  print(out[[n]]$h2, digits = 6)
  print(out[[n]]$ai_inverse)
}
