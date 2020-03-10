## Repository Structure

*The repository is structured as follows:*

- **\Data_Setup_March_CPS** – contains the do-file that constructs the final CPS data set (**marcps.dta**). It also contains some ancillary data sets used to construct this final data set, which are described below.
- **\Data_Setup_NSDUH** – contains the do-files that construct the appended raw NSDUH data set (**ALLYEARS12_1_10.dta**). It also contains the final NSDUH data set (**DRUGDATA_FINAL2.dta**).
- **\Figures** – contains the do-files and graph files for the figures in the paper.
- **\Raw_CPS_Data** – contains the original CPS .dat data set and do-file downloaded from IPUMS.
- **\Tables** – contains the do- and log files for the tables in the paper.
- **\Raw_NSDUH_1979-1999** – a zipped file that contains the raw NSDUH from 1979 to 1999.
- **\Raw_NSDUH_2000-2003** – a zipped file that contains the raw NSDUH from 2000 to 2003.
- **\Raw_NSDUH_2004-2006** – a zipped file that contains the raw NSDUH from 2004 to 2006.

## Data Set Construction

*The two main data sources are the March Current Population Survey (CPS) ASEC Supplement (downloaded from IPUMs), and data from the National Survey on Drug Use and Health (NSDUH).*

- **Final March CPS Data Set**
  - **marcps.dta** – the **make_marcps.do** constructs this final CPS data set. This do-file calls the following data sets:
    - **cps_00012.dat** – raw CPS data downloaded from IPUMs.
    - **DRUGDATA_FINALv2.dta** – contains state level data on industry, employer size, minimum wage, labor force statistics, and prison data. No do-file for this.
    - **msadtindex.dta** – MSA level drug testing index.
    - **statedtindex.dta** – State-level drug testing index, labor market, and prison data from 1980-2006.
    - **stempgrowth_dt.dta** – State level employment growth.
    - **cpiu2000.dta** – CPI-U-RS data from 1967-2010.
    
- **Final NSDUH Data Set**
  - **DRUGDATA_FINAL2.dta** - the do-file for constructing this data set is not included.
    - **sasYY.dta** – The raw NSDUH data from 1979-2006.
    - **appendallyears2.do** – Appends sasYY.dta files together while only pulling the relevant variables. Creates **ALLYEARS12_1_10.dta**. You will have to extract zipped folders before running this file.
    - **renamenoIR.do** – Converts the 2000-2006 variable names to lower case letters so they match the pre-2000 years. You will have to extract zipped folders before running this file.
    - **ALLYEARS12_1_10.dta** – The appended data set of raw NSDUH data.

## Tables Construction

- **Table 1.-Share of Establishments with a Drug Testing Program**
  - **Table1_1997-2006.do** – Uses **DRUGDATA_FINAL2.dta** to produce the rightmost column in Table 1. Data for the first and second column are from U.S. Department of Labor (1989) Tables 1 and 2, and Hartwell et. al (1996) Table 1, respectively.
- **Table 2.-Changes in Reported Employer Drug Testing in the NSDUH, 2002-03 to 2007-09**
  - **descrip.do** – Uses **marcps.dta** to produce Table 2.
- **Table 3.-Difference Between Nonusers and Users in High-Testing-Industry Employment Rates, by Time Period and Census Divisions Testing Intensity**
  - **Table3_divisions.do** – Uses **DRUGDATA_FINAL2.dta** to produce Table 3.
- **Table 4.-Impacts of Pro-Testing Legislation by Demographic Group**
  - **basic.do** – Uses **marcps.dta** to produce Table 4.
- **Table 5.-Impacts of Pro- and Anti-Testing Legislation by Demographic Group**
  - **basic.do** – Uses **marcps.dta** to produce Table 5.
- **Table 6.-Impacts of Pro- and Anti-Testing Legislation by Exclusive Demographic Groups**
  - **basic_exclusive.do** – Uses **marcps.dta** to produce Table 6.
- **Table 7.-Impacts of Pro-Testing Legislation by Metropolitan Area Drug-Testing Exposure**
  - **msa_exclusive_3yr.do** – Uses **marcps.dta** to produce Table 7.

## Appendix Tables Construction

- **Appendix Table A1: Employer Drug Testing Regulations and Prevalence by State**
  - **state_rest_rates_table.do** – Uses **statecode.dta** and **state_test_rates_NSDUH.txt** to produce columns 5-7 in Table A1.
    - **statecode.dta** – FIPS, Census, ICPSR, and Education Department codes for the 50 States and the District of Columbia.
    - **state_test_rates_NSDUH.txt** – State level data on share of NSDUH respondents reporting testing by their employer. These data were provided to the author as a special tabulation of the NSDUH, from the Office of Applied Studies at SAMHSA. They are not provided in this repository.
- **Appendix Table A2: Drug Use Rates by Group and Decade**
  - **appendix_table_a2.do** – Uses **DRUGDATA_FINAL2.dta** to produce Table A2.
- **Appendix Table A3: Changes in Reported Employer Drug Testing in the NSDUH, 2002-02 to 2007-09**
  - **ratechanges.do** – Uses **state_test_rates_NSDUH_9901.txt**, **state_test_rates_NSDUH_0203.txt**, and **state_test_rates_NSDUH_0709.txt**, and to produce Table A3. 
    - **state_test_rates_NSDUH_9901.txt** – State level data on share of NSDUH respondents reporting testing by their employer, from the SAMHSA, Office of Applied Studies, NSDUH over 1999-2001. These data are a special tabulation and are not provided.
    - **state_test_rates_NSDUH_0203.txt** – State level data on share of NSDUH respondents reporting testing by their employer, from the SAMHSA, Office of Applied Studies, NSDUH over 2002-2003. These data are a special tabulation and are not provided.
    - **state_test_rates_NSDUH_0709.txt** – State level data on share of NSDUH respondents reporting testing by their employer, from the SAMHSA, Office of Applied Studies, NSDUH over 2007-2009. These data are a special tabulation and are not provided.
- **Appendix Table A4: Comparison of pro-testing legislation impacts across models**
  - **specifications.do** – Uses **marcps.dta** to create Table A4.
- **Appendix Table A5: Robustness analysis using later sample periods**
  - **basic_exclusive1990.do** – Uses **marcps.dta** to create Table A5.
  
## Figures Construction

- **Figure 1 and 2**
  - **rawplots.do** – Use **marcps.dta** to produce graph files for Figure 1 and 2 and save them in the /Output folder.
    - **rawplots_year.gph** – Figure 1.
    - **rawplots_ttlaw_lowess1trim10.gph** – Figure 2(a).
    - **rawplots_ttlaw_lowess2trim10.gph** – Figure 2(b).
    - Additional figures are created by **rawplots.do** and are contained in the /Output folder. These figures do not appear in the published paper. The /Original_Graphs folder contains the origin published graphs in .gph format.
- **Figure 3**
  - **placebolaws.do** – Uses **marcps.dta** to produce the **placebo_results.dta** data set.
    - **test_placebo_graph.do** – Produces **placebograph.gph** – Figure 3.
