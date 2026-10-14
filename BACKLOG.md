# Backlog

Working notes for the rewrite. Not part of the book.

## Start here (left open 2026-10-13)

State of the repo: the Quarto conversion, the restructure into parts, the stubs and the dataset work are on the `quarto-rewrite` branch. `main` is still the 2024 bookdown version. The folder moved from `workshopMaterials/dplR-workshop` to `openDendro/learningToLoveDplR`; the GitHub repo was renamed from `OpenDendro/dplR-workshop` to `OpenDendro/learningToLoveDplR` on 2026-10-13, and the old name no longer resolves. The writing spec is a local file and is not in the repo.

### Structure, done 2026-10-13

- "Standardization and Chronologies" is now 05 Detrending, 06 Chronology Statistics, 07 Chronologies. Regional Curves (08) and Signal-Free (09) are their own part, "Regional Curves and Signal-Free".
- New part "Trees and Disturbance" after Time Series: 15 Basal Area, 16 Events. The part names are placeholders; change them in `_quarto.yml`.
- Files renumbered with `git mv`: Crossdating is 10 to 12 (asides 10x, 12x), Smoothing and Filtering is 13, Memory and Cycles is 14, Basal Area is 15. 01 to 09 and 16 to 18 kept their numbers.
- `treeMean` is out of 06 and belongs in "Trees and Disturbance". Undecided: a section of Basal Area, or a short chapter of its own on tree-level series.

### Structure suggestions, undecided

- Trim the time series chapters (13, 14) against the time series book. Keep what is specific to tree rings (the spline and its frequency response, the residual chronology, `redfit`, wavelets) and point to that book for the rest.
- Crossdating comes after standardization, so the book's order differs from the order of a project. Done 2026-10-13: a paragraph each in the Preface, A First Pass and Checking a Collection (Wrapping Up) says dating comes first in practice and points to 10Crossdating. Check the reason the Preface gives for the order (dplR's crossdating tools prewhiten and use a biweight master, so they lean on the standardization chapters). That reason is mine, and you may have had another one. Keep these paragraphs when those chapters are rewritten.

### Open decisions

- dplR version in CI. Decided 2026-10-13: dplR 1.8.1 goes to CRAN only after the rewrite is done, since more dplR changes are expected (signal-free especially). Until then `DESCRIPTION` has `OpenDendro/dplR` under `Remotes:`, so CI builds on dplR's master and dplR changes must be pushed before the chapters that need them. When 1.8.1 is on CRAN: take the remote out, and check that `01Welcome.qmd`, which tells readers to `install.packages("dplR")`, needs no note about the dev version.
- Deployment. The workflow in `.github/workflows/publish.yml` deploys with GitHub Actions and `docs/` is gitignored but still tracked. Before pushing: switch Pages to "workflow" and run `git rm -r --cached docs`. Until both are done the old bookdown site stays live.
- Cover page: first version 2026-10-13, same layout as the time series book. `assets/cover-art.R` draws the art from `co021` into `assets/cover-art.svg`, which `index.qmd` reads at render time.
- `LICENSE.md`, `CITATION.cff`, `.zenodo.json`: drafted 2026-10-13 on the pattern of the time series and spatial books (CC BY-NC-SA 4.0 for prose and figures, MIT for code). `LICENSE.md` says the data in `data/` and in dplR keep their sources' terms. Still to add once they exist: `url` (the site address) and `doi` and `date-released` in `CITATION.cff`. The README has no license section yet and is still the 2022 text.
- Favicon: not started.
- The 54 chunks that were unnamed in the 2022 chapters are still unlabeled.
- Whether to split the chapter skeleton and code conventions out of the writing spec into a `CRC-POLISH.md`, as in the other books.

### Suggested next step

Chronology Statistics (06) and Chronology Building (07) have first full drafts (2026-10-13). Read them against the spec and decide whether they are the template. Then 05 Detrending, which both lean on and which is still the 2022 text on `ca533`.

Before either goes to CI: 07 needs 1.8.1 dev, which CI now installs from GitHub (see "Open decisions"), so the dplR changes must be pushed first. Neither chapter has been rendered as part of the whole book, only alone.

### 07 Chronology Building, for Andy to check

