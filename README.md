# Store Reports

Store Reports is a free command-line program that fetches your apps' figures from the Apple App
Store and Google Play – downloads, crash and ANR rates, crash logs, error groups, performance,
ratings, chart positions and proceeds – for any number of customers and apps, and condenses them
into a management overview with a traffic light per app. No dashboard login, no manual export.

More: <https://christiandrapatz.de/report/>

## Requirements

- A Mac (Apple Silicon or Intel) or Windows 10/11 64-bit. No Python or other software needed.
- Apple: an App Store Connect **Team API key** (Key ID, Issuer ID, `.p8` file). `vendor_number`
  additionally enables sales and proceeds.
- Google: a **service account** JSON with access to your apps in Play Console. `reports_bucket`
  additionally enables install numbers and the full review history.

## Install

1. `git clone https://github.com/drapatzc/apireport.git` – or download the ZIP on GitHub.
2. Open the folder for your system:

   | Folder | System |
   |---|---|
   | `storereports-macos-arm64` | Mac with Apple Silicon (M1 or newer) |
   | `storereports-macos-x86_64` | Mac with Intel processor |
   | `storereports-windows-x86_64` | Windows 10/11, 64-bit |

   Only the folders present in the repository are available so far.
3. Copy `config.example.yaml` to `config.yaml` and enter your values (see below).
4. Put the Apple `.p8` key into `credentials/apple/` and the Google JSON into `credentials/google/`.
5. macOS only, if the first start is blocked: run `xattr -dr com.apple.quarantine .` once in that folder.

## Configuration

Customers are the top level; each customer has one Apple key and/or one Google service account
that applies to all their apps. Everything is enabled by default, so a minimal `config.yaml` is
short – `config.example.yaml` documents every option and every metric switch:

```yaml
general:
  output_directory: "./reports"
  default_days: 30

customers:
  - name: "My Company"
    apple:
      key_id: "ABC123DEFG"
      issuer_id: "00000000-0000-0000-0000-000000000000"
      private_key_file: "./credentials/apple/AuthKey_ABC123DEFG.p8"
      vendor_number: "12345678"
    google:
      service_account_file: "./credentials/google/service-account.json"
      reports_bucket: "pubsite_prod_rev_01234567890123456789"
    apps:
      - name: "My iOS App"
        platform: "apple"
        app_id: "1234567890"
        bundle_id: "com.example.app"
      - name: "My Android App"
        platform: "google"
        package_name: "com.example.app"
```

## Run

Double-click **`Store Reports starten.command`** (macOS) or **`Store Reports starten.bat`**
(Windows): the analysis runs and the overview opens in your browser. Or in the terminal
(`./storereports` on macOS, `storereports.exe` on Windows):

| Option | What it does |
|---|---|
| `--check` | Validate `config.yaml` and test every account, without downloading data. |
| `--list` | Show the configured customers and apps and exit. |
| `--days N` | Reporting period in days (default: `general.default_days`, 30). |
| `--customer NAME` | Only this customer (repeatable). |
| `--app NAME` | Only this app (repeatable). |
| `--platform apple` / `--platform google` | Only this store. |
| `--details` | Also print every single metric in the terminal. |
| `--open` | Open the overview in the browser afterwards. |
| `--config PATH` | Use another configuration file (default: `config.yaml` in the current folder or next to the program). |
| `--verbose` | Debug logging. |
| `--help` | All options. |

A failing metric (for example a missing permission) never stops the run; it is marked in the
report and everything else continues. `Ctrl+C` stops cleanly and still writes the reports
collected so far. Exit code `0` means all good, `1` something failed, `2` invalid configuration.

## Output

Everything is written to `reports/` next to `config.yaml`. Start with **`reports/overview.html`**:
the management table with a traffic light per app, grouped by customer, followed by one card per
app. Every app also gets `reports/<Customer>/<App>/<timestamp>/summary.html` with all details,
one CSV and JSON file per metric (for Excel), downloaded crash logs and stack traces in
`crashlogs/`, and Apple diagnostic logs in `diagnostics/`. `reports/management_summary.csv` holds
the overview for Excel; `reports/store_reports.sqlite` keeps the history of every run and feeds
the comparison with the previous run, the sparklines and the trend charts.

In the HTML reports, **proceeds, downloads and updates are masked (`********`)** until you click
**"Freischalten"** at the bottom of the page. The "Sales" section is always collapsed; all other
sections open automatically when they contain data.

## Traffic light

| Check | WARNUNG | KRITISCH |
|---|---|---|
| Crash rate, Apple (crashes per session) | ≥ 0.5 % | ≥ 1.0 % |
| Crash rate, Google (Google's bad-behavior threshold) | ≥ 0.545 % | ≥ 1.09 % |
| ANR rate, Google | ≥ 0.235 % | ≥ 0.47 % |
| Average rating (from 3 ratings) | < 4.0 | < 3.0 |
| TestFlight crash reports in the period | any | – |
| Unanswered reviews with 3 stars or less | ≥ 3 | – |
| A metric could not be fetched | yes | – |

Beyond the traffic light, every run compares itself with the previous one: the overview starts
with **"Was hat sich geändert"** (status changes, new versions, notable moves in downloads, crash
rate or ratings, new and resolved warnings), the management table shows an arrow and a sparkline
per metric, and each app gets a **Release-Radar** (share of sessions or users on the current
version, its crash rate against the previous version, a verdict such as *Stabil* or *Auffällig*)
and a **Reviews** block (response rate, unanswered reviews with 3 stars or less, most frequent words
in negative reviews). Charts are built in: downloads, crash rate and store rating per app in the
overview; star distribution, top countries, crashes and downloads per day and the trend per run in
each app report.

Notes: Apple delivers Analytics data 1–2 days after the first run; Google vitals arrive with a
1–2 day delay; Apple's production crash logs are not available via the API (full logs come from
TestFlight, counts and rates from Analytics).

© 2026 Christian Drapatz · <https://christiandrapatz.de> · <https://onetwoapps.com>
