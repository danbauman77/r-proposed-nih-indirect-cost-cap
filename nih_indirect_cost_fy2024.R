# =============================================================================
# Analysis: Rerun FY 2024 NIH Indirect Cost Reimbursement w/ Proposed 15-Percent Cap
# =============================================================================


# -- Libraries

library(tidyverse)



# -- Config

CSV_PATH          <- "download/2025-01-28/RePORTER_PRJ_C_FY2024.csv"

working_directory <- "~/GitHub/nih-indirect-cost-r"



ic_lookup        <- read.csv("reference/NIH_ADMINISTERING_IC.csv",
                             stringsAsFactors = FALSE,
                             na.strings       = c("", "NA"))

ic_supercode_map <- setNames(ic_lookup$superCode, ic_lookup$CODE)

setwd(working_directory)



# -- Read CSV

df_raw <- read.csv(
  CSV_PATH,
  stringsAsFactors = FALSE,
  na.strings        = c("", "NA")
)



# -- Add filtering columns

df <- df_raw |>
  mutate(
    
    DIRECT_COST_AMT   = as.numeric(DIRECT_COST_AMT),
    
    INDIRECT_COST_AMT = as.numeric(INDIRECT_COST_AMT),
    
    PROPOSED_15PCT_CAP_INDIRECT_COST = DIRECT_COST_AMT * 0.15,
    
    TRUE_FALSE_IS_INDIRECT_COST_LESS_THAN_CAP =
      !is.na(INDIRECT_COST_AMT) & (INDIRECT_COST_AMT > PROPOSED_15PCT_CAP_INDIRECT_COST),
    
    IF_RERUN_FY24_INDIRECT_COST_WITH_15PCT_CAP_COST =
      pmin(INDIRECT_COST_AMT, PROPOSED_15PCT_CAP_INDIRECT_COST, na.rm = FALSE),
    
    INDIRECT_COST_AMT_MORE_THAN_ZERO_DOLLARS =
      !is.na(INDIRECT_COST_AMT) & INDIRECT_COST_AMT > 0,
    
    NIH_ADMINISTERING_IC = ic_supercode_map[ADMINISTERING_IC]
    
  )



# -- Apply pivot-table filters

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




# -- Save outputs

# Pivot summary (one row per institution) [Uncomment to write]
#write.csv(datawrapper_table, "output/nih_indirect_fy2024_summary.csv", row.names = FALSE)