# Shared inputs for the SE investigation: one data frame per trait and ONE pruned
# pedigree, so ASReml, hsquared, the independent R reference and MCMCglmm all see
# byte-identical inputs. Run from the repo root:
#   Rscript dev-test/se-investigation/00-prepare-data.R
src <- readRDS("dev-test/asreml_results.rds")
ped <- src$ped[, c("id", "dam", "sire")]

prune <- function(ids, ped) {
  keep <- ids
  repeat {
    rows <- match(keep, ped$id)
    par <- unique(c(ped$dam[rows], ped$sire[rows]))
    new <- unique(c(keep, par[!is.na(par)]))
    if (length(new) == length(keep)) break
    keep <- new
  }
  p <- ped[ped$id %in% keep, ]
  # parents before offspring (prepPed order is preserved by the subset)
  stopifnot(all(is.na(p$dam) | match(p$dam, p$id) < match(p$id, p$id)))
  stopifnot(all(is.na(p$sire) | match(p$sire, p$id) < match(p$id, p$id)))
  p
}

slim <- function(d, trait) {
  d <- as.data.frame(d)
  d <- d[, c(trait, "animal", "year_f", "round_f", "exp_manip", "female.age")]
  names(d)[1] <- "y"
  d$animal <- as.character(d$animal)
  droplevels(d)
}

cs <- slim(src$dat_cs, "clutch_size")
ld <- slim(src$dat_ld, "laydate")
ped_cs <- prune(unique(cs$animal), ped)
ped_ld <- prune(unique(ld$animal), ped)

saveRDS(
  list(
    clutch_size = list(data = cs, ped = ped_cs),
    laydate = list(data = ld, ped = ped_ld)
  ),
  "dev-test/se-investigation/inputs.rds"
)
cat("clutch_size:", nrow(cs), "records,", length(unique(cs$animal)), "females,",
    nrow(ped_cs), "pedigree rows\n")
cat("laydate:    ", nrow(ld), "records,", length(unique(ld$animal)), "females,",
    nrow(ped_ld), "pedigree rows\n")