- Detrending is `Spline` with defaults on both collections, as decided 2026-10-13. The stripping section is as you wrote it except for `wa082RWI` renamed `wa082Rwi`, the sentence about the age-dependent spline (now the default spline, two thirds of series length), and a link to 06. With `Spline` indices `strip.rwl` removes 6 of the 23 series and one whole tree, so the inline numbers in that section have changed from the `AgeDepSpline` version.
- ARSTAN chronology at Hurricane Ridge. `chron.ars` gave a negative lag-one autocorrelation there (-0.15) because it added the pooled model to the individually whitened series and skipped the second whitening. Fixed in dplR 1.8.1 dev on 2026-10-13 (uncommitted): `ars` is now `res` with the pooled model put back, as the help page and ARSTAN_49v1b.f have it. The chapter's paragraph is rewritten for the new numbers and carries a version note. iDetrend also calls `chron.ars`, so its ARSTAN chronology changes with 1.8.1.
- `chron(prewhiten = TRUE)` gives a residual chronology with lag-one autocorrelation of -0.23 at `wa082`. The chapter says so, against the old line that the residual chronology is white noise.
- Opinions written for you: "I use SSS" over a depth cutoff; "I detrend the whole series and cut afterward" (the 2022 text leaned the other way, cut the widths and then detrend); "Use the trees" for `chron.ci`.
- The 2022 remark that uncertainty grows toward the end of the chronology is gone. It came from `AgeDepSpline`: the mean standard error across series in 1950 to 1983 is 0.146 with it and 0.059 with `Spline`.
- `treeMean()` returned class `rwl` when given class `rwi`. Fixed in dplR 1.8.1 dev on 2026-10-13 (uncommitted), and the chapter calls it without `as.rwi()`, so this is one more thing in 07 that needs dev dplR.
- Variance section, rewritten 2026-10-13 as "Variance, Sample Depth and Agreement". Depth alone explains only the first half century at `wa082`; the 1800 to 1850 block is as variable as 1700 to 1750 because rbar is 0.44 there against 0.23 after 1950. Depth, block rbar and series spread together predict the observed standard deviation within about 0.02 in every block. The section shows a depth-only adjustment by hand next to `chron.stabilized`, which also scales for running rbar. Check two things written for you: that Frank et al. (2006) treat changes in rbar as an artifact (taken from the dplR help page, not reread in the paper), and the paragraph saying higher agreement at constant series spread can be a stronger shared signal, so scaling it away is a judgment call.
- Not in the chapter: dplPy treats stabilization as a step applied to any finished chronology, where dplR's function builds one from indices. That was a note for this section and belongs in 17DplPy if anywhere.
- Dropped from the 2022 chapter: the hand-rolled standard error ribbon, the `tidyverse` code, the spaghetti plot and "Go foRth!".
- Needs dev dplR 1.8.1 (`strip.rwl` with `nyrs`, indices and the `dplR.strip` attribute). `_freeze/07Chronologies` was rendered against it.

### 06 Chronology Statistics, for Andy to check

- Detrending. Both collections use `detrend(method = "Spline")` with defaults, to match A2DataSources. This was not decided, only defaulted. Changing it is one line in `stats-setup`, and the prose numbers are inline so they follow.
- First-person statements written for you: "The rule I follow is to compute the statistics on the indices that go into the chronology I am going to use" (prewhiten for a residual chronology, not for a standard one), and "I don't know" why rbar falls at Hurricane Ridge after the 1833 window. Keep, change or cut.
- "Wigley and colleagues did not hand it down as a threshold." Written from the dplR help page for `sss` and from memory of Buras (2017), not from rereading Wigley et al. (1984). Check the wording against the paper.
- The effective rbar is cited to Briffa and Jones (1990). Confirm that is the right source for the formula `rwi.stats` uses.
- The approximation for `interseries.cor` (square root of rbar times EPS of the other series) is my derivation for equally correlated series. It lands within 0.01 on both collections. Not from a paper.
- Plots are black and white `theme_minimal`, with line type and point shape in place of colour. No palette was chosen.
- `common.interval` is in an exercise only. `rwi.stats(co021Rwi, co021Ids, period = "common")` stops with "too few years with enough trees", which the exercise leads the reader to.
- Rendered against local dplR 1.8.1. Not run against CRAN 1.8.0, which is what CI installs. `_freeze/06ChronologyStats` is new and untracked.
- Finding worth knowing for 07: with `prewhiten = TRUE` the twentieth-century drop in running rbar at `wa082` is smaller and EPS stays above 0.87 in every full-depth window (last window rbar.eff 0.430, EPS 0.901).

### Outside this repo

