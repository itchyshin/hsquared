# Independent R reference (no ASReml, no Julia): REML log-likelihood of the
# animal + permanent-environment model through Henderson's sparse MME, and three
# information matrices at a given theta = (s2_a, s2_pe, s2_e):
#   AI  = average information      1/2 y'P Vi P Vj P y          (what ASReml inverts)
#   OBS = observed information    -d2 logL / d theta2 (FD)      (what hsquared inverts)
#   EXP = expected information     1/2 tr(P Vi P Vj) = 2 AI - OBS (linear V identity)
#   Rscript dev-test/se-investigation/02-reference.R
suppressPackageStartupMessages(library(Matrix))
inp <- readRDS("dev-test/se-investigation/inputs.rds")
asr <- readRDS("dev-test/se-investigation/res-asreml.rds")

build <- function(d, ped) {
  rownames(ped) <- NULL
  m <- nadiv::makeAinv(ped)
  Ainv <- m$Ainv
  ids <- attr(m$listAinv, "rowNames")
  X <- model.matrix(~ year_f + round_f + exp_manip + female.age, d)
  q <- qr(X)
  X <- X[, q$pivot[seq_len(q$rank)], drop = FALSE] # full column rank
  n <- nrow(d)
  Za <- sparseMatrix(i = seq_len(n), j = match(d$animal, ids), x = 1,
                     dims = c(n, length(ids)))
  fem <- unique(d$animal)
  Zp <- sparseMatrix(i = seq_len(n), j = match(d$animal, fem), x = 1,
                     dims = c(n, length(fem)))
  W <- cbind(Matrix(X, sparse = TRUE), Za, Zp)
  p <- ncol(X); qa <- ncol(Za); qp <- ncol(Zp)
  list(y = d$y, X = X, Za = Za, Zp = Zp, W = W, WtW = crossprod(W),
       Wty = crossprod(W, d$y), yty = sum(d$y^2), Ainv = Ainv,
       logdetAinv = as.numeric(determinant(Ainv)$modulus),
       n = n, p = p, qa = qa, qp = qp,
       ia = p + seq_len(qa), ip = p + qa + seq_len(qp))
}

# Everything at one theta from one sparse Cholesky.
at_theta <- function(M, th, chol0 = NULL) {
  sa <- th[1]; sp <- th[2]; se <- th[3]
  Ginv <- bdiag(Matrix(0, M$p, M$p, sparse = TRUE), M$Ainv / sa,
                Diagonal(M$qp, 1 / sp))
  C <- forceSymmetric(M$WtW / se + Ginv)
  ch <- if (is.null(chol0)) Cholesky(C, LDL = FALSE, perm = TRUE) else update(chol0, C)
  rhs <- M$Wty / se
  b <- solve(ch, rhs)
  logdetC <- as.numeric(determinant(ch, sqrt = FALSE)$modulus)
  yPy <- M$yty / se - sum(b * rhs)
  logdetR <- M$n * log(se)
  logdetG <- M$qa * log(sa) - M$logdetAinv + M$qp * log(sp)
  ll <- -0.5 * (logdetR + logdetG + logdetC + yPy) # REML, constant dropped
  list(ll = ll, ch = ch, b = as.numeric(b), C = C)
}

ai_matrix <- function(M, th, r) {
  sa <- th[1]; sp <- th[2]; se <- th[3]
  b <- r$b
  e <- M$y - as.numeric(M$W %*% b)
  Q <- cbind(as.numeric(M$Za %*% b[M$ia]) / sa,
             as.numeric(M$Zp %*% b[M$ip]) / sp,
             e / se)
  # P Q = R^-1 Q - R^-1 W C^-1 W' R^-1 Q
  WtQ <- crossprod(M$W, Q) / se
  PQ <- Q / se - as.matrix(M$W %*% solve(r$ch, WtQ)) / se
  0.5 * crossprod(Q, PQ)
}

fd_hessian <- function(f, th, rel) {
  k <- length(th); h <- rel * th; H <- matrix(0, k, k); f0 <- f(th)
  for (i in 1:k) for (j in i:k) {
    ei <- replace(numeric(k), i, h[i]); ej <- replace(numeric(k), j, h[j])
    H[i, j] <- if (i == j) {
      (-f(th + 2 * ei) + 16 * f(th + ei) - 30 * f0 + 16 * f(th - ei) - f(th - 2 * ei)) /
        (12 * h[i]^2)
    } else {
      (f(th + ei + ej) - f(th + ei - ej) - f(th - ei + ej) + f(th - ei - ej)) /
        (4 * h[i] * h[j])
    }
    H[j, i] <- H[i, j]
  }
  H
}

fd_grad <- function(f, th, rel = 1e-4) {
  sapply(seq_along(th), function(i) {
    h <- rel * th[i]; e <- replace(numeric(length(th)), i, h)
    (f(th + e) - f(th - e)) / (2 * h)
  })
}

# Delta-method SEs from a covariance of theta
summarise_cov <- function(V, th) {
  tot <- sum(th)
  g <- c(tot - th[1], -th[1], -th[1]) / tot^2
  c(se_animal = sqrt(V[1, 1]), se_permanent = sqrt(V[2, 2]),
    se_residual = sqrt(V[3, 3]), se_h2 = sqrt(drop(t(g) %*% V %*% g)))
}

out <- list()
for (tr in names(inp)) {
  M <- build(inp[[tr]]$data, inp[[tr]]$ped)
  th <- asr[[tr]]$varcomp$estimate
  r0 <- at_theta(M, th)
  f <- function(t) at_theta(M, t, r0$ch)$ll

  # 1. polish the optimum with AI-Newton steps (score by FD), so every matrix is
  #    evaluated at the same, tight REML optimum.
  for (it in 1:6) {
    r <- at_theta(M, th, r0$ch)
    AI <- ai_matrix(M, th, r)
    g <- fd_grad(f, th)
    step <- solve(AI, g)
    th <- th + step
    if (max(abs(step / th)) < 1e-10) break
  }
  r <- at_theta(M, th, r0$ch)
  AI <- ai_matrix(M, th, r)
  grad <- fd_grad(f, th)
  OBS <- lapply(c(1e-2, 3e-3, 1e-3), function(rel) -fd_hessian(f, th, rel))
  names(OBS) <- c("rel1e-2", "rel3e-3", "rel1e-3")
  O <- OBS[["rel3e-3"]]
  EXP <- 2 * AI - O
  out[[tr]] <- list(
    theta = setNames(th, c("animal", "permanent", "residual")),
    theta_asreml = asr[[tr]]$varcomp$estimate,
    grad = grad, AI = AI, OBS = OBS, EXP = EXP,
    se_AI = summarise_cov(solve(AI), th),
    se_OBS = sapply(OBS, function(o) summarise_cov(solve(o), th)),
    se_EXP = summarise_cov(solve(EXP), th),
    se_asreml = c(asr[[tr]]$varcomp$se, asr[[tr]]$h2[["se"]])
  )
  cat("\n=====", tr, "=====\n")
  cat("theta (polished):", format(th, digits = 8), "\n")
  cat("theta (ASReml):  ", format(asr[[tr]]$varcomp$estimate, digits = 8), "\n")
  cat("score at polished theta:", format(grad, digits = 3), "\n")
  tab <- rbind(ASReml = out[[tr]]$se_asreml, AI_ref = out[[tr]]$se_AI,
               t(out[[tr]]$se_OBS), EXP_ref = out[[tr]]$se_EXP)
  print(signif(tab, 6))
}
saveRDS(out, "dev-test/se-investigation/res-reference.rds")
