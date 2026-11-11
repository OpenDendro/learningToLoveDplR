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
#       bai.trend > 0 lets each tree's basal area increment change with age:
#       a tree's yearly area is multiplied by exp(beta * age / 100), with
#       beta drawn for each tree from N(0, bai.trend). Negative beta is a
#       tree whose BAI falls off with age, so its rings thin faster than the
#       geometry alone; positive beta keeps BAI climbing, so its rings
#       flatten or widen. Every tree then has its own shape of age trend,
#       and no one curve family fits them all, like the misfits seen under a
#       scope. bai.trend = 0 (the default) gives the one shape, scaled.
#       bai.age ties a tree's growth rate to its age: it is the correlation
#       between the log of the rate and the tree's age, from -1 to 1. A
#       negative value makes old trees slow growers and young ones fast,
#       Briffa and Melvin's modern-sample bias (2011, p. 122-123). The
#       spread of rates stays at bai.sdlog. bai.age = 0 (the default) keeps
#       the rate independent of age.
#   C   climate, shared by every tree. climate.phi (default 0.3) gives it
#       AR(1) persistence of its own, separate from the tree's memory (phi).
#       The shocks keep their share of the variance, so the prewhitened
#       rbar targets hold, and everything is scaled so that the filtered
#       C + T + E still has standard deviation sd.hf (see the C block). climate.phi = 0 gives white climate,
#       the collection the book used before 2026-10-23. A climate series
#       passed in is used as it is, and climate.phi is ignored.
#       sens.sdlog > 0 gives each tree its own sensitivity to C, a
#       multiplier drawn on the log scale so that its mean square is 1:
#       trees differ in how hard the shared climate hits them, and the
#       average climate variance across trees stays where rbar.bt puts it.
#       Sensitive trees swing more and track the climate better; complacent
#       ones swing less. Cook's model has one C felt the same way by every
#       tree, and sens.sdlog = 0 (the default) keeps that. Trees that
#       differ in sensitivity agree with each other less, so with it on
#       the between-tree correlation falls under rbar.bt (on the true fast
#       part, from about 0.50 to 0.44 at sens.sdlog = 0.3 and 0.32 at 0.6,
#       averaged over 200 collections, 2026-11-10).
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
# dead (default NULL) puts dead trees in the collection, the snags and
# remnant wood that a collection can mix with living trees. A share of the
# trees (dead$frac) died before end.year, each in a year drawn uniformly
# from the dead$span years before it. A dead tree keeps its age, so its pith
# moves back with its outer ring and the collection reaches further back.
# Series then end in different years, so the end of a series no longer
# falls in the same decade for every tree. Turning it on changes the years
# the collection covers, and so every draw after it.
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
                           phi = 0.5, climate = NULL, climate.phi = 0.3,
                           sens.sdlog = 0,
                           bai = 600, bai.sdlog = 0.4, juv = 25,
                           bai.trend = 0, bai.age = 0,
                           compete = 0.3, compete.frac = 0.5,
                           compete.phi = 0.97,
                           pith.miss = 5, dead = NULL,
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
            abs(phi) < 1, abs(climate.phi) < 1, sd.hf > 0, sens.sdlog >= 0,
            bai.trend >= 0, abs(bai.age) <= 1)

  # ── who is in the collection ──
  # Tree 1 is the oldest. Ages are spaced on a square so old trees are few,
  # as in most collections.
  k <- (n.tree - seq_len(n.tree)) / (n.tree - 1)
  tree.age <- round(age.range[1] + diff(age.range) * k^2)
  tree.id <- sprintf("%s%02d", site, seq_len(n.tree))
  # the outer ring: end.year for a living tree, earlier for a dead one
  outer <- rep(end.year, n.tree)
  if (!is.null(dead)) {
    stopifnot(dead$frac >= 0, dead$frac <= 1, dead$span >= 1)
    # the release tree and trees with planted dating errors stay alive,
    # because their years are given for a tree cored in end.year
    keep <- integer(0)
    if (!is.null(release)) keep <- release$tree
    if (!is.null(errors) && nrow(errors) > 0) {
      keep <- c(keep, match(substr(errors$series, 1, nchar(errors$series) - 1),
                            tree.id))
    }
    can.die <- setdiff(seq_len(n.tree), keep)
    n.dead <- min(round(dead$frac * n.tree), length(can.die))
    if (n.dead > 0) {
      who <- sort(can.die[sample.int(length(can.die), n.dead)])
      outer[who] <- end.year - sample.int(dead$span, n.dead, replace = TRUE)
    }
  }
  pith <- outer - tree.age + 1
  ids <- expand.grid(core = seq_len(n.core), tree = seq_len(n.tree))[, 2:1]
  series <- paste0(tree.id[ids$tree], LETTERS[ids$core])
  rownames(ids) <- series
  # A core misses the pith by a few rings, so cores of one tree differ in length
  first <- pith[ids$tree] + rpois(length(series), pith.miss)
  yrs <- seq(min(pith), end.year)
  n.yr <- length(yrs)

  # ── C: climate ──
  # Variance of C + T + E before the tree's memory filter. White input of
  # variance v comes out of an AR(1) filter with variance v / (1 - phi^2),
  # so this gives the filtered series a standard deviation of sd.hf. It is
  # the scaling Bunn et al. (2013, Appendix A) use to keep an AR(1) series'
  # own variance fixed whatever phi is. A red climate (climate.phi) goes
  # through two filters, its own and the tree's, and comes out with g times
  # the variance a white one would. So all three parts are shrunk by one
  # common factor that brings the filtered total back to sd.hf; their
  # proportions, and so the prewhitened rbar targets, don't change.
  v <- sd.hf^2 * (1 - phi^2)
  if (is.null(climate) && climate.phi != 0) {
    g <- (1 + phi * climate.phi) /
      ((1 - climate.phi^2) * (1 - phi * climate.phi))
    v <- v / (rbar.bt * g + 1 - rbar.bt)
  }
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
  # red climate: the same shocks, carried forward from year to year
  if (is.null(climate) && climate.phi != 0) {
    clim <- as.numeric(stats::filter(clim, climate.phi, method = "recursive"))
  }

  # ── A, T, E and the AR(1) memory ──
  burn <- 50
  ar1 <- function(x) {
    y <- stats::filter(c(rnorm(burn, sd = sd(x)), x), phi, method = "recursive")
    as.numeric(y)[-seq_len(burn)]
  }
  tree.noise <- matrix(rnorm(n.yr * n.tree, sd = sd.t), n.yr, n.tree)
  # each tree's growth rate. With bai.age set, part of the log rate comes
  # from the tree's age in standard units and the rest from the same draw,
  # so the spread stays at bai.sdlog and no other draw moves.
  z.rate <- rnorm(n.tree)
  z.age <- (tree.age - mean(tree.age)) / sd(tree.age)
  bai.tree <- bai * exp(bai.sdlog * (bai.age * z.age +
                                     sqrt(1 - bai.age^2) * z.rate) -
                        bai.sdlog^2 / 2)
  # each tree's sensitivity to the climate. Drawn only when asked for, so
  # the default collection for a given seed is the same as before the option
  # existed. exp(z * s - s^2) has a mean square of 1.
  sens.tree <- if (sens.sdlog > 0) {
    exp(rnorm(n.tree, sd = sens.sdlog) - sens.sdlog^2)
  } else {
    rep(1, n.tree)
  }
  age.mm <- hf <- dist <- matrix(NA_real_, n.yr, length(series),
                                 dimnames = list(yrs, series))
  pulse <- function(y0, size, decay) {
    ifelse(yrs >= y0, size * exp(-(yrs - y0) / decay), 0)
  }
  # pulses are added to whole columns; years after a dead tree's outer ring
  # stay NA because dist is NA there
  for (i in seq_along(series)) {
    tr <- ids$tree[i]
    alive <- yrs >= pith[tr] & yrs <= outer[tr]
    hf[alive, i] <- ar1(sens.tree[tr] * clim[alive] + tree.noise[alive, tr] +
                        rnorm(sum(alive), sd = sd.e))
    dist[alive, i] <- 0
  }

  # ── D1 and D2: disturbance ──
  hit <- integer(0)
  if (!is.null(release)) {
    if (release$year <= pith[release$tree] ||
        release$year > outer[release$tree]) {
      stop("release year ", release$year, " is outside tree ", release$tree)
    }
    cols <- ids$tree == release$tree
    dist[, cols] <- dist[, cols] + pulse(release$year, release$size,
                                         release$decay)
  }
  if (!is.null(event)) {
    standing <- which(pith < event$year & outer >= event$year)
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

  # ── A: geometry, then competition ──
  # Each tree's BAI trend is drawn after everything else, and only when
  # asked for, so the default collection for a given seed is unchanged.
  bai.beta <- if (bai.trend > 0) rnorm(n.tree, sd = bai.trend) else
    rep(0, n.tree)
  for (i in seq_along(series)) {
    tr <- ids$tree[i]
    alive <- yrs >= pith[tr] & yrs <= outer[tr]
    age <- yrs[alive] - pith[tr] + 1
    area <- cumsum(bai.tree[tr] * (1 - exp(-age / juv)) *
                   exp(bai.beta[tr] * age / 100))
    radius <- sqrt(area / pi)
    age.mm[alive, i] <- diff(c(0, radius))
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
      if (y <= min(yy) || y >= max(yy)) {
        stop(s, " runs ", min(yy), " to ", max(yy),
             ", so it can't take an error at ", y)
      }
      v.in <- x[ok]
      at <- which(yy == y)
      v.out <- switch(errors$type[j],
        missing = v.in[-at],
        false = append(v.in[-at], v.in[at] * c(0.4, 0.6), after = at - 1),
        stop("error type must be \"missing\" or \"false\""))
      # the outer ring stays in its year; the rings inside it move
      last <- max(which(ok))
      x[] <- NA
      x[seq(last - length(v.out) + 1, last)] <- v.out
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
         pith = data.frame(tree = tree.id, pith = pith, outer = outer,
                           row.names = NULL),
         competition = tree.id[comp.trees],
         sensitivity = data.frame(tree = tree.id, sensitivity = sens.tree,
                                  row.names = NULL),
         growth = data.frame(tree = tree.id, bai = bai.tree,
                             bai.trend = bai.beta, row.names = NULL),
         params = list(n.tree = n.tree, n.core = n.core, end.year = end.year,
                       rbar.bt = rbar.bt, rbar.wt = rbar.wt, sd.hf = sd.hf,
                       phi = phi, climate.phi = climate.phi,
                       sens.sdlog = sens.sdlog, bai = bai, juv = juv,
                       bai.trend = bai.trend, bai.age = bai.age,
                       dead = dead,
                       compete = compete,
                       compete.frac = compete.frac,
                       compete.phi = compete.phi, seed = seed)))
}
