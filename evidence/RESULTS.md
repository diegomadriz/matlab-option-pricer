# Project history, recorded runs and configuration

Project period: December 2025, with later fixes listed below. The original version is the
December 30, 2025 submission archive.
`submission-manifest.json` records its publishable files; the three numerical test
fixtures are extracted from that archive without changes. The report PDF and its
extracted figures retain the December evidence, with no saved price table, raw
samples or figure seed.

## Dated changes

- July 9, 2026: the Black-Scholes zero-maturity/zero-volatility deterministic payoff branch was added.
- October 3, 2026: the Pricer seed-field reference was fixed to `SeedEditField` in App Designer and re-saved an internally consistent app in R2026a Update 5. The hand-edited July app is excluded.
- October 3, 2026: publication work added standalone input guards, demo path/wording edits, tests, reproduction, evidence and CI. The edited MATLAB files are marked in place.

The app's stale December preview preceded its final strike default; it is not
current evidence. The publication app is the October re-save. The standalone
course demo uses strike 100; the Pricer configuration uses 102.

## App examples recorded on October 3, 2026

These are post-course MATLAB Online R2026a Update 5 (Linux) examples, not December
course results. Full inputs and displayed outputs are in `example-runs-2026.json`.

| Pricer run | Black-Scholes | Monte Carlo estimate | Standard error | Absolute gap / standard error |
| --- | ---: | ---: | ---: | ---: |
| Seed 42 | 9.423365 | 9.414263 | 0.062853 | 0.14 |
| Unseeded | 9.423365 | 9.466486 | 0.063158 | 0.68 |

The Simulator seed-42 run recorded terminal mean 105.082718 and sample standard
deviation 20.771853. Its screenshot is omitted because removing the tooltip strip
would cut the tabs. The clean unseeded Pricer screenshot is copied without editing.
Gaps use the six-decimal displayed results, not unsaved full-precision outputs.

`reproduce_example` follows the app's seeded Pricer calculation sequence.
`restore_archive` only copies December report images and the evidence index and exports the recorded
configuration. It does not regenerate the old random paths.

The earlier 11-test suite passed in MATLAB Online R2026a on October 3, 2026. CI now
runs the full 13-test suite on every push. MIT covers the whole repository, report
included. See `history.json` for verification and license provenance.

## Configuration

| Parameter | App Pricer defaults | Standalone demo |
| --- | ---: | ---: |
| Spot | 100 | 100 |
| Strike | 102 | 100 |
| Annual risk-free rate | 0.05 | 0.05 |
| Annual volatility | 0.2 | 0.2 |
| Maturity in years | 1 | 1 |
| Time steps | 252 | 252 |
| Pricing paths | 50,000 | 5,000 |
| Paths displayed | At most 30 | 20 |

Sources: `results.json`, the app's MATLAB code and `demo/demo_option_pricing.m`.