- dplR 1.8.1 dev changes this book now depends on, all made 2026-10-13 and handed over for commit that day: `strip.rwl()` (the row-count fix, `nyrs`, stripping indices, the `dplR.strip` record), `chron.ars()` (ARSTAN chronology built from the residual chronology), and `treeMean()` (returns class `rwi` for indices). CRAN 1.8.0 has none of them, so 07 does not render on it. The `chron()` help page also gained a caution about the residual chronology.
- dplR, not done: none of the 2026-10-13 changes had the full test suite or `R CMD check` run, only the test files touched. `chron.ars()` still reuses the pooled order for the second whitening, where ARSTAN picks it afresh. iDetrend calls `chron.ars()`, so its ARSTAN chronology changes with 1.8.1.
- dplR: `ssf(return.info = TRUE)` returns a list with class `crn`.
- dplR `TODO` has a new item: revamp the plots.

## Standing notes

- Plots: include new ggplot figures where they are useful. Most of dplR's own plot methods date from before 2010 and are due a revamp (see dplR's TODO), so don't lean on them where a ggplot shows the data better.

## Running datasets (decided 2026-10-06)

- `co021` (Mesa Verde Douglas-fir) and `wa082` (Hurricane Ridge Pacific silver fir) are carried through the book. The reasons, with the evidence, are written up in A2DataSources.
- `co021` is the strong-signal collection: 14th of 6,764 ITRDB ring-width files for interseries correlation, no flagged segments until an error is planted, 716 absent rings.
- `wa082` is the ordinary one: 44th percentile, EPS near 0.85, and the sample-depth and SSS cutoffs disagree. Its raw file has a `-999` gap in 712011 at 1900 that the on-board copy holds as zero.
- `gp.rwl` for Regional Curves and Basal Area (pith offsets and diameters; `zof.rwl` has them too). `ca533` for Signal-Free only. `cana157` for Events.
- `data/` holds `co021.rwl` and `wa082.rwl` as served by the ITRDB. Chapters 02, 04 and 05 still use `ca533` and need switching when they are rewritten.
- The "zip `data/` into the site" step is in `publish.yml` (2026-10-13, copied from the time series book), and A2DataSources links to `data.zip`. The link is relative and only works on the deployed site, since `data.zip` is made in CI. Check it after the first deploy.
- Still needed: a deliberately broken file for the Tucson aside; an entry for the two files in a permissions log if the book goes to a publisher.
- Rule adopted with this decision: don't describe what a dataset is good for without checking it against the data. Unchecked claims are listed in the callout at the top of A2DataSources.

## Coverage decisions (2026-10-06)

- `net` is left out of the book.
- `glk` and `sgc` get an aside (10xAsideSignAgreement).
- `sea` and `pointer` get a chapter (16Events).
- `treeMean` is framed the way it is used: ecological work on tree-to-tree differences.
- The smaller functions (`series.rwl.plot`, `skel.plot`, `xskel.plot`, `common.interval`, `read.crn`, `bakker`, `gini.coef`) go in only where they fit. Not if clunky.
- `kalman.ar` and `kalman.spec` (added to dplR dev 2026-10-07) go in the Time Series part: evolutive AR spectra by the Kalman filter, with `profile` for choosing `lambda`. They follow from the AR models and `redfit` in 14MemoryCycles, so that chapter is the likely home, or a chapter of their own after it. They exist only in dplR dev, so the book needs dev dplR in CI once they are used. Open questions on choosing the order and `lambda`, and the comparison with Ed Cook's programs, are in dplR's `TODO`; settle those before writing the section.
- Chronology Statistics now comes before Chronology Building, because the SSS cutoff, EPS stripping and variance stabilization depend on rbar, EPS and SSS.

## Planned revisions to carried-over chapters

- 10Crossdating: the chapter never mentions `xdate.report` or `write.xdate.report`.
- 13SmoothingFiltering: lead with `pass.filt` and fold the manual `signal` padding code.
## Known problems in carried-over chapters

- 07Chronologies: `strip.rwl()` stops with an error in CRAN dplR 1.8.0 and works in 1.8.1 dev. The stripping section was rewritten on 2026-10-13 around the dependence on detrending. It uses `nyrs`, stripping of indices and the `dplR.strip` attribute, all added to 1.8.1 dev that day and uncommitted, and its inline numbers stop the render without them. `error: true` is off. Install dev dplR before rendering; the rest of the chapter is still the old text.
- 09SignalFree: written against the 2024 output of `ssf(return.info = TRUE)`; nine chunks fail. The chapter has `error: true`.
- A3Acknowledgements fetches the author list from crandb at build time.
