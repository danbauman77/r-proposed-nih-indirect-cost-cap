# =============================================================================
# Analysis: Rerun FY 2024 NIH Indirect Cost Reimbursement w/ Proposed Cap
# =============================================================================


# -- Libraries

library(tidyverse)


# -- Config / Algebra

setwd("~/GitHub/r-proposed-nih-indirect-cost-cap")

API_KEY        <- ""
INPUT_FILE     <- "download/2025-01-28/RePORTER_PRJ_C_FY2024.csv"
REFERENCE_FILE <- "reference/NIH_ADMINISTERING_IC.csv"
OUTPUT_DIR     <- "output"
CAP_RATE       <- 0.15


# -- Shared Toolbox

ensure_dir <- function(path) {
  dir.create(path, showWarnings = FALSE, recursive = TRUE)
  path
}

read_source_csv <- function(path, na_strings = c("", "NA")) {
  read.csv(path, stringsAsFactors = FALSE, na.strings = na_strings)
}

write_output_csv <- function(df, path) {
  ensure_dir(dirname(path))
  write.csv(df, path, row.names = FALSE)
}


# -- Reference Data

ic_lookup        <- read_source_csv(REFERENCE_FILE)
ic_supercode_map <- setNames(ic_lookup$superCode, ic_lookup$CODE)


# -- Read CSV

df_raw <- read_source_csv(INPUT_FILE)


# -- Filtering Columns

df <- df_raw |>
  mutate(

    DIRECT_COST_AMT   = as.numeric(DIRECT_COST_AMT),

    INDIRECT_COST_AMT = as.numeric(INDIRECT_COST_AMT),

    PROPOSED_15PCT_CAP_INDIRECT_COST = DIRECT_COST_AMT * CAP_RATE,

    TRUE_FALSE_IS_INDIRECT_COST_LESS_THAN_CAP =
      !is.na(INDIRECT_COST_AMT) & (INDIRECT_COST_AMT > PROPOSED_15PCT_CAP_INDIRECT_COST),

    IF_RERUN_FY24_INDIRECT_COST_WITH_15PCT_CAP_COST =
      pmin(INDIRECT_COST_AMT, PROPOSED_15PCT_CAP_INDIRECT_COST, na.rm = FALSE),

    INDIRECT_COST_AMT_MORE_THAN_ZERO_DOLLARS =
      !is.na(INDIRECT_COST_AMT) & INDIRECT_COST_AMT > 0,

    NIH_ADMINISTERING_IC = ic_supercode_map[ADMINISTERING_IC]

  )


# -- Filters

df_filtered <- df |>
  filter(
    NIH_ADMINISTERING_IC == "NIH",
    is.na(SUBPROJECT_ID),
    INDIRECT_COST_AMT_MORE_THAN_ZERO_DOLLARS,
    !FUNDING_MECHANISM %in% c(
      "SBIR-STTR RPGS",
      "TRAINING, INDIVIDUAL",
      "TRAINING, INSTITUTIONAL",
      "SBIR/STTR CONTRACTS"
    )
  )


# -- Group by ORG_NAME

datawrapper_table <- df_filtered |>
  group_by(ORG_NAME) |>
  summarise(
    direct_cost_total        = sum(DIRECT_COST_AMT,                                  na.rm = TRUE),
    indirect_cost_total      = sum(INDIRECT_COST_AMT,                                na.rm = TRUE),
    indirect_15pct_cap_total = sum(IF_RERUN_FY24_INDIRECT_COST_WITH_15PCT_CAP_COST,  na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(
    cost_differential = indirect_15pct_cap_total - indirect_cost_total
  ) |>
  arrange(desc(indirect_cost_total))


# -- Output

#write_output_csv(datawrapper_table, file.path(OUTPUT_DIR, "nih_indirect_fy2024_summary.csv"))
