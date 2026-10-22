# Simulates a tree-ring collection with a known answer: 20 trees, 2 cores
# each, cored in one year, with sample depth falling back in time.
# Chapters load it with
#   source("R/sim-collection.R")
#   sim <- sim.collection(seed = 1)
# Lives in the book for now. A candidate for sim.rwl in dplR later.
#
# The terms follow Cook's linear aggregate model, R = A + C + dD1 + dD2 + E
# (Cook 1990, in Cook and Kairiukstis, p. 98-104; dplR.bib Cook1990model).
# Cook notes ring widths are multiplicative and that logs make the model
# linear (p. 98), so the terms are added on the log scale:
#   log(width) = log(A) + C + T + E + D1 + D2
#   A   age and size trend: the ring a stem lays down if it adds a fixed
#       basal area each year, after a juvenile ramp. Widths fall as the
#       radius grows. This is Cook's geometric-constraint argument for A
#       (p. 98), typical of open-canopy trees. No dplR method fits it by
#       name, but ModNegExp follows it closely (r = 0.999 for SIM05A at
#       seed 1). Cook's answer for closed canopies is that A is a stochastic
#       process with no predictable shape (p. 100). So half the trees
#       (compete.frac) also get a slow AR(1) wander on the log scale
#       (compete, compete.phi): a competition history no detrending curve
#       assumes. compete = 0 gives open-canopy trees only.
#   C   climate, shared by every tree
#   T   noise shared by the cores of one tree. Cook's E covers microsite
#       and measurement noise, uncorrelated within and between trees
#       (p. 102); T is split out of it so two cores of a tree agree more
#       than two trees do.
#   E   noise in each core
#   D1  endogenous disturbance: a release in one tree. Cook's D1 pulses are
#       random in space and time, so uncorrelated between trees (p. 100-102).
#   D2  exogenous disturbance: an event across the stand. Cook defines D2 by
#       its synchrony in all sampled trees (p. 102); here it hits a fraction
#       (event$frac, default half), a departure that keeps it visible as a
#       stand event without making it indistinguishable from climate. Set
#       frac = 1 for Cook's version.
# C + T + E go through an AR(1) filter, the tree's memory of last year. Cook
# treats the shocks (climate, disturbance, random) as passing through each
# tree's ARMA memory (p. 130-131). Here D1 and D2 are added after the filter
# as fixed pulse shapes, so they are not propagated as innovations.
# Variances are set from the target correlations of the filtered terms:
#   rbar.bt = var(C) / total,  rbar.wt = (var(C) + var(T)) / total
#
# Dating errors (missing or false rings) are planted last, in the measured
# series only. Everything that went in comes back in $truth.
#
# Terms checked against Cook (1990) on 2026-10-17; notes in
# workspace/references/notes/CookBook.md. Cook (1985), the dissertation, not
# yet checked.

