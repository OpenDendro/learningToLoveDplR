# Draws the cover art, assets/cover-art.svg, from co021.
# index.qmd reads the svg at render time. Run from the book root:
#   Rscript assets/cover-art.R
# Three panels: one core drawn ring by ring, its ring widths with the
# detrending curve, and the site chronology over its sample depth.

library(dplR)
data(co021)

ink   <- "#1a3a5c"
amber <- "#c8922a"
x0 <- 30; x1 <- 510                       # plot area, left and right

pts <- function(x, y) paste0(sprintf("%.1f,%.1f", x, y), collapse = " ")
txt <- function(x, y, s, cl = "axl", anchor = "start") {
  sprintf('<text class="%s" x="%.1f" y="%.1f" text-anchor="%s">%s</text>',
          cl, x, y, anchor, s)
}
ln <- function(xa, ya, xb, yb, cl = "ax") {
  sprintf('<line class="%s" x1="%.1f" y1="%.1f" x2="%.1f" y2="%.1f"/>',
          cl, xa, ya, xb, yb)
}

# ── one series: the shortest complete one, so single rings stay visible ──
id  <- "645232"
rw  <- co021[[id]]
yrs <- time(co021)[!is.na(rw)]
rw  <- rw[!is.na(rw)]
fit <- detrend.series(rw, method = "Spline", make.plot = FALSE,
                      return.info = TRUE)
crv <- fit$curves

# ── panel 1: the core, pith side left, one line per ring boundary ──
cTop <- 28; cBot <- 60
edge <- x0 + cumsum(rw) / sum(rw) * (x1 - x0)
mid <- edge - rw / sum(rw) * (x1 - x0) / 2     # center of each ring
# pinpricks as on a mounted core: one dot each decade, two at fifty years,
# three on the century, stacked across the core
decade <- yrs %% 10 == 0
nDots <- ifelse(yrs %% 100 == 0, 3, ifelse(yrs %% 50 == 0, 2, 1))[decade]
dotX <- rep(mid[decade], nDots)
dotY <- (cTop + cBot) / 2 + unlist(lapply(nDots, function(n) (seq_len(n) - (n + 1) / 2) * 5))
core <- c(
  txt(x0, 16, "Series 645232", "lbl"),
  sprintf('<rect x="%d" y="%d" width="%d" height="%d" rx="2" fill="#f3e6cc" stroke="#b08a52" stroke-width="1"/>',
          x0, cTop, x1 - x0, cBot - cTop),
  sprintf('<path class="ring" d="%s"/>',
          paste0(sprintf("M%.1f %d V%d", edge[-length(edge)], cTop + 1, cBot - 1),
                 collapse = " ")),
  sprintf('<circle cx="%.1f" cy="%.1f" r="1.4" fill="%s"/>', dotX, dotY, ink),
  txt(x0, cBot + 13, min(yrs)),
  txt(x1, cBot + 13, max(yrs), anchor = "end"),
  txt((x0 + x1) / 2, cBot + 13,
      sprintf("%d rings, %.0f mm", length(rw), sum(rw)), anchor = "middle")
)

# ── panel 2: ring widths and the detrending curve ──
pTop <- 112; pBot <- 232
xs <- function(y) x0 + (y - min(yrs)) / diff(range(yrs)) * (x1 - x0)
ymax <- ceiling(max(rw))
ys <- function(v) pBot - v / ymax * (pBot - pTop)
xt <- seq(1500, 1650, by = 50)
widths <- c(
  ln(x0, 84, x1, 84, "sep"),
  txt(x0, 102, "Ring widths", "lbl"),
  ln(x0, pBot, x1, pBot), ln(x0, pTop, x0, pBot),
  txt(x0 - 6, ys(0:ymax) + 3, 0:ymax, anchor = "end"),
  txt(x0 - 6, pTop - 8, "mm", anchor = "end"),
  txt(xs(xt), pBot + 13, xt, anchor = "middle"),
  sprintf('<polyline fill="none" stroke="%s" stroke-width="1.3" stroke-linejoin="round" points="%s"/>',
          ink, pts(xs(yrs), ys(rw))),
  sprintf('<polyline fill="none" stroke="%s" stroke-width="2.4" stroke-linecap="round" points="%s"/>',
          amber, pts(xs(yrs), ys(crv))),
  ln(396, 108, 420, 108, "key-ink"),  txt(425, 111, "measured"),
  ln(396, 122, 420, 122, "key-amb"),  txt(425, 125, "growth curve")
)

