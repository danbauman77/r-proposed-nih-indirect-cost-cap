# NIH Indirect Cost Cap Analysis

R script to rerun FY 2024 NIH indirect cost reimbursements under a proposed 15-percent cap on indirect cost recovery rates.

## Install

1. Ensure R 4.1+ installed
2. Install dependencies:

```r
install.packages("tidyverse")
```

## Data

Download the NIH RePORTER project-level CSV for the target fiscal year from https://reporter.nih.gov and place it in `download/`.

A reference lookup file (`reference/NIH_ADMINISTERING_IC.csv`) maps administering IC codes to a supercode used to filter for NIH-administered awards.

## Configure

Edit the constants at the top of `code.R`:

```r
API_KEY        <- ""
INPUT_FILE     <- "download/2025-01-28/RePORTER_PRJ_C_FY2024.csv"
REFERENCE_FILE <- "reference/NIH_ADMINISTERING_IC.csv"
OUTPUT_DIR     <- "output"
CAP_RATE       <- 0.15
```

## Run

```r
source("code.R")
```

- Reads the RePORTER CSV and reference lookup
- Adds computed columns: proposed cap amount, boolean flags, IC mapping
- Filters to NIH-administered awards with indirect costs > $0, excluding SBIR/STTR and training programs
- Groups by institution, summarises direct/indirect/capped totals and the cost differential
- Output write is commented out by default; uncomment to save to `output/`

## Methodology

The Chronicle relied on data from NIH Reporter, which reflects the estimated indirect and direct costs of individual grants. Indirect cost-recovery rates are negotiated between institutions and NIH officials and are considered confidential information and unavailable for disclosure by the federal government. The indirect-cost rate is applied to the total direct costs associated with a particular NIH funding program. Direct costs "may include, but are not limited to, salaries, travel, equipment, and supplies directly supporting or benefiting the grant-supported project or activity." Costs for "common or joint objectives that cannot be readily identified with an individual project or program" are considered "indirect costs" -- and encompass spending on facilities operation and maintenance, depreciation, and administrative operations.

For example, consider the 58 percent rate negotiated by the Broad Institute and the federal government. If the direct costs associated with an NIH project amounted to $100,000, under the deal negotiated between the Broad Institute and NIH, the Broad Institute would be entitled to seek reimbursement up to $58,000 on any indirect costs associated with that project.

This analysis covers a single year, whereas NIH-funded grants and contracts typically run for longer periods. In addition, multiple years may pass before an institution or the federal government renegotiates indirect-cost recovery rates.

The Chronicle limited its analysis to funding programs administered by the NIH or its institutes, centers, or units. The Chronicle also limited its analysis to funding grants and contracts that reported at least $1 on indirect costs.

In calculating the potential cost-differential for fiscal year 2024, The Chronicle relied on the process below when deciding whether or not to include original indirect-cost amount(s) or amounts derived from the proposed 15-percent rate cap in relevant aggregate sums:

- When the original indirect-cost amount for a record was greater than the corresponding product of direct cost multiplied by 15 percent, The Chronicle included this 15-percent product towards the aggregate sum for an institution or state.
- When the original amount of a record was less than the 15-percent product, The Chronicle included the original amount towards the aggregate sum for an institution or state.

The Chronicle excluded SBIR/STTR programs from its analysis because direct and indirect cost amounts were not available for those programs.

The Chronicle also excluded funding targeted at training from this analysis. The federal government relies on a mandatory 8-percent cap on indirect costs for most federal training grants. Cost information for sub-projects was also excluded from the analysis.

### Acknowledgements
- Coded and debugged with the assistance of claude.ai