sim.collection <- function(n.tree = 20, n.core = 2, end.year = 2025,
                           age.range = c(120, 380),
                           rbar.bt = 0.4, rbar.wt = 0.6, sd.hf = 0.25,
                           phi = 0.5, climate = NULL,
                           bai = 600, bai.sdlog = 0.4, juv = 25,
                           compete = 0.3, compete.frac = 0.5,
                           compete.phi = 0.97,
                           pith.miss = 5,
                           release = list(tree = 10, year = 1950,
                                          size = log(2), decay = 25),
                           event = list(year = 1880, frac = 0.5,
                                        size = -log(2), decay = 8),
                           errors = data.frame(series = "SIM03A",
                                               year = 1800,
                                               type = "missing"),
                           site = "SIM", digits = 2, seed = NULL) {
  if (!is.null(seed)) set.seed(seed)
  stopifnot(n.tree >= 2, n.core >= 1, n.core <= 26,
            rbar.bt >= 0, rbar.wt >= rbar.bt, rbar.wt < 1,
            abs(phi) < 1, sd.hf > 0)

  # ── who is in the collection ──
  # Tree 1 is the oldest. Ages are spaced on a square so old trees are few,
  # as in most stands.
  k <- (n.tree - seq_len(n.tree)) / (n.tree - 1)
  tree.age <- round(age.range[1] + diff(age.range) * k^2)
  pith <- end.year - tree.age + 1
  tree.id <- sprintf("%s%02d", site, seq_len(n.tree))
  ids <- expand.grid(core = seq_len(n.core), tree = seq_len(n.tree))[, 2:1]
  series <- paste0(tree.id[ids$tree], LETTERS[ids$core])
  rownames(ids) <- series
  # A core misses the pith by a few rings, so cores of one tree differ in length
  first <- pith[ids$tree] + rpois(length(series), pith.miss)
  yrs <- seq(min(pith), end.year)
  n.yr <- length(yrs)

  # ── C: climate ──
  v <- sd.hf^2 * (1 - phi^2)            # variance of C + T + E before the filter
  sd.c <- sqrt(rbar.bt * v)
  sd.t <- sqrt((rbar.wt - rbar.bt) * v)
  sd.e <- sqrt((1 - rbar.wt) * v)
  if (is.null(climate)) {
    clim <- rnorm(n.yr)
  } else {
    # a series named by year, rescaled; its shape is kept
    clim <- climate[as.character(yrs)]
    if (anyNA(clim)) {
      stop("climate must have a value for every year from ", min(yrs),
           " to ", end.year)
    }
  }
  clim <- (clim - mean(clim)) / sd(clim) * sd.c

  # ── A, T, E and the AR(1) memory ──
  burn <- 50
  ar1 <- function(x) {
    y <- stats::filter(c(rnorm(burn, sd = sd(x)), x), phi, method = "recursive")
    as.numeric(y)[-seq_len(burn)]
  }
  tree.noise <- matrix(rnorm(n.yr * n.tree, sd = sd.t), n.yr, n.tree)
  bai.tree <- bai * exp(rnorm(n.tree, sd = bai.sdlog) - bai.sdlog^2 / 2)
  age.mm <- hf <- dist <- matrix(NA_real_, n.yr, length(series),
                                 dimnames = list(yrs, series))
  pulse <- function(y0, size, decay) {
    ifelse(yrs >= y0, size * exp(-(yrs - y0) / decay), 0)
  }
  for (i in seq_along(series)) {
    tr <- ids$tree[i]
    alive <- yrs >= pith[tr]
    age <- yrs[alive] - pith[tr] + 1
    area <- cumsum(bai.tree[tr] * (1 - exp(-age / juv)))
    radius <- sqrt(area / pi)
    age.mm[alive, i] <- diff(c(0, radius))
    hf[alive, i] <- ar1(clim[alive] + tree.noise[alive, tr] +
                        rnorm(sum(alive), sd = sd.e))
    dist[alive, i] <- 0
  }

  # ── D1 and D2: disturbance ──
  hit <- integer(0)
  if (!is.null(release)) {
    if (release$year <= pith[release$tree] || release$year > end.year) {
      stop("release year ", release$year, " is outside tree ", release$tree)
    }
    cols <- ids$tree == release$tree
    dist[, cols] <- dist[, cols] + pulse(release$year, release$size,
                                         release$decay)
  }
  if (!is.null(event)) {
    standing <- which(pith < event$year)
    hit <- sort(standing[sample.int(length(standing),
                                    round(event$frac * length(standing)))])
    cols <- ids$tree %in% hit
    dist[, cols] <- dist[, cols] + pulse(event$year, event$size, event$decay)
  }

  # ── competition: A as a stochastic process ──
  # In a closed canopy, suppression and release by neighbors bend the age
  # trend into a shape no curve predicts (Cook 1990, p. 100). A slow,
  # smoothed AR(1) wander on the log scale, shared by the cores of a tree,
  # does that for
  # a fraction of the trees. Drawn last so the other draws for a given seed
  # don't change. It is part of A, so truth$age includes it.
  n.comp <- round(compete.frac * n.tree)
  comp.trees <- if (compete > 0 && n.comp > 0) {
    sort(sample.int(n.tree, n.comp))
  } else {
    integer(0)
  }
  wander <- matrix(0, n.yr, n.tree)
  for (tr in comp.trees) {
    # an AR(1) wander, then an 11-year running mean so it changes over
    # decades rather than from one year to the next
    w <- as.numeric(stats::filter(rnorm(n.yr + 2 * burn), compete.phi,
                                  method = "recursive"))
    w <- as.numeric(stats::filter(w, rep(1 / 11, 11), sides = 2))
    w <- w[burn + seq_len(n.yr)]
    wander[, tr] <- (w - mean(w)) / sd(w) * compete
  }
  age.mm <- age.mm * exp(wander[, ids$tree])

  # ── widths, cut to what each core reaches ──
  width <- age.mm * exp(hf + dist)
  for (i in seq_along(series)) {
    width[yrs < first[i], i] <- NA
    age.mm[yrs < first[i], i] <- NA
    hf[yrs < first[i], i] <- NA
    dist[yrs < first[i], i] <- NA
  }
  width <- round(width, digits)
  if (any(width == 0, na.rm = TRUE)) {
    warning(sum(width == 0, na.rm = TRUE), " rings round to zero at ",
            digits, " decimals and will read as absent rings")
  }
  to.rwl <- function(m) {
    out <- as.data.frame(m)
    rownames(out) <- yrs
    class(out) <- c("rwl", "data.frame")
    out
  }
  rwl.true <- to.rwl(width)

  # ── dating errors ──
  # Counted in from the bark. A missing ring makes every ring before it one
  # year too late; a false ring (one ring split in two) makes them one year
  # too early. Each error is given by its true calendar year, and errors in
  # one series go in oldest first so a later one is not moved by an earlier one.
  measured <- width
  if (!is.null(errors) && nrow(errors) > 0) {
    errors <- errors[order(errors$series, errors$year), , drop = FALSE]
    pad <- 5
    measured <- rbind(matrix(NA_real_, pad, ncol(width),
                             dimnames = list(min(yrs) - pad:1, series)),
                      measured)
    for (j in seq_len(nrow(errors))) {
      s <- errors$series[j]
      y <- errors$year[j]
      if (!s %in% series) stop("no series named ", s)
      x <- measured[, s]
      ok <- !is.na(x)
      yy <- as.numeric(names(x))[ok]
      if (y <= min(yy) || y >= end.year) {
        stop(s, " runs ", min(yy), " to ", end.year,
             ", so it can't take an error at ", y)
      }
      v.in <- x[ok]
      at <- which(yy == y)
      v.out <- switch(errors$type[j],
        missing = v.in[-at],
        false = append(v.in[-at], v.in[at] * c(0.4, 0.6), after = at - 1),
        stop("error type must be \"missing\" or \"false\""))
      x[] <- NA
      x[seq(length(x) - length(v.out) + 1, length(x))] <- v.out
      measured[, s] <- x
    }
    measured <- measured[rowSums(!is.na(measured)) > 0, , drop = FALSE]
    yrs.m <- as.numeric(rownames(measured))
  } else {
    yrs.m <- yrs
  }
  rwl <- as.data.frame(measured)
  rownames(rwl) <- yrs.m
  class(rwl) <- c("rwl", "data.frame")

  list(rwl = rwl,
       ids = ids,
       truth = list(
         rwl = rwl.true,
         climate = data.frame(year = yrs, climate = clim),
         age = to.rwl(age.mm),
         memory.noise = to.rwl(hf),
         disturbance = to.rwl(dist),
         release = release,
         event = c(event, list(trees = hit)),
         errors = errors,
         pith = data.frame(tree = tree.id, pith = pith, row.names = NULL),
         competition = tree.id[comp.trees],
         params = list(n.tree = n.tree, n.core = n.core, end.year = end.year,
                       rbar.bt = rbar.bt, rbar.wt = rbar.wt, sd.hf = sd.hf,
                       phi = phi, bai = bai, juv = juv, compete = compete,
                       compete.frac = compete.frac,
                       compete.phi = compete.phi, seed = seed)))
}