# ── panel 3: the chronology, with sample depth underneath ──
crn <- chron(detrend(co021, method = "Spline"))
cy  <- time(crn)
smo <- caps(crn$std, nyrs = 30)
qTop <- 286; qBot <- 416; dTop <- 446; dBot <- 496
xc <- function(y) x0 + (y - min(cy)) / diff(range(cy)) * (x1 - x0)
cmax <- ceiling(max(crn$std) * 2) / 2
yc <- function(v) qBot - v / cmax * (qBot - qTop)
yd <- function(n) dBot - n / max(crn$samp.depth) * (dBot - dTop)
ct <- seq(1200, 1900, by = 100)
chronology <- c(
  ln(x0, 258, x1, 258, "sep"),
  txt(x0, 276, "Chronology", "lbl"),
  ln(x0, qBot, x1, qBot), ln(x0, qTop, x0, qBot),
  ln(x0, yc(1), x1, yc(1), "zl"),
  txt(x0 - 6, yc(c(0, 1, 2)) + 3, c(0, 1, 2), anchor = "end"),
  sprintf('<polyline fill="none" stroke="%s" stroke-width="0.9" stroke-linejoin="round" points="%s"/>',
          ink, pts(xc(cy), yc(crn$std))),
  sprintf('<polyline fill="none" stroke="%s" stroke-width="2.4" stroke-linecap="round" points="%s"/>',
          amber, pts(xc(cy), yc(smo))),
  sprintf('<polygon fill="%s" opacity="0.16" points="%s"/>', ink,
          pts(c(x0, xc(cy), x1), c(dBot, yd(crn$samp.depth), dBot))),
  sprintf('<polyline fill="none" stroke="%s" stroke-width="1" points="%s"/>',
          ink, pts(xc(cy), yd(crn$samp.depth))),
  ln(x0, dBot, x1, dBot),
  txt(x0 + 6, dTop + 2, "sample depth"),
  txt(x1, yd(max(crn$samp.depth)) - 5,
      sprintf("%d series", max(crn$samp.depth)), anchor = "end"),
  txt(xc(ct), dBot + 13, ct, anchor = "middle"),
  txt(x1, 276, "co021, Mesa Verde Douglas-fir", anchor = "end")
)

svg <- c(
  '<svg class="art-svg" viewBox="0 0 520 516" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="A tree core, its ring widths with a fitted growth curve, and the Mesa Verde chronology with its sample depth">',
  "<style>",
  "  .art-svg .ax  { stroke:#c0ccda; stroke-width:1; fill:none; }",
  "  .art-svg .zl  { stroke:#c0ccda; stroke-width:0.8; fill:none; stroke-dasharray:3 3; }",
  "  .art-svg .sep { stroke:#dde5ee; stroke-width:1; stroke-dasharray:5 4; fill:none; }",
  "  .art-svg .ring { stroke:#8a5a2b; stroke-width:0.7; fill:none; opacity:0.8; }",
  sprintf("  .art-svg .key-ink { stroke:%s; stroke-width:1.6; }", ink),
  sprintf("  .art-svg .key-amb { stroke:%s; stroke-width:2.4; }", amber),
  "  .art-svg .axl { font-family:'Source Code Pro',monospace; font-size:9px; fill:#8a9aaa; letter-spacing:0.5px; }",
  "  .art-svg .lbl { font-family:'Source Code Pro',monospace; font-size:10px; font-weight:600; fill:#1a2535; letter-spacing:2px; text-transform:uppercase; }",
  "</style>",
  core, widths, chronology,
  "</svg>"
)
writeLines(svg, "assets/cover-art.svg")
