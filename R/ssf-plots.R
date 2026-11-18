# Pictures of what ssf does from one iteration to the next.
# Each function takes the list that ssf returns with return.info = TRUE:
#   info <- ssf(rwl, return.info = TRUE)
# Chapters load them with
#   source("R/ssf-plots.R")
# Lives in the book for now. Candidates for plot methods in dplR later.
#
# How ssf numbers its iterations (dplR 1.8.1 dev). Iteration 0 is the
# ordinary chronology: curves fit to the measurements, indices, a mean.
# Iterations 1 to k each fit curves to the signal-free measurements made
# from the chronology before. The matrices and arrays in info have one
# column or slice per iteration, named "0" to "k". MAD_Vec has k - 1
# values: the first compares iteration 2 with iteration 1, the last
# compares k with k - 1, and ssf stops when one falls below mad.threshold.
#
# Needs ggplot2 and cowplot, and dplR for caps.

library(ggplot2)
library(cowplot)

# axis and legend breaks for iteration numbers: a few round whole numbers,
# so thirteen iterations don't crowd the axis
whole.breaks <- function(lims) {
  b <- pretty(lims)
  b[b == round(b)]
}

# ── ssf.long ──
# The chronology at every iteration as one long data frame, one row per
# year and iteration. ggplot wants its data this way. The other functions
# here start from it.
ssf.long <- function(info) {
  crn.mat <- info[["sfCrn_Mat"]]
  yrs <- as.numeric(rownames(crn.mat))
  iterations <- as.numeric(colnames(crn.mat))
  depth <- info[["ssfCrn"]][["samp.depth"]]
  out <- data.frame(year = rep(yrs, times = length(iterations)),
                    iteration = rep(iterations, each = length(yrs)),
                    crn = as.vector(crn.mat),
                    samp.depth = rep(depth, times = length(iterations)))
  out
}

# ── ssf.truth.plot ──
# For a simulated collection, where the climate signal is known. truth is
# the chronology a perfect method would give, in index units, as a vector
# named by year. With sim.collection the shared signal on the log scale is
# the climate filtered by the trees' AR(1) memory, so
#   clim <- sim$truth$climate
#   truth <- exp(stats::filter(clim$climate, phi, method = "recursive"))
#   names(truth) <- clim$year
# where phi is sim$truth$params$phi.
# Chronology and truth are each divided by their own mean over the years
# they share, so the comparison is about shape and a difference in level
# doesn't count.
# Three panels:
#   a  the smoothed truth with the smoothed chronology at the first and last
#      iteration, to see where the loop moved the chronology
#   b  the error of each iteration against the truth, year to year and after
#      an nyrs smoothing spline: is the loop getting closer?
#   c  the smoothed error for every year and iteration: where is it getting
#      closer, and where does it overshoot?
ssf.truth.plot <- function(info, truth, nyrs = 31) {
  crn.mat <- info[["sfCrn_Mat"]]
  yrs <- rownames(crn.mat)
  common <- intersect(yrs, names(truth))
  if (length(common) < nyrs) {
    stop("the chronology and truth share only ", length(common), " years")
  }
  crn.mat <- crn.mat[common, , drop = FALSE]
  truth <- truth[common]
  iterations <- as.numeric(colnames(crn.mat))
  k <- max(iterations)

  # both on a mean of 1 over the shared years
  truth <- truth / mean(truth)
  for (j in seq_along(iterations)) {
    crn.mat[, j] <- crn.mat[, j] / mean(crn.mat[, j])
  }

  # smooth each one with the same spline
  truth.sm <- caps(truth, nyrs = nyrs)
  crn.sm <- crn.mat
  for (j in seq_along(iterations)) {
    crn.sm[, j] <- caps(crn.mat[, j], nyrs = nyrs)
  }

  # root mean square error of each iteration, year to year and smoothed
  rmse <- data.frame(iteration = rep(iterations, 2),
                     scale = rep(c("Year to year",
                                   paste0("Smoothed (", nyrs, " yr)")),
                                 each = length(iterations)),
                     rmse = NA)
  for (j in seq_along(iterations)) {
    rmse$rmse[j] <- sqrt(mean((crn.mat[, j] - truth)^2))
    rmse$rmse[j + length(iterations)] <- sqrt(mean((crn.sm[, j] - truth.sm)^2))
  }

  # a: truth with the first and last chronology, smoothed
  lines.df <- data.frame(
    year = rep(as.numeric(common), 3),
    value = c(truth.sm, crn.sm[, 1], crn.sm[, ncol(crn.sm)]),
    what = rep(c("Truth", "Iteration 0", paste("Iteration", k)),
               each = length(common)))
  lines.df$what <- factor(lines.df$what,
                          levels = c("Truth", "Iteration 0",
                                     paste("Iteration", k)))
  p.a <- ggplot(lines.df, aes(x = year, y = value, color = what)) +
    geom_hline(yintercept = 1, linetype = "dashed", color = "grey60") +
    geom_line(linewidth = 0.8) +
    scale_color_manual(values = c("black", "#E69F00", "#0072B2")) +
    labs(x = "Year", y = paste0("Index (", nyrs, "-yr spline)"),
         color = NULL) +
    theme_cowplot() +
    theme(legend.position = "top")

  # b: error by iteration
  p.b <- ggplot(rmse, aes(x = iteration, y = rmse)) +
    geom_line(color = "grey40") +
    geom_point(aes(color = iteration), size = 2.5) +
    facet_wrap(~ scale, ncol = 1, scales = "free_y") +
    scale_color_viridis_c(end = 0.9, guide = "none") +
    scale_x_continuous(breaks = whole.breaks) +
    labs(x = "Iteration", y = "RMSE against truth") +
    theme_cowplot() +
    theme(strip.background = element_blank())

  # c: smoothed error for each year and iteration
  err <- data.frame(year = rep(as.numeric(common), times = length(iterations)),
                    iteration = rep(iterations, each = length(common)),
                    error = as.vector(crn.sm - truth.sm))
  lim <- max(abs(err$error))
  p.c <- ggplot(err, aes(x = year, y = iteration, fill = error)) +
    geom_raster() +
    scale_fill_distiller(palette = "RdBu", limits = c(-lim, lim),
                         direction = 1) +
    scale_y_continuous(breaks = whole.breaks, expand = c(0, 0)) +
    scale_x_continuous(expand = c(0, 0)) +
    labs(x = "Year", y = "Iteration",
         fill = "Chronology\nminus truth\n(smoothed)") +
    theme_cowplot()

  top <- plot_grid(p.a, p.b, ncol = 2, rel_widths = c(2, 1),
                   labels = c("a", "b"))
  plot_grid(top, p.c, ncol = 1, rel_heights = c(1.2, 1), labels = c("", "c"))
}

