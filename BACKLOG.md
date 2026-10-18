# Backlog

Working notes for the rewrite. Not part of the book.

## Start here (left open 2026-10-13)

State of the repo: the Quarto conversion, the restructure into parts, the stubs and the dataset work are on the `quarto-rewrite` branch. `main` is still the 2024 bookdown version. The folder moved from `workshopMaterials/dplR-workshop` to `openDendro/learningToLoveDplR`; the GitHub repo was renamed from `OpenDendro/dplR-workshop` to `OpenDendro/learningToLoveDplR` on 2026-10-13, and the old name no longer resolves. The writing spec is a local file and is not in the repo.

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
| **Getting Going** ||||
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

- dplR version in CI. Decided 2026-10-13: dplR 1.8.1 goes to CRAN only after the rewrite is done, since more dplR changes are expected (signal-free especially). Until then `DESCRIPTION` has `OpenDendro/dplR` under `Remotes:`, so CI builds on dplR's master and dplR changes must be pushed before the chapters that need them. When 1.8.1 is on CRAN: take the remote out, and check that `01Welcome.qmd`, which tells readers to `install.packages("dplR")`, needs no note about the dev version.
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
