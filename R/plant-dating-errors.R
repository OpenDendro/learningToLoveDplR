# Plant known dating errors in co021, for the crossdating chapters.
#
# The collection is read from data/co021.rwl and two series are misdated with
# dplR's own ring-edit methods, keeping each series' outer year fixed, as a
# misdated core from a living tree would be:
#   645221  the 1797 ring deleted: a missing ring, so every ring inside it
#           is dated a year too late.
#   643143  the 1425 ring counted twice: a false ring, so every ring inside
#           it is dated a year too early.
# plant.dating.errors() returns the misdated collection with the table of what
# was planted as the attribute "planted", so a chapter can check its findings
# against the truth. Undo with insert.ring() and delete.ring(); chapter 06 does.
#
# Run from the book's root:
#   source("R/plant-dating-errors.R"); co021Bad <- plant.dating.errors()

plant.dating.errors <- function(file = "data/co021.rwl") {
  x <- suppressMessages(dplR::read.rwl(file, format = "tucson"))
  x <- dplR::delete.ring(x, series = "645221", year = 1797)
  x <- dplR::insert.ring(x, series = "643143", year = 1425,
                         ring.value = x[["643143"]][time(x) == 1425])
  attr(x, "planted") <- data.frame(
    series = c("645221", "643143"),
    year = c(1797, 1425),
    error = c("missing ring", "false ring"),
    expected.lag = c(-1, 1)
  )
  x
}
