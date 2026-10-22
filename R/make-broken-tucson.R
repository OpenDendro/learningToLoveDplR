# Make a Tucson file with known defects, for the aside on the Tucson format.
#
# Seven series from co021, 1900-1963, written with write.tucson and then broken
# by hand, one defect per series except the control. The result is
# data/co021broken.rwl. make.broken.tucson() returns a table of what was
# planted, so the aside can check the reader against it.
#
# Run from the book's root:
#   source("R/make-broken-tucson.R"); make.broken.tucson()

make.broken.tucson <- function(out = "data/co021broken.rwl") {
  co021 <- suppressMessages(dplR::read.rwl("data/co021.rwl", format = "tucson"))
  keep <- c("641114", "641121", "641132", "641143", "642114", "642121", "642143")
  x <- suppressMessages(window(co021, 1900, 1963))[, keep]

  # Every series but 641121 at 0.01 mm; 641121 at 0.001 mm, so the file has
  # mixed precision, which the format allows.
  f01 <- tempfile(fileext = ".rwl")
  f001 <- tempfile(fileext = ".rwl")
  on.exit(unlink(c(f01, f001)))
  dplR::write.tucson(x[, keep != "641121"], f01)
  dplR::write.tucson(x[, "641121", drop = FALSE], f001, prec = 0.001)
  lines01 <- readLines(f01)
  lines001 <- readLines(f001)
  id <- substr(lines01, 1, 6)

  # 641121: the -9999 that ends the series is lost, and with it the only
  # statement in the file that the series is in 0.001 mm.
  lines001 <- sub(" -9999$", "", lines001)

  # 641132: a nine-character ID, which pushes the year out of columns 9-12.
  i <- id == "641132"
  lines01[i] <- paste0("MV641132X", substring(lines01[i], 9))

  # 641143: the 1930s line pasted in twice.
  dup <- which(id == "641143" & substr(lines01, 9, 12) == "1930")

  # 642121: labeled 642114, so two cores share an ID over the same years.
  i <- id == "642121"
  lines01[i] <- paste0("642114", substring(lines01[i], 7))

  # 642143: the letter O typed for a zero in the 1920s.
  o <- which(id == "642143" & substr(lines01, 9, 12) == "1920")
  vals <- substring(lines01[o], seq(13, 67, 6), seq(18, 72, 6))
  hit <- grep("0$", vals)[1]
  vals[hit] <- sub("0$", "O", vals[hit])
  lines01[o] <- paste0(substr(lines01[o], 1, 12), paste0(vals, collapse = ""))

  lines01 <- append(lines01, lines01[dup], after = dup)
  first <- which(id == "641114")
  broken <- append(lines01, lines001, after = max(first))
  writeLines(broken, out, sep = "\r\n")

  data.frame(
    series = c("641114", "641121", "641132", "641143", "642121", "642143"),
    defect = c("none (control)",
               "0.001 mm series with its -9999 stop marker missing",
               "nine-character ID (MV641132X) pushing the year out of columns 9-12",
               "1930s line repeated",
               "labeled 642114, sharing an ID and years with another core",
               paste0("letter O for zero in ", 1920 + hit - 1)),
    stringsAsFactors = FALSE
  )
}
