# Backlog

Working notes for the rewrite. Not part of the book.

## Start here (left open 2026-10-13)

State of the repo: the Quarto conversion, the restructure into parts, the stubs and the dataset work are on the `quarto-rewrite` branch. `main` is still the 2024 bookdown version. The folder moved from `workshopMaterials/dplR-workshop` to `openDendro/learningToLoveDplR`; the GitHub repo was renamed from `OpenDendro/dplR-workshop` to `OpenDendro/learningToLoveDplR` on 2026-10-13, and the old name no longer resolves. The writing spec is a local file and is not in the repo.

### Ring Widths outlines, 2026-10-19 (uncommitted)

- `03ReadingWriting.qmd` and `03xAsideTucsonFormat.qmd` are outlines, section by section. 03 is built around the `wa082` 1900 gap: file holds `-999`, `read.tucson` gives `NA`, `fill.internal.NA = 0` and `read.tucson.legacy` give 0. Checked 2026-10-19: `rwl.check` on the file warns (`RWL_INTERNAL_NA`) and notes 712011 is uncheckable; on the on-board `wa082` (legacy zero) it gives only `RWL_ZERO_RING`, so the gap is invisible once it is a zero.
- `04CheckingCollection.qmd` moved off `ca533`. It reads `data/co021.rwl` and `data/wa082.rwl` (so `wa082` has the `NA`). The report and series statistics sections are written to the spec with inline numbers; the base-R boxplot is replaced by one ggplot of `ar1` for both collections. The rest (segment and depth plots, `rwl.check`, trimming) is an outline.
- Dev dplR: nothing in 03 needs 1.8.1. 04 needs none of it now that filling moved to 08; 08's Closing the Gap needs it for `fill.internal.NA(fill = "Chron")` and `series =`, and for the filled object keeping class `rwl`. `RWL_ZERO_RUN` doesn't fire on either collection. The column-73 stop marker fix matters only if the broken file for 03x plants one.
- Decided 2026-10-19 (Andy): 712011's 1900 gap stays open through crossdating and is filled at the start of 08 Detrending, where `detrend` first refuses it. The "Closing the Gap" outline moved from 04 to 08; 04 keeps a short section, "The Gap in 712011", pointing forward. Checked 2026-10-19 with the gap open: `xdate.report` lists 712011 under `excluded` (the `nyrs` spline needs an unbroken series); `corr.rwl.seg` gives it no correlation for 1875-1924 or 1900-1949; `ccf.series.rwl` loses 1900-1949; `interseries.cor` works (0.66) with a warning. The crossdating chapters use `co021`, so little is lost. 04's exercise on fills became one on what `xdate.report` says about 712011.
- Not explained yet (now in 08's outline): `Chron` fills 1900 at 0.24 against 0.45 (1899) and 0.39 (1901); `Linear` 0.42, `Spline` 0.47. The other series' mean spline index in 1900 is about 0.82, so a narrow year, but that doesn't obviously give half the neighbours. Work through the method before 04 says why.
- For Andy to check: Biondi and Qeadan (2008) for the Gini coefficient, from memory of the help page, not in `dplR.bib`. Further Reading for 03 has no Tucson-format citation yet.
- Open: whether `read.crn` and `write.crn` belong in 03 or 10. The name of the broken file for 03x and whether it is made in a chunk or an `R/` script.
- dplR, found 2026-10-19, not fixed: after `fill.internal.NA(fill = "Chron")` on `wa082`, `rwl.check` reports precision as 0.002 mm (it infers precision from the filled value; the file is 0.01 mm). And the read record on the filled object still lists the gap as holding `-999` with `fill.internal.NA` NULL, so nothing records that the year was filled or how.

### Chapter 1 and the name-conflicts aside, 2026-10-19 (uncommitted)

- Andy is happy with chapter 2 as the intro and roadmap. Chapter 1 (2022 Welcome) and the name-conflicts aside don't fit in front of it.
- `01xAsideNameConflicts.qmd` is out of `_quarto.yml` until later; the file is kept. Its two links are gone: the pointer sentence in 01Welcome, and the link in the 13SmoothingFiltering footnote (the footnote still says `signal` masks `hanning`). 13 is a likely home if it comes back, since that is where a mask first bites.
- What chapter 1 is for: decided 2026-10-19, the lineage chapter. First draft written the same day (see the next item).

### 01 Where dplR Comes From, first draft 2026-10-19 (uncommitted)

- `01Welcome.qmd` is now "Where dplR Comes From": COFECHA, ARSTAN and the DPL; the 20 to 32-year spline story; a table, computed from `formals`, showing that `xdate.report` (32-year spline, Pearson) and `corr.rwl.seg` (divide by the mean, Spearman) have different defaults; scripture and not a target; other R packages; citing dplR (the "idle rich" paragraph kept). Renamed to `01WhereDplRComesFrom.qmd` with `git mv` (staged, `_freeze` folder too) on 2026-10-19.
- Setup moved to A1, now "Setup, Packages and References": R and an editor, YaRrr, installing dplR (CRAN and the dev version), the package list read from `DESCRIPTION`, `sessionInfo()`. The Preface is rewritten to spec: who the book is for, what it assumes, a pointer to A1, the draft warning.
- New bib entry `GrissinoMayer2001`, checked against the PDF.
- Checked against sources: COFECHA 1982 and the "co-date" name (Grissino-Mayer 2001, p. 205); 20-year spline on California collections (Holmes 1983, p. 72); 32-year default (Grissino-Mayer 2001, p. 207); Fritts 1963 routine and its limits (Holmes 1983, p. 69); no AR modeling in the 1983 description, AR in the 2002 `COFECHA.f` banner; LTRR and IANIGLA (Holmes 1983 acknowledgements); ARSTAN change log 2006 to 2019 with the age-dependent spline in 2014 (`ARSTAN_49v1b.f` header); `/pub/dpl` on the LTRR server (Grissino-Mayer 2001); the 2022 package list against CRAN on 2026-10-19 (`MtreeRing` is archived and was dropped; `BIOdry`, `DendroSync` and `tracheideR` are on CRAN but left out to keep the list short).
- Andy confirmed 2026-10-19: the name dplR is a nod to Holmes's DPL; the DPL is a set of programs sharing Fortran routines; Ed Cook's comment stays in, and Andy added a sentence after the quote. Still resting on Andy's own word: "I started dplR around 2006" (from A3) and the paragraph on tuning dplR to match COFECHA and ARSTAN.
- 2026-10-19, Andy: "A Default Is a Judgment Call" was too inside baseball. Rewritten plain: why COFECHA smooths, 20 years in 1983 and 32 by 2001, Ed on the log transform (Andy's sentence kept), and that dplR makes these arguments. Cut and parked for 05Crossdating or 07x: the `formals` table showing `xdate.report` (32-year spline, Pearson) and `corr.rwl.seg` (divide by the mean, Spearman) default differently; the AR step and the Spearman option Ed says he talked Holmes into; the 1983 paper's lack of AR modeling against the 2002 source. Exercises cut to three (help page `nyrs`, `?detrend` `nyrs`, `citation`); the `wa082` spline and Pearson/Spearman exercises go with the table.
- For 07xAsideCrossdatingStats, not checked carefully: a missing ring planted mid-series in each `wa082` core longer than 200 rings was found at every spline setting, but false flags on other cores averaged 0 with a 10-year spline or with the mean, 0.2 at 20 years, 1.9 at 32, 1.8 at 64 and 1.0 at 100. Some of that is the two series `wa082` flags anyway at 32 years. On `co021` every setting found the ring with no false flags. Worth a proper run before the aside says anything about the 32-year default.

### Crossdating reorder, done 2026-10-15 (uncommitted)

- Crossdating now comes right after Ring Widths. Renamed with `git mv`, `_freeze` folders included: 10Crossdating to 05Crossdating, 10xAsideSignAgreement to 05xAsideSignAgreement, 11FixingErrors to 06FixingErrors, 12Floaters to 07Floaters, 12xAsideCrossdatingStats to 07xAsideCrossdatingStats, 05Detrending to 08Detrending, 06ChronologyStats to 09ChronologyStats, 07Chronologies to 10Chronologies, 08RegionalCurves to 11RegionalCurves, 09SignalFree to 12SignalFree. 01 to 04 and 13 to 18 kept their numbers. Section ids don't use file names, so only the `.qmd` links changed.
- Parts reordered in `_quarto.yml`. Cross-links fixed in 02, 04, 09 and 10.
- Prose: the order-explaining paragraph is cut from the Preface. A First Pass says crossdating has its own part right after reading and checking ring widths. Checking a Collection (Wrapping Up) points to the next chapter. 09 now says the reader met `interseries.cor` in the crossdating chapters rather than that it comes back there.
- File numbers in this backlog are updated to the new names, except in the history below this section.

### Chapter 2 and a quick reference, decided 2026-10-15

- A First Pass goes. It was a workshop TL;DR (read `ca533`, plot, `AgeDepSpline`, `chron`) and in the book it repeats 03, 04, 08 and 10 more thinly, runs defaults without saying why (10 now argues against `AgeDepSpline`), skips crossdating and uses `ca533`.
- It is replaced by the concepts chapter, From Cores to a Record (see the item under "Structure suggestions" and "Simulated collection and the climate thread"). Its overview job moves from code to the six coring-trip questions, each ending with a pointer to its part. It introduces splines and prewhitening as dating tools, which the crossdating part now needs before 08 and 13: `xdate.report` and `rwl.check` use a 32-year spline then AR prewhitening by default; `corr.rwl.seg`, `corr.series.seg` and `ccf.series.rwl` divide by the mean (`nyrs = NULL`) then prewhiten. 05Crossdating's line that each series is "filtered to remove low-frequency variation" is loose for `corr.rwl.seg` and needs fixing in the rewrite.
- Layering for those ideas: 2 gives the intuition, 05 to 07 use the defaults with a sentence on why, 07x gives the mechanics (planned: simulated cores with a shared signal, age trends, AR(1) memory and a planted missing ring, compared raw against filtered; not yet run), 08 and 13 come back to the same spline from the other side.
- New appendix: a one-page quick reference, the main calls in pipeline order (`read.rwl`, `rwl.check`, `xdate.report`, `detrend`, `rwi.stats`, `chron`), one line each with a link to its chapter. For returning readers and for workshops. Not started; file name and position among the appendices open.
- `02FirstPass.qmd` stays in place until the new chapter is written. Blocked on the simulation: decide whether its code lives in the book or becomes `sim.rwl` in dplR, and check Cook's aggregate model against his text.

### References from Kevin, 2026-10-18

Kevin sent a folder of classic papers, now in `workspace/references/`; `notes/folder-summary.md` there lists them by chapter (abstracts read, not the papers). For this book:
- 02: cite Cook (1987, Tree-Ring Bulletin 47) for the aggregate model alongside `Cook1990model`; needs a bib entry. Fritts (1966, Science) and Schulman (1941, Ecology) are short classics for the climate term and site selection.
- 05-07: Douglass (1941) on crossdating vs correlation, Douglass (1946) on precision of dating, Douglass (1929, National Geographic) for the HH-39 story in 07.
- 08: Cook and Peters (1997) on ratio bias, with a Campito Mountain example (`ca533`'s site).
- 09: Wigley et al. (1984) and Buras (2017) are now in hand; check the "not a threshold" sentence against the bodies.
- 10: `frank2006` is the TRACE 4 paper (not in the folder); Frank et al. (2007, GRL) and Osborn et al. (1997) are. Consider citing all three for `chron.stabilized`, as its help page does.
- 11-12: Cook et al. (1995), Briffa et al. (1992), Briffa et al. (1996), Esper et al. (2003), Briffa and Melvin (2011), and Bunn et al. (2004), Andy's own simulation of RCS vs negative exponential.
- Climate part: the Cook, Briffa and Jones NATO report (published as Cook et al. 1994, IJC 14) defines CE; Cook et al. (1999) uses RE and CE; Fritts et al. (1971) for response functions; Meko et al. (1993) found the weakest drought signal in the Pacific Northwest, worth knowing before the `wa082` climate check.
- Cook and Peters (1981) added by Andy 2026-10-18 (`CookPeters1981_spline.pdf`). Still missing: Frank et al. (2006 TRACE), Holmes (1983), Grissino-Mayer (2001), Wigley et al. (1987), Black et al. (2016), Zang and Biondi (2015, Ecography, not Dendrochronologia), Schweingruber et al. (1990), Becker et al. (1994), Nowacki and Abrams (1997).

### 02 An Additive Model of Tree Growth, third draft 2026-10-19 (uncommitted)

Decided with Andy 2026-10-19: the chapter is about the aggregate model (a ring width is several parts, never seen separately, and each method estimates one and can mistake one for another). It is not a quick tour of dplR functions; that job stays with the planned quick-reference appendix. Retitled "An Additive Model of Tree Growth"; the file is still `02CoresToRecord.qmd`, so links and `_freeze` names are unchanged.

New structure: Big Idea (the claim, then the 40 simulated series and what is hidden in them); A Ring Width in Parts (Cook, the method-to-part paragraph, the parts figure, a "Who Shares What" subsection with the within- and between-tree correlations); The Missing Ring; The Crowded Trees; The Stand Event (sample depth, recovery by century, EPS, then the 1880 event); The Released Tree (the Cook signal/noise quote moved here); What the Simulation Leaves Out (Schulman's selection point folded into the site bullet); Wrapping Up with a method / part / what it mistakes / where-in-the-book table and the project-order paragraph. The six coring-trip questions are no longer headings. Cut: the pith-offset summary (belongs in 11 Regional Curves), the naming-scheme aside, and the body text and hidden chunk on the between-tree rbar shortfall (now only exercise 1). Exercises reordered to follow the sections. Computed numbers unchanged.

### 02 From Cores to a Record, second draft 2026-10-19 (uncommitted)

Prose reworked against the papers in `workspace/references/`; code, figures and computed numbers unchanged from the first draft (re-rendered fresh, same values). New citations, each checked against the PDF:
- Cook (1987) pp. 38-45 (scan, read as page images): the model and its terms, the signal/noise quote (p. 38, the chapter's one direct quote), open vs closed-canopy A (p. 40, Fig. 1), D2 example of logged hemlocks (Fig. 3), heteroscedasticity r = 0.67 in lodgepole pine (p. 43), and the no-covariance caveat (p. 43), now used for the crowded tree.
- Schulman (1941): selection is deliberately non-random; the crossdated group is the unit of study; false and locally absent rings.
- Douglass (1941): no correlation formula should decide dating; first principle of interpretation (many trees, wide area, long time means climate), used to open Solid for What?; the Mesa Verde canyon slope as one of the best sites in forty years. That is Mesa Verde fir in general, not a claim that `co021` is the same trees.
- Fritts (1966): two radii in each of ten trees; complacent vs sensitive along the forest-border gradient; outer rings hold more wood; indices with mean 1 and equal weight.
- Holmes (1983): COFECHA's spline, master without the series, 50-year segments lagged 25, a 20-year spline chosen by trial, not a substitute for crossdating on the wood.
- Black et al. (2016): abstract only, for 1% and 5% dating error rates.
- Wigley et al. (1984) p. 206 (scan): common signal can come from management, pests and disease, pollution; no obvious EPS level for reconstruction. Buras (2017) for how that got lost.
- Bunn et al. (2004) as the precedent for the simulation.
New bib entries: `Cook1987`, `Schulman1941`, `Douglass1941`, `Fritts1966`, `Holmes1983`, `Black2016`, `Bunn2004`. Not checked against the PDFs: Douglass volume 39 (from memory) and the issue numbers, which are left out for Black, Douglass and Fritts.
New exercise 6 (spline stiffness in `xdate.report`, Holmes's trade-off), not run.
For Andy: `GrissinoMayer2001_softwareReview.pdf` (was `Grissino 2001.pdf`) in the references folder is a 2001 software review of a dendrology CD, not the COFECHA manual.

### 02 From Cores to a Record, first draft 2026-10-17 (uncommitted)

`02FirstPass.qmd` renamed with `git mv` to `02CoresToRecord.qmd` and rewritten; `_freeze/02FirstPass` removed, the new chapter renders on its own and in the full book. The old TL;DR code walk-through is gone from the chapter; it belongs in the quick-reference appendix, still not started.

Structure: Big Idea; Packages; A Collection Built from Parts (Cook's model, the parts of SIM10A); then the six questions as sections (What Do I Have?, When Did Each Ring Grow?, Are the Counts Right?, What Is Each Tree Doing?, How Good Is the Record?, Solid for What?), each ending with a pointer to its part; Beside a Collection Nobody Built (`wa082`); Wrapping Up; five exercises that turn the simulation's dials; Further Reading. Six figures, black and white `theme_minimal`.

Simulation change for the chapter: `compete`, `compete.frac`, `compete.phi` in `R/sim-collection.R`. Half the trees get a slow log-scale wander in A (AR(1) at 0.97, then an 11-year running mean, sd 0.3), drawn last so the other seed-1 draws don't change, but widths and everything computed from them do. The numbers recorded under "Simulated collection, first version" below are from before this change. With it (seed 1): ModNegExp tracks the true A at median r 0.998 on open trees and 0.81 on competition trees (one core, SIM14B, falls back to a flat line); `xdate.report` still flags SIM03A at lag -1 before 1800, plus weak unplanted flags on SIM08B and SIM10A (gains .004 and .024); prewhitened rbar.bt 0.35 against a target of 0.4.

Findings the chapter uses (all computed inline):
- Raw widths hide the missing ring. SIM03A over 1725-1799 correlates at only about 0.2 with the raw master as dated, positive at every shift, and nothing stands out. After a 32-year spline and AR residuals (the chapter's `toWiggles`, close to `xdate.report`'s defaults) it is -0.28 as dated and 0.53 one year earlier.
- A stand-wide event looks like climate: the standard chronology drops from 1.05 to 0.81 across 1880 while the true climate barely moves.
- EPS tracks the squared correlation between the residual chronology and the true climate in 50-year windows, within 0.13.
- `wa082` looks a lot like the simulation without tuning: rbar.wt 0.59 vs 0.58, rbar.bt 0.35 vs 0.35, median AR1 0.75 vs 0.80.

For Andy to check:
- Voice: first draft of the opening chapter in the new spec. Opinion written for you: "the most useful equation in dendrochronology, and not because anybody fits it". Three "X, not Y" lines cut on 2026-10-17 at Andy's request (they read as the AI contrast tell).
- The between-tree rbar shortfall (0.35 against 0.4, and 0.36 without competition) is unexplained, and the chapter says so. Exercise 2 sends the reader after it. Worth running down before the chapter is final, since 09 relies on rbar behaving.
- `wa082` has no locally absent rings (its one zero is the 1900 gap); the chapter uses `co021`'s 716 zeros for that point.
- Climate part not promised: the Solid for What? section points to Trees and Disturbance and Time Series only. Add a pointer if the Climate part goes ahead.
- Pointers to 03, 04, 05, 08, 09, 10, 11, 13, 15 all resolve. 04 and 08 still carry "moved here from A First Pass" notes at the top, which are still true.

### Reference notes on the Cook Book, 2026-10-17

`workspace/references/notes/CookBook.md` (outside this repo) has section-by-section notes on Cook and Kairiukstis (1990) with page numbers, an index by this book's chapters, and what each section means for dplR. Chapters 3, 4 and parts of 5 read closely; 1 and 2.1 and 2.3 lightly; 6 skipped. `CookBook.txt` beside it is the OCR text, for searching.

What it settled or found for this book:
- 09: effective rbar is Briffa and Jones (1990) eq. 3.43, p. 143, the formula `rwi.stats` uses. Settles that flag. The "0.85 isn't a threshold" sentence is supported at second hand (Briffa and Jones p. 147 and 151); Wigley et al. (1984) itself still unread.
- 02: "20 trees, 2 cores each" is the sampling recommendation in Schweingruber, Kairiukstis and Shiyatov (Cook Book 2.1, p. 27). Cite it.
- 05 to 07: Pilcher (2.3, p. 40-47) has Douglass on personal judgment, the 40-year minimum for crossdating short series with a split-the-series test, decade errors, and the computer as a substitute for skill. Robinson (1.1, p. 5) has the HH-39 story for 07 Floaters. Huber's Gleichläufigkeit (1.3, p. 12) for 05x.
- 08: the %n criterion (67-75% of n) is Cook (1985) via p. 114, the source of `Spline`'s default. Cook and Briffa's comparison (3.7) is a model for redoing a method comparison on `co021` and `wa082`. Their conclusion "never use any tree-ring standardization method or computer program as a black box" (p. 161).
- 10: ARSTAN's two-stage procedure and pooled AR (p. 129-132) support the 1.8.1 `chron.ars` fix. 3.5 (p. 136-137) warns that variance correction masks the loss of precision in thin early years; worth a line in the variance section.
- 11: the stand-level growth curve (RCS in all but name) was dismissed for climate work here (p. 120).
- Climate part: chapter 4 defines RE (eq. 4.39, p. 181) but not CE, which needs another source. 5.6 (Briffa and Cook) on response functions, including Cropper (1982) using simulated data with known climate to show misleading results, a precedent for the planned check.
- 16: `pointer` uses the Becker algorithm (per `man/pointer.Rd`), not Schweingruber's visual method in 5.10.

### Simulated collection, first version 2026-10-15 (uncommitted)

Decided 2026-10-15: the simulation lives in the book for now and may move to dplR as `sim.rwl` later. It is in `R/sim-collection.R`, and chapters load it with `source("R/sim-collection.R")` and `sim.collection(seed = 1)`. It returns `rwl` (with the planted errors), `ids`, and `truth` (error-free widths, climate, age trends, memory and noise, disturbance, the release, the event and the trees it hit, the errors, pith years, parameters). Base R only.

What it builds: 20 trees with 2 cores each, cored in 2025. Tree 1 is the oldest; ages run 120 to 380 on a square spacing, so old trees are few. Depth with seed 1 is 4 cores in 1700, 14 in 1800, 32 in 1900 and 40 in 2000. Log width is the sum of the aggregate-model terms. The age trend comes from a stem that lays down a constant basal area each year after a juvenile ramp. Climate is white noise unless you pass a series. Tree and core noise are sized so prewhitened rbar.bt and rbar.wt hit targets (0.4, 0.6). An AR(1) with phi 0.5 carries memory. There is a release in tree 10 in 1950, a stand event in 1880 that hits half the standing trees, and a missing ring in SIM03A at 1800. Widths are rounded to 0.01 mm.

Checked with seed 1 on dplR 1.8.1 dev:
- `xdate.report` flags SIM03A B at lag -1 in 1725-1774 and 1750-1799 (gains .93 and .88) and A in 1775-1824, which is the missing ring. It also gives two weak B flags that nobody planted: SIM08B 1825-1874 (lag 7, gain .015) and SIM10A 1900-1949 (lag -9, gain .031). That is material for the false-alarm discussion in 06FixingErrors. Series intercorrelation is 0.596, close to sqrt(rbar times EPS), the approximation in 09.
- `detrend(method = "Spline")` then `rwi.stats`: rbar.bt 0.364 and rbar.wt 0.577 prewhitened, a little under the targets. The likely causes are the spline taking some climate variance and the AR fit, but nobody has tested that yet.
- The standard chronology correlates with the true climate at r = 0.795 since 1800. The residual chronology reaches r = 0.944, because memory smears the climate and prewhitening takes the smear out. That holds only because the simulated climate is white.
- The 1880 event shows: standard chronology mean 1.069 for 1875-1879 and 0.856 for 1880-1889.
- Circularity is not answered. `ModNegExp` follows the constant-BAI age trend at r = 0.999 for SIM05A. If the book wants an age trend no method assumes, it needs a different curve (a wandering competition term, say). Undecided.

Checked 2026-10-17 against Cook's aggregate-model chapter (Cook 1990, Cook Book p. 98-104), now in `dplR.bib` as `Cook1990model` (`Cook1990` stays the standardization chapter, p. 104-123). The terms match. Three departures, now stated in the script's header: a tree-level noise term T split out of Cook's E; the stand event hits half the trees where Cook's D2 is synchronous in all of them (`event$frac = 1` gives Cook's version); disturbance pulses are added after the AR filter rather than passed through it as innovations (Cook p. 130-131; intervention detection's innovational outlier, Cook Book 5.8). Cook's own answer to circularity is that in closed canopies A is a stochastic process with no predictable shape (p. 100): a wandering competition term for some trees would follow him. The dissertation (`cook1985`) is not yet checked. False rings work (`type = "false"` splits a ring 40:60): a false ring planted in SIM06B at 1900 flags B at lag +1 in every segment from 1775 to 1899, the segment across 1900 reads "weak at every lag", and rings after 1900 are untouched. The simulation has no locally absent rings, measurement error or partial rings, which is the "too clean" con. Chapter 2 will set it beside `wa082` for that.

### Structure, done 2026-10-13 (file numbers here are the old ones)

- "Standardization and Chronologies" is now 05 Detrending, 06 Chronology Statistics, 07 Chronologies. Regional Curves (08) and Signal-Free (09) are their own part, "Regional Curves and Signal-Free".
- New part "Trees and Disturbance" after Time Series: 15 Basal Area, 16 Events. The part names are placeholders; change them in `_quarto.yml`.
- Files renumbered with `git mv`: Crossdating is 10 to 12 (asides 10x, 12x), Smoothing and Filtering is 13, Memory and Cycles is 14, Basal Area is 15. 01 to 09 and 16 to 18 kept their numbers.
- `treeMean` is out of 06 and belongs in "Trees and Disturbance". Undecided: a section of Basal Area, or a short chapter of its own on tree-level series.

### Structure suggestions, undecided

- Trim the time series chapters (13, 14) against the time series book. Keep what is specific to tree rings (the spline and its frequency response, the residual chronology, `redfit`, wavelets) and point to that book for the rest.
- Done 2026-10-15, see above. Kept for the reasoning: move the Crossdating part to right after Ring Widths (proposed 2026-10-13, Andy agreed to do it next session). Old file numbers in this item. The crossdating chapters (10 to 12x) don't refer to detrending, `rwi`, rbar, EPS, splines or prewhitening anywhere; only the empty 12xAsideCrossdatingStats plans to explain the spline and prewhitening, and that aside is the place for the one paragraph on what `corr.rwl.seg` does to a series first. Crossdating also sets up 06: correlations between series come before running rbar and EPS. Work: reorder the parts in `_quarto.yml`; renumber with `git mv` (crossdating files become 05 to 07 with asides 05x and 07x, standardization and later shift up, check the whole list against `_quarto.yml`); rename the matching `_freeze` folders or let them rebuild; fix cross-links (`grep -n "\.qmd)"` over the chapters, and the file numbers named in this backlog); cut the order-explaining paragraph from the Preface; change the Checking a Collection Wrapping Up pointer to "the next chapter"; A First Pass can say crossdating is the next part.
- Andy's idea, 2026-10-13, decided 2026-10-15 (see above): an early concepts chapter (Getting Going). Andy's framing: root it in how a new dendro thinks about a collection, someone just back from coring 20 trees, 2 cores per tree, asking how to make a solid tree-ring record. Concepts arrive in the order that person meets them, each step ending with a pointer to its part of the book:
  1. What do I have? 40 series, 20 trees; IDs carry the structure; two cores from one tree should agree more than two trees. (series vs trees, `read.ids`)
  2. When did each ring grow? Outer ring is the coring year for a living tree; every year is a count, a hypothesis until cores agree. (data in time, dated vs floating)
  3. Are the counts right? A missing or false ring shifts everything before it; compare patterns across cores and trees, after taking out each tree's slow trend and memory. First appearance of splines and prewhitening, as dating tools. (common signal, filtering, autocorrelation)
  4. What is each tree doing? Age trend, releases; detrending decides what to keep. The same spline from the other side. (splines as filters)
  5. How good is the record? 20 trees today, a handful in 1750. (sample depth, a first look at rbar and EPS)
  6. Solid for what? Climate wants the shared signal, ecology wants the differences. (`treeMean`, Trees and Disturbance)
  After the crossdating reorder, the parts of the book follow these steps in order. Andy, 2026-10-13: A First Pass likely folds into this framework, so this chapter replaces it rather than sitting beside it. Its code walk-through (read, plot, detrend, `chron` on `ca533`) becomes the code that goes with the steps, on the book's own data. Data: a simulated collection (Andy is attracted to it, 2026-10-13; see "Simulated collection and the climate thread" below). Would take material from 13 Smoothing and Filtering. Risk: abstractions before the reader has done anything, which the 20-tree framing mostly answers.

### Simulated collection and the climate thread (discussed 2026-10-13, Andy: "a solid idea")

Not started. Read this as one plan with the concepts chapter above and the crossdating reorder.

The idea. Simulate the 20-tree, 2-core collection, and build it as Cook's linear aggregate model: ring width = age trend × shared climate × local disturbance × noise. Writing the simulation teaches the model the whole book rests on: crossdating finds the climate term, detrending takes out the age term, ecology wants the disturbance term. Plant known things (a release in one tree, a missing ring in one core, a climate series with a known signal strength) so each method can be checked against the truth.

Why simulated data are so nifty (Andy, 2026-10-13, keep this framing in the book): we know what the answer is, and we are eager to retrieve it. The pleasure is in the recovery. Every method becomes a small experiment: here is what we put in, did we get it back, and if not, what got lost and why? The text should carry that eagerness, not treat simulation as a dry check.

The aggregate model gets an explicit treatment (Andy, 2026-10-13). Ring width as the sum (or, on the log scale, the product) of an age trend, a climate signal shared by the stand, endogenous disturbance in one tree, exogenous disturbance across the stand, and error, following Cook (1985 dissertation; Cook 1990 in Cook and Kairiukstis). Not only a recipe for the simulation: name each term, say which part of the book goes after which term, and come back to it in later chapters ("detrending is an estimate of the age term", "the chronology is an estimate of the climate term", "events are the disturbance terms"). Placement open: a section of chapter 2, which builds the simulation from it, or an aside of its own hanging off chapter 2. Check the exact form and terms against Cook's text before writing, and add the 1985 dissertation to `dplR.bib` if it is not there.

Pros: known truth at every step, which is the spec's plant-a-signal rule applied to a whole chapter; exactly the shape wanted (20 trees, 2 cores, depth falling back in time); readers can turn the dials (weaker signal, more autocorrelation, fewer old trees) for exercises; no provenance, permissions or unchecked data claims.

Cons and how to handle them:
- Too clean. Real wood has partial and locally absent rings, measurement error, variance that changes with width. The concepts chapter ends by setting `wa082` beside the simulation and showing what the real collection has that the model left out.
- Circularity. If the age trend is simulated as a negative exponential, `ModNegExp` recovers it almost perfectly and proves little. Say so, or simulate age trends that no standard detrending method assumes.
- No place or story. Real collections have Mesa Verde and Campito; the simulation has nothing to look at.
- A third collection dilutes the 2026-10-06 decision (same trees throughout, so attention goes to the method). Keep the simulation as a recurring check, not a running dataset.
- Code to maintain: fixed seed, readable. dplR has no simulation function. Open question: a `sim.rwl` in dplR (useful for teaching, testing and the apps) or code that lives in the book. Not while 1.8.1 is still open, at least.

Checked 2026-10-13: `wa082` is 23 series from 12 trees, 11 of them with two cores, nearly the 20-tree, 2-core shape. `co021` is 35 series from about 11 trees with one to four cores each, a grouping `autoread.ids` infers with a warning (A2 already says it is evidence, not proof). So `wa082` is the real collection to set beside the simulation.

Real data stays the backbone (Andy, 2026-10-13: the book does not drop real data). Three kinds of data, three jobs:
- Simulated: what a method does, against a known answer. The concepts chapter, reconstruction, and short checks elsewhere ("here is what this detrending does to a series whose trend we know").
- Real with planted problems: the wood is real and you know where you broke it. Crossdating already does this with `co021`. Probably covers more of the book than pure simulation.
- Real as it comes: reading and checking files (the `-999` gap in `wa082`), deciding without a true answer (09's "I don't know" about rbar after 1833), finding what nobody planted (the `chron.ars` defect showed up at Hurricane Ridge), credibility with dendro readers, and the reader's own next collection, which will look like `wa082`.
Pattern for many chapters: the method on data with a known answer, then on Mesa Verde and Hurricane Ridge where nobody knows it.

The climate gap. The book stops at the chronology. Climate appears only in passing (09 warns that EPS is not a climate signal, 10 says the functions don't know what a chronology is for, the 18Conclusion stub lists "climate response"). dplR has no climate-growth or calibration functions, so this leans on `treeclim` (Zang and Biondi) and base R; neither `treeclim` nor `dendroTools` is installed here yet. Proposed: a part on climate, parallel to Trees and Disturbance, so the book ends on the two uses of a record from step 6 of the concepts chapter. Placed after the chronology chapters and Time Series (it uses memory and spectra). Tree-ring-specific content only, pointing to the time series book for regression with autocorrelated errors and forecasting:
- Climate and growth: correlation and response functions over monthly windows, choosing a season, moving windows for stability, the false positives from screening many months.
- Reconstruction: calibration and verification split, RE and CE (by hand, a few lines), variance lost in regression.
- Back to 10: the test of chronology choices (standard vs residual vs ARSTAN, EPS cutoff, stabilization) that 10 keeps deferring to "what the chronology is for".

Why the simulation carries into it: with a known climate series, reconstruction can show true skill against what RE and CE report, how much low-frequency variation detrending removes (simulate centennial swings to show the segment length curse), and what screening many months does to apparent skill. The simulated collection then runs from the coring trip to a reconstruction.

Before writing: get climate data (PRISM monthly from 1895 covers both US sites; ship it or fetch at build time) and compute whether `co021` and `wa082` have a usable climate signal. Don't assume either does; a weak or absent one could be a lesson. Cost: at least one more part on top of the rewrite and the 2027 promises. Also reopens whether dplR should have calibration and verification helpers.
- Superseded 2026-10-15 by the reorder; the Preface paragraph is cut and the other two now point forward to the next part. Old text: Crossdating comes after standardization, so the book's order differs from the order of a project. Done 2026-10-13: a paragraph each in the Preface, A First Pass and Checking a Collection (Wrapping Up) says dating comes first in practice and points to 10Crossdating. Check the reason the Preface gives for the order (dplR's crossdating tools prewhiten and use a biweight master, so they lean on the standardization chapters). That reason is mine, and you may have had another one. Keep these paragraphs when those chapters are rewritten.

### Proposed structure (2026-10-13, for next session)

Puts together the crossdating reorder, the concepts chapter and the climate part above. The crossdating reorder is done (2026-10-15), so 1 to 14 below match the files. Chapter 2 and the Climate part are not started; adding 15 and 16 would renumber Basal Area, Events, dplPy and Conclusion to 17 to 20. "Status" is the files as of 2026-10-13. Three new chapters (2 replaces A First Pass, 15 and 16 are added), so 18 chapters become 20.

| # | Chapter | Data | Status |
|---|---|---|---|
| | Preface | none | 2022 text plus the dating-first paragraph, which the reorder removes |
| **Foundations** (was Getting Going, renamed 2026-10-19) ||||
| 1 | Welcome | none | 2022 text |
| 1x | Aside: Name Conflicts | none | carried over |
| 2 | From Cores to a Record (new, replaces A First Pass) | simulated 20 trees × 2 cores, ending beside `wa082` | not started |
| **Ring Widths** ||||
| 3 | Reading and Writing | `co021.rwl`, `wa082.rwl` in `data/` | stub |
| 3x | Aside: Tucson Format | deliberately broken file, still to make | stub |
| 4 | Checking a Collection | `co021`, `wa082` (switch from `ca533`) | partly written |
| 4x | Aside: Classes and Generics | any | stub |
| **Crossdating** (moved up) ||||
| 5 | Crossdating a Collection | `co021` with planted errors | 2022 text, works |
| 5x | Aside: Sign Agreement | `co021` | stub |
| 6 | Fixing Errors | `co021` with planted errors | stub |
| 7 | Floaters | `co021` with a floating series | stub |
| 7x | Aside: Crossdating Statistics | `co021`; simulation for why series are prewhitened | stub |
| **Standardization and Chronologies** ||||
| 8 | Detrending | `co021`, `wa082` (switch from `ca533`); simulated age trends as a check | partly written |
| 9 | Chronology Statistics | `co021`, `wa082` | first full draft |
| 10 | Chronology Building | `co021`, `wa082` | first full draft |
| **Regional Curves and Signal-Free** ||||
| 11 | Regional Curves | `gp.rwl`; simulation for the segment length curse | stub |
| 12 | Signal-Free | simulation and a real collection (see below) | 2024 text on `ca533`, 9 chunks fail |
| **Time Series** ||||
| 13 | Smoothing and Filtering | `co021` | carried over, to trim |
| 14 | Memory and Cycles | `co021` | carried over; possible home for `kalman.ar` |
| **Climate** (new part, name a placeholder) ||||
| 15 | Climate and Growth (new) | `co021`, `wa082` + PRISM monthly; simulated climate as a check | not started |
| 16 | Reconstruction (new) | simulated collection with known climate, plus whichever real collection has a usable signal | not started |
| **Trees and Disturbance** ||||
| 17 | Basal Area | `gp.rwl` | stub |
| 18 | Events | `cana157` | stub |
| **Wrapping Up** ||||
| 19 | dplPy | likely `co021`, `wa082` | stub |
| 20 | Conclusion | none | stub |
| A1–A3 | Packages, Data Sources, Acknowledgements | `co021`, `wa082` files | A2 partly written |
| new | Quick Reference (decided 2026-10-15) | none, or `co021` | not started |

Notes:
- Simulation is the running thread only in 2 and 16. In 7x, 8, 11, 12 and 15 it is a short check against a known answer, then back to real data.
- Signal-free (Andy, 2026-10-13, from the ssf work): wants a simulation as well as a real data set. The simulation shows whether the method recovers a known common signal and what it does to trend distortion; the real collection shows it on wood. Which real collection is open: `ca533` (what the chapter uses now), or `co021`/`wa082` to stay with the running data. Check whether the method needs very long series before switching.
- Climate could be one chapter instead of two. Split because they ask different questions: what do the trees respond to, and how well do they stand in for the climate.
- Crossdating chapters could share their example with xDateR, which uses `co021` with planted errors (ABC118, ABC104, floater ABC110). Check the app's files before relying on that.
- Open: whether `co021` or `wa082` has a usable climate signal (decides 15 and 16); where `treeMean` lands (Basal Area or its own short chapter); the part names.
- Only 9 and 10 are full drafts, so renumbering now costs little. After the reorder, A2DataSources needs a short note on the simulated collection and on the climate data.

### Open decisions

- dplR version in CI. Decided 2026-10-13: dplR 1.8.1 goes to CRAN only after the rewrite is done, since more dplR changes are expected (signal-free especially). Until then `DESCRIPTION` has `OpenDendro/dplR` under `Remotes:`, so CI builds on dplR's master and dplR changes must be pushed before the chapters that need them. When 1.8.1 is on CRAN: take the remote out, and check that `A1PackagesUsed.qmd` (the setup section, moved from the old Welcome), which tells readers to `install.packages("dplR")`, needs no note about the dev version.
- Deployment. The workflow in `.github/workflows/publish.yml` deploys with GitHub Actions and `docs/` is gitignored but still tracked. Before pushing: switch Pages to "workflow" and run `git rm -r --cached docs`. Until both are done the old bookdown site stays live.
- Cover page: first version 2026-10-13, same layout as the time series book. `assets/cover-art.R` draws the art from `co021` into `assets/cover-art.svg`, which `index.qmd` reads at render time.
- `LICENSE.md`, `CITATION.cff`, `.zenodo.json`: drafted 2026-10-13 on the pattern of the time series and spatial books (CC BY-NC-SA 4.0 for prose and figures, MIT for code). `LICENSE.md` says the data in `data/` and in dplR keep their sources' terms. Still to add once they exist: `url` (the site address) and `doi` and `date-released` in `CITATION.cff`. The README has no license section yet and is still the 2022 text.
- Favicon: not started.
- The 54 chunks that were unnamed in the 2022 chapters are still unlabeled.
- Whether to split the chapter skeleton and code conventions out of the writing spec into a `CRC-POLISH.md`, as in the other books.

### Suggested next step

The crossdating reorder is done (2026-10-15), and chapter 2 is decided (concepts chapter plus a quick-reference appendix). Next, settle the rest of "Simulated collection and the climate thread": where the simulation code lives (book or a `sim.rwl` in dplR), Cook's model checked against his text, and whether to add a climate part (check `co021` and `wa082` against PRISM first). Those decide the book's shape, so they come before more chapter drafting.

Chronology Statistics (09) and Chronology Building (10) have first full drafts (2026-10-13). Read them against the spec and decide whether they are the template. Then 08 Detrending, which both lean on and which is still the 2022 text on `ca533`.

Before either goes to CI: 10 needs 1.8.1 dev, which CI installs from GitHub (see "Open decisions"). The dplR changes were committed and pushed by 2026-10-15. Neither chapter has been rendered as part of the whole book, only alone.

### 10 Chronology Building, for Andy to check

- Detrending is `Spline` with defaults on both collections, as decided 2026-10-13. The stripping section is as you wrote it except for `wa082RWI` renamed `wa082Rwi`, the sentence about the age-dependent spline (now the default spline, two thirds of series length), and a link to 09. With `Spline` indices `strip.rwl` removes 6 of the 23 series and one whole tree, so the inline numbers in that section have changed from the `AgeDepSpline` version.
- ARSTAN chronology at Hurricane Ridge. `chron.ars` gave a negative lag-one autocorrelation there (-0.15) because it added the pooled model to the individually whitened series and skipped the second whitening. Fixed in dplR 1.8.1 dev on 2026-10-13 (pushed by 2026-10-15): `ars` is now `res` with the pooled model put back, as the help page and ARSTAN_49v1b.f have it. The chapter's paragraph is rewritten for the new numbers and carries a version note. iDetrend also calls `chron.ars`, so its ARSTAN chronology changes with 1.8.1.
- `chron(prewhiten = TRUE)` gives a residual chronology with lag-one autocorrelation of -0.23 at `wa082`. The chapter says so, against the old line that the residual chronology is white noise.
- Opinions written for you: "I use SSS" over a depth cutoff; "I detrend the whole series and cut afterward" (the 2022 text leaned the other way, cut the widths and then detrend); "Use the trees" for `chron.ci`.
- The 2022 remark that uncertainty grows toward the end of the chronology is gone. It came from `AgeDepSpline`: the mean standard error across series in 1950 to 1983 is 0.146 with it and 0.059 with `Spline`.
- `treeMean()` returned class `rwl` when given class `rwi`. Fixed in dplR 1.8.1 dev on 2026-10-13 (pushed by 2026-10-15), and the chapter calls it without `as.rwi()`, so this is one more thing in 10 that needs dev dplR.
- Variance section, rewritten 2026-10-13 as "Variance, Sample Depth and Agreement". Depth alone explains only the first half century at `wa082`; the 1800 to 1850 block is as variable as 1700 to 1750 because rbar is 0.44 there against 0.23 after 1950. Depth, block rbar and series spread together predict the observed standard deviation within about 0.02 in every block. The section shows a depth-only adjustment by hand next to `chron.stabilized`, which also scales for running rbar. Check two things written for you: that Frank et al. (2006) treat changes in rbar as an artifact (taken from the dplR help page, not reread in the paper), and the paragraph saying higher agreement at constant series spread can be a stronger shared signal, so scaling it away is a judgment call.
- Not in the chapter: dplPy treats stabilization as a step applied to any finished chronology, where dplR's function builds one from indices. That was a note for this section and belongs in 17DplPy if anywhere.
- Dropped from the 2022 chapter: the hand-rolled standard error ribbon, the `tidyverse` code, the spaghetti plot and "Go foRth!".
- Needs dev dplR 1.8.1 (`strip.rwl` with `nyrs`, indices and the `dplR.strip` attribute). `_freeze/10Chronologies` was rendered against it.

### 09 Chronology Statistics, for Andy to check

- Detrending. Both collections use `detrend(method = "Spline")` with defaults, to match A2DataSources. This was not decided, only defaulted. Changing it is one line in `stats-setup`, and the prose numbers are inline so they follow.
- First-person statements written for you: "The rule I follow is to compute the statistics on the indices that go into the chronology I am going to use" (prewhiten for a residual chronology, not for a standard one), and "I don't know" why rbar falls at Hurricane Ridge after the 1833 window. Keep, change or cut.
- "Wigley and colleagues did not hand it down as a threshold." Written from the dplR help page for `sss` and from memory of Buras (2017), not from rereading Wigley et al. (1984). Check the wording against the paper.
- The effective rbar is cited to Briffa and Jones (1990). Confirm that is the right source for the formula `rwi.stats` uses.
- The approximation for `interseries.cor` (square root of rbar times EPS of the other series) is my derivation for equally correlated series. It lands within 0.01 on both collections. Not from a paper.
- Plots are black and white `theme_minimal`, with line type and point shape in place of colour. No palette was chosen.
- `common.interval` is in an exercise only. `rwi.stats(co021Rwi, co021Ids, period = "common")` stops with "too few years with enough trees", which the exercise leads the reader to.
- Rendered against local dplR 1.8.1. Not run against CRAN 1.8.0, which is what CI installs. `_freeze/09ChronologyStats` (was 06) is tracked as of the 2026-10-13 commit.
- Finding worth knowing for 10: with `prewhiten = TRUE` the twentieth-century drop in running rbar at `wa082` is smaller and EPS stays above 0.87 in every full-depth window (last window rbar.eff 0.430, EPS 0.901).

### Outside this repo

- dplR 1.8.1 dev changes this book now depends on, all made 2026-10-13 and handed over for commit that day: `strip.rwl()` (the row-count fix, `nyrs`, stripping indices, the `dplR.strip` record), `chron.ars()` (ARSTAN chronology built from the residual chronology), and `treeMean()` (returns class `rwi` for indices). CRAN 1.8.0 has none of them, so 10 does not render on it. Committed and pushed to dplR master by 2026-10-15. The `chron()` help page also gained a caution about the residual chronology.
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
- `data/` holds `co021.rwl` and `wa082.rwl` as served by the ITRDB. Chapters 02, 04 and 08 still use `ca533` and need switching when they are rewritten.
- The "zip `data/` into the site" step is in `publish.yml` (2026-10-13, copied from the time series book), and A2DataSources links to `data.zip`. The link is relative and only works on the deployed site, since `data.zip` is made in CI. Check it after the first deploy.
- Still needed: a deliberately broken file for the Tucson aside; an entry for the two files in a permissions log if the book goes to a publisher.
- Rule adopted with this decision: don't describe what a dataset is good for without checking it against the data. Unchecked claims are listed in the callout at the top of A2DataSources.

## Coverage decisions (2026-10-06)

- `net` is left out of the book.
- `glk` and `sgc` get an aside (05xAsideSignAgreement).
- `sea` and `pointer` get a chapter (16Events).
- `treeMean` is framed the way it is used: ecological work on tree-to-tree differences.
- The smaller functions (`series.rwl.plot`, `skel.plot`, `xskel.plot`, `common.interval`, `read.crn`, `bakker`, `gini.coef`) go in only where they fit. Not if clunky.
- `kalman.ar` and `kalman.spec` (added to dplR dev 2026-10-07) go in the Time Series part: evolutive AR spectra by the Kalman filter, with `profile` for choosing `lambda`. They follow from the AR models and `redfit` in 14MemoryCycles, so that chapter is the likely home, or a chapter of their own after it. They exist only in dplR dev, so the book needs dev dplR in CI once they are used. Open questions on choosing the order and `lambda`, and the comparison with Ed Cook's programs, are in dplR's `TODO`; settle those before writing the section.
- Chronology Statistics now comes before Chronology Building, because the SSS cutoff, EPS stripping and variance stabilization depend on rbar, EPS and SSS.

## Planned revisions to carried-over chapters

- 05Crossdating: the chapter never mentions `xdate.report` or `write.xdate.report`.
- 13SmoothingFiltering: lead with `pass.filt` and fold the manual `signal` padding code.
## Known problems in carried-over chapters

- 10Chronologies: `strip.rwl()` stops with an error in CRAN dplR 1.8.0 and works in 1.8.1 dev. The stripping section was rewritten on 2026-10-13 around the dependence on detrending. It uses `nyrs`, stripping of indices and the `dplR.strip` attribute, all added to 1.8.1 dev that day (pushed by 2026-10-15), and its inline numbers stop the render without them. `error: true` is off. Install dev dplR before rendering; the rest of the chapter is still the old text.
- 12SignalFree: written against the 2024 output of `ssf(return.info = TRUE)`; nine chunks fail. The chapter has `error: true`.
- A3Acknowledgements fetches the author list from crandb at build time.