# ── ssf.change.plot ──
# How much each year moved, iteration by iteration, with sample depth
# underneath on the same years. from = "first" colors each cell by the
# chronology minus the one at iteration 0, so the last row is the total
# change. from = "previous" colors it by the chronology minus the one just
# before it, so the rows fade toward zero as the loop settles. nyrs smooths
# the differences first; NULL leaves them as they are.
ssf.change.plot <- function(info, from = c("first", "previous"),
                            nyrs = NULL) {
  from <- match.arg(from)
  crn.mat <- info[["sfCrn_Mat"]]
  yrs <- as.numeric(rownames(crn.mat))
  iterations <- as.numeric(colnames(crn.mat))
  diff.mat <- crn.mat
  for (j in seq_along(iterations)) {
    if (from == "first") {
      diff.mat[, j] <- crn.mat[, j] - crn.mat[, 1]
    } else if (j == 1) {
      diff.mat[, j] <- NA # iteration 0 has nothing before it
    } else {
      diff.mat[, j] <- crn.mat[, j] - crn.mat[, j - 1]
    }
    if (!is.null(nyrs) && !all(is.na(diff.mat[, j]))) {
      diff.mat[, j] <- caps(diff.mat[, j], nyrs = nyrs)
    }
  }
  # drop iteration 0, which is all zero (from first) or empty (from previous)
  diff.mat <- diff.mat[, -1, drop = FALSE]
  shown <- iterations[-1]

  chg <- data.frame(year = rep(yrs, times = length(shown)),
                    iteration = rep(shown, each = length(yrs)),
                    change = as.vector(diff.mat))
  lim <- max(abs(chg$change), na.rm = TRUE)
  fill.lab <- if (from == "first") "Change from\niteration 0" else
    "Change from\nprevious\niteration"
  p.heat <- ggplot(chg, aes(x = year, y = iteration, fill = change)) +
    geom_raster() +
    scale_fill_distiller(palette = "RdBu", limits = c(-lim, lim),
                         direction = 1) +
    scale_y_continuous(breaks = whole.breaks, expand = c(0, 0)) +
    scale_x_continuous(expand = c(0, 0)) +
    labs(x = NULL, y = "Iteration", fill = fill.lab) +
    theme_cowplot()

  depth <- data.frame(year = yrs, samp.depth = info[["ssfCrn"]][["samp.depth"]])
  p.depth <- ggplot(depth, aes(x = year, y = samp.depth)) +
    geom_area(fill = "grey80", color = "grey40") +
    scale_x_continuous(expand = c(0, 0)) +
    labs(x = "Year", y = "Sample depth") +
    theme_cowplot()

  # align the two panels on their left and right edges so the years line up
  plot_grid(p.heat, p.depth, ncol = 1, rel_heights = c(2, 1),
            align = "v", axis = "lr")
}

