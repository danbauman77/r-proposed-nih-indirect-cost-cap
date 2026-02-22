

# Analysis: Rerun FY 2024 NIH Indirect Cost Reimbursement w/ Proposed 15-Percent Cap

## -- Libraries
```   
library(tidyverse)
```   
## -- Config
```   
CSV_PATH \<- "download/2025-01-28/RePORTER_PRJ_C_FY2024.csv"
working_directory \<- "\~/GitHub/nih-indirect-cost-r"

setwd(working_directory)

ic_lookup \<- read.csv("reference/NIH_ADMINISTERING_IC.csv",
stringsAsFactors = FALSE, na.strings = c("", "NA")) ic_supercode_map \<-
setNames(ic_lookup$superCode, ic_lookup$CODE)
```   
## -- Read CSV
```   
df_raw \<- read.csv( CSV_PATH, stringsAsFactors = FALSE, na.strings =
c("", "NA") )
```   
## -- Add filtering columns

```         

df \<- df_raw \|\> mutate(
    
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

```

## -- Apply pivot-table filters
```   
df_filtered \<- df \|\> filter( NIH_ADMINISTERING_IC == "NIH",
is.na(SUBPROJECT_ID), INDIRECT_COST_AMT_MORE_THAN_ZERO_DOLLARS,
!FUNDING_MECHANISM %in% c( "SBIR-STTR RPGS", "TRAINING, INDIVIDUAL",
"TRAINING, INSTITUTIONAL", "SBIR/STTR CONTRACTS" ) )
```   
## -- Group by ORG_NAME
```   
datawrapper_table \<- df_filtered \|\> group_by(ORG_NAME) \|\>
summarise( direct_cost_total = sum(DIRECT_COST_AMT, na.rm = TRUE),
indirect_cost_total = sum(INDIRECT_COST_AMT, na.rm = TRUE),
indirect_15pct_cap_total =
sum(IF_RERUN_FY24_INDIRECT_COST_WITH_15PCT_CAP_COST, na.rm = TRUE),
.groups = "drop" ) \|\> mutate( cost_differential =
indirect_15pct_cap_total - indirect_cost_total ) \|\>
arrange(desc(indirect_cost_total))
```   
## -- Save outputs
```   
###Pivot summary (one row per institution) [Uncomment to write]
###write.csv(datawrapper_table, "output/nih_indirect_fy2024_summary.csv",
row.names = FALSE)
```

## -- Additional Methodological Notes

The Chronicle relied on data from NIH Reporter, which reflects the estimated indirect and direct costs of individual grants. Indirect cost-recovery rates are negotiated between institutions and NIH officials and are considered confidential information and unavailable for disclosure by the federal government. The indirect-cost rate is applied to the total direct costs associated with a particular NIH funding program. Direct costs “may include, but are not limited to, salaries, travel, equipment, and supplies directly supporting or benefiting the grant-supported project or activity.” Costs for “common or joint objectives that cannot be readily identified with an individual project or program” are considered “indirect costs” — and encompass spending on facilities operation and maintenance, depreciation, and administrative operations.

For example, consider the 58 percent rate negotiated by the Broad Institute and the federal government. If the direct costs associated with an NIH project amounted to $100,000, under the deal negotiated between the Broad Institute and NIH, the Broad Institute would be entitled to seek reimbursement up to $58,000 on any indirect costs associated with that project.

This analysis covers a single year, whereas NIH-funded grants and contracts typically run for longer periods. In addition, multiple years may pass before an institution or the federal government renegotiates indirect-cost recovery rates.

The Chronicle limited its analysis to funding programs administered by the NIH or its institutes, centers, or units. The Chronicle also limited its analysis to funding grants and contracts that reported at least $1 on indirect costs. 

In calculating the potential cost-differential for fiscal year 2024, The Chronicle relied on the process below when deciding whether or not to include original indirect-cost amount(s) or amounts derived from the proposed 15-percent rate cap in relevant aggregate sums …

• When the original indirect-cost amount for a record was greater than the corresponding product of direct cost multiplied by 15 percent, The Chronicle included this 15-percent product towards the aggregate sum for an institution or state; 

• When the original amount of a record was less than the 15-percent product, The Chronicle included the original amount towards the aggregate sum for an institution or state; 

The Chronicle excluded SBIR/STTR programs from its analysis because direct and indirect cost amounts were not available for those programs. 

The Chronicle also excluded funding targeted at training from this analysis. The federal government relies on a mandatory 8-percent cap on indirect costs for most federal training grants. Cost information for sub-projects was also excluded from the analysis. 