# ── ssf.curves.plot ──
# One series: its measurements in gray and the curve ssf fit to it at each
# iteration. The curve at iteration 0 is fit to the measurements; later ones
# are fit to the signal-free measurements, so they stop following the
# climate. series is a name or a column number. Left NULL, it picks the
# series whose curve moved the most, as the mean absolute difference between
# its first and last curve divided by its mean width.
ssf.curves.plot <- function(info, series = NULL) {
  curves <- info[["sfRWRescaledCurves_Array"]]
  rw <- info[["sfRW_Array"]][, , 1] # slice 0 holds the measurements
  yrs <- as.numeric(dimnames(curves)[[1]])
  iterations <- as.numeric(dimnames(curves)[[3]])
  last <- length(iterations)

  if (is.null(series)) {
    moved <- numeric(ncol(rw))
    for (i in seq_len(ncol(rw))) {
      moved[i] <- mean(abs(curves[, i, last] - curves[, i, 1]), na.rm = TRUE) /
        mean(rw[, i], na.rm = TRUE)
    }
    series <- which.max(moved)
  }
  if (is.numeric(series)) series <- colnames(rw)[series]
  if (!series %in% colnames(rw)) stop("no series named ", series)

  # this series' measurements and curves, long, without the years it has none
  has <- !is.na(rw[, series])
  meas <- data.frame(year = yrs[has], width = rw[has, series])
  crv <- data.frame(year = rep(yrs[has], times = last),
                    iteration = rep(iterations, each = sum(has)),
                    curve = as.vector(curves[has, series, ]))

  ggplot() +
    geom_line(data = meas, aes(x = year, y = width), color = "grey60") +
    geom_line(data = crv, aes(x = year, y = curve, color = iteration,
                              group = iteration), linewidth = 0.9) +
    scale_color_viridis_c(end = 0.9, breaks = whole.breaks) +
    labs(x = "Year", y = "Ring width", color = "Iteration",
         title = series) +
    theme_cowplot()
}

# ── ssf.convergence.plot ──
# The stopping rule, iteration by iteration. Left, MAD on a log scale with
# the threshold ssf stops at: a steady fall is a straight line. Right, each
# MAD divided by the one before it: a flat line means the loop closes the
# gap by the same share each time, a line near 1 means it has stalled, and
# values above 1 mean it is swinging back and forth.
ssf.convergence.plot <- function(info) {
  mad <- info[["MAD_Vec"]]
  threshold <- info[["infoList"]][["mad.threshold"]]
  if (length(mad) < 2) stop("ssf ran too few iterations to show convergence")
  # MAD_Vec[1] compares iteration 2 with iteration 1
  conv <- data.frame(iteration = seq_along(mad) + 1, mad = mad)
  conv$ratio <- c(NA, mad[-1] / mad[-length(mad)])

  p.mad <- ggplot(conv, aes(x = iteration, y = mad)) +
    geom_hline(yintercept = threshold, linetype = "dashed", color = "grey40") +
    geom_line(color = "grey40") +
    geom_point(aes(color = iteration), size = 2.5) +
    scale_y_log10() +
    scale_color_viridis_c(end = 0.9, limits = c(0, max(conv$iteration)),
                          guide = "none") +
    scale_x_continuous(breaks = whole.breaks) +
    labs(x = "Iteration", y = "MAD from previous iteration",
         subtitle = if (isTRUE(info[["converged"]])) "Converged" else
           "Did not converge") +
    theme_cowplot()

  p.ratio <- ggplot(conv[-1, ], aes(x = iteration, y = ratio)) +
    geom_hline(yintercept = 1, linetype = "dashed", color = "grey40") +
    geom_line(color = "grey40") +
    geom_point(aes(color = iteration), size = 2.5) +
    scale_color_viridis_c(end = 0.9, limits = c(0, max(conv$iteration)),
                          guide = "none") +
    scale_x_continuous(breaks = whole.breaks) +
    expand_limits(y = 0) +
    labs(x = "Iteration", y = "MAD / previous MAD", subtitle = " ") +
    theme_cowplot()

  plot_grid(p.mad, p.ratio, ncol = 2)
}

# ── ssf.spectrum.plot ──
# Where in frequency the loop changes the chronology. Ed Cook's view is that
# signal-free detrending should help most at medium frequencies, the band a
# detrending curve flexible enough to follow the age trend also bends to
# follow. Periods are on a log axis, from 2 years out to the length of the
# chronology.
# Without truth, two panels:
#   a  the smoothed periodogram of the chronology at each iteration
#   b  each spectrum divided by the one at iteration 0: above 1 is power
#      the loop added at that period, below 1 is power it took away
# With truth (as in ssf.truth.plot), a third:
#   c  the spectrum of the error, chronology minus truth, at each iteration:
#      the periods where the loop gets closer to the truth are where these
#      lines drop below the iteration 0 line
# spans sets the smoothing of the periodogram (see ?spec.pgram); wider
# spans give smoother lines and blur nearby periods together.
ssf.spectrum.plot <- function(info, truth = NULL, spans = c(3, 3)) {
  crn.mat <- info[["sfCrn_Mat"]]
  if (!is.null(truth)) {
    common <- intersect(rownames(crn.mat), names(truth))
    crn.mat <- crn.mat[common, , drop = FALSE]
    truth <- truth[common] / mean(truth[common])
  }
  iterations <- as.numeric(colnames(crn.mat))

  # smoothed periodogram of one series, as a data frame by period
  spec.df <- function(x) {
    s <- spec.pgram(x, spans = spans, taper = 0.1, detrend = TRUE,
                    plot = FALSE)
    data.frame(period = 1 / s$freq, power = s$spec)
  }

  spec.all <- NULL
  err.all <- NULL
  for (j in seq_along(iterations)) {
    x <- crn.mat[, j] / mean(crn.mat[, j])
    s <- spec.df(x)
    s$iteration <- iterations[j]
    spec.all <- rbind(spec.all, s)
    if (!is.null(truth)) {
      e <- spec.df(x - truth)
      e$iteration <- iterations[j]
      err.all <- rbind(err.all, e)
    }
  }
  # divide every spectrum by iteration 0's, period by period
  base <- spec.all$power[spec.all$iteration == 0]
  spec.all$ratio <- spec.all$power / rep(base, times = length(iterations))

  period.axis <- scale_x_log10(breaks = c(2, 5, 10, 20, 50, 100, 200, 500))
  iter.color <- scale_color_viridis_c(end = 0.9, breaks = whole.breaks)

  p.a <- ggplot(spec.all, aes(x = period, y = power, color = iteration,
                              group = iteration)) +
    geom_line() +
    period.axis + scale_y_log10() + iter.color +
    labs(x = "Period (years)", y = "Power", color = "Iteration") +
    theme_cowplot()

  p.b <- ggplot(spec.all[spec.all$iteration > 0, ],
                aes(x = period, y = ratio, color = iteration,
                    group = iteration)) +
    geom_hline(yintercept = 1, linetype = "dashed", color = "grey40") +
    geom_line() +
    period.axis + scale_y_log10() + iter.color +
    labs(x = "Period (years)", y = "Power / power at iteration 0",
         color = "Iteration") +
    theme_cowplot()

  if (is.null(truth)) {
    return(plot_grid(p.a, p.b, ncol = 1, labels = c("a", "b"),
                     align = "v", axis = "lr"))
  }

  p.c <- ggplot(err.all, aes(x = period, y = power, color = iteration,
                             group = iteration)) +
    geom_line() +
    period.axis + scale_y_log10() + iter.color +
    labs(x = "Period (years)", y = "Error power",
         color = "Iteration") +
    theme_cowplot()
  plot_grid(p.a, p.b, p.c, ncol = 1, labels = c("a", "b", "c"),
            align = "v", axis = "lr")
}
