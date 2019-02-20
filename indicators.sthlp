{smcl}
{* *! version 1.0 23 May 2018}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install gtsd" "ssc install gtsd"}{...}
{vieweralsosee "Help gtsd (if installed)" "help gtsd"}{...}
{vieweralsosee "Install dirstr" "ssc install dirstr"}{...}
{vieweralsosee "Help dirstr (if installed)" "help dirstr"}{...}
{vieweralsosee "Install datalibweb" "ssc install datalibweb"}{...}
{vieweralsosee "Help datalibweb (if installed)" "help datalibweb"}{...}
{vieweralsosee "Install primus" "ssc install primus"}{...}
{vieweralsosee "Help primus (if installed)" "help primus"}{...}
{viewerjumpto "Syntax" "indicators##syntax"}{...}
{viewerjumpto "Description" "indicators##description"}{...}
{viewerjumpto "Options" "indicators##options"}{...}
{viewerjumpto "Remarks" "indicators##remarks"}{...}
{viewerjumpto "Examples" "indicators##examples"}{...}
{title:Title}
{phang}
{bf:indicators} {hline 2} {err: help file in progress}

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:indicators}
{it:{help indicators##calcset:instruction}}
[{cmd:,}
{it:{help indicators##options:options}}]

{p 4 6 2}
Where {it:instruction} refers to a set of shorthands that indicate {cmd:indicators} 
what to do. See {help indicators##calcset:below} for further explanation.{p_end}

{marker sections}{...}
{title:sections}

{pstd}
Sections are presented under the following headings:

		{it:{help indicators##optable:Options at a glance}}
		{it:{help indicators##description:Description}}
		{it:{help indicators##fstructure:Folder Structure}}
		{it:{help indicators##calcset:Set of instructions}}
		{it:{help indicators##vc_vars:vc_* variables}}
		{it:{help indicators##options:Options}}
		{it:{help indicators##examples:Examples}}
		{it:{help indicators##files:Explanation of files}}
		{it:{help indicators##references:References}}
		
{marker optable}{...}
{title:Options at a glance}
{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt coun:tries(string)}} List of countries to use for calculations. You may  
use {it:countries(all)} to include all the countries.{p_end}
{synopt:{opt y:ears(numlist)}} List of year to use in calculations. {p_end}
{synopt:{opt newonly}} Perform calculations only in new data that has been added to 
the repository of GMD collection using {help datalibweb}{p_end}
{syntab:Repository}
{synopt:{opt repo:sitory(string)}} Name of repository. Default is {it:all_GMD}{p_end}
{synopt:{opt reporoot(string)}} Directory where repository is stored. Default is 
{browse \\wbgfscifs01\GTSD\02.core_team\02.data\01.Indicators:here}{p_end}
{synopt:{opt createrepo}} Necessary to create or update repository{p_end}
{synopt:{opt gpwg2}} Necessary to update GPWG2 independent repo file. Requires option 
{it:createrepo}{p_end}
{synopt:{opt repofromfile}} create repo_vc from existing repo_ file. Only works with option 
{it:createrepo}. {err: This is a temporary solution when datalibweb is not up to date}.{p_end}

{syntab:Load data}
{synopt:{opt load}} Loads the data file corresponding to {it:instruction}. 
See option {help indicators##vcdate:vcdate()} and more details 
{help indicators##load:here}.{p_end}
{synopt:{opt shape(string)}} Shape of the file corresponding to the set of calculations. 
It can be either wide or long. default is wide.{p_end}
{syntab:Debugging}
{synopt:{opt pause}} Activate strategic pause points along the {cmd:indicators} files 
for debugging purposes. see {help pause}{p_end}
{synopt:{opt noi}} Display some important information along the process{p_end}
{synopt:{opt trace(instruction)}} activate {cmd:set trace on} for the section of the 
process in which {it:instruction} is executed.{p_end}

{syntab:Advanced}
{synopt:{opt vcdate(string)}} Vintage control date. It works with set of indicators and 
repo files. It also works with options {it:load} and {it:restore}  {p_end}
{synopt:{opt restore}} Restore output files form any previous vintage.{p_end}

{syntab:Seldom used}
{synopt:{opt welfare:vars(string)}} set of welfare variables to use for calculations. 
Default is "welfare welfshprosperity welfareused welfarenom welfaredef welfareother 
pcexp pcinc"{p_end}
{synopt:{opt reg:ions(string)}} Perform calculations by countries of the same region.{p_end}
{synopt:{opt mod:ule(string)}} Perform calculations for a specific module of GMD{p_end}
{synopt:{opt plines(string)}} Poverty lines for poverty. Default is "1.9 3.2 5.5"{p_end}
{synopt:{opt cpivintage(string)}} Vintage of CPI. default is {help datalibweb}'s default.
type the whole vintage, including the "v" and the leading zeros (e.g., v03).{p_end}
{synopt:{opt type:s(string)}} Type of collection.{p_end}
{synopt:{opt veralt(string)}} Alternative version of data to be used in calculations{p_end}
{synopt:{opt vermast(string)}} Master version of the data to be used in calculations.{p_end}
{synopt:{opt filen:ames(string)}} Perform calculation for a specific file{p_end}
{synopt:{opt wbo:data(string)}} Set of indicators to be included in the wdi file. 
Default are NE.CON.PRVT.PC.KD; NY.GDP.PCAP.PP.CD; NY.GDP.PCAP.PP.KD; 
NY.GNP.PCAP.CD; NY.GNP.PCAP.KD; SI.POV.NAHC; SP.RUR.TOTL; SP.RUR.TOTL.ZS; 
SP.POP.TOTL; SI.POV.GINI. see {help wbopendata_indicators##indicators:list of indicators} {p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{cmd:indicators} is a Stata package that produces a set of well-structured files
with basic socioeconomic indicators used by the Global Team for Statistical 
Development (GTSD) of the World Bank. So far, the packages produces indicators for
poverty, inequality, shared prosperity, Key indicators, and information downloaded 
from WDI. The value added of the set of results produced by {cmd:indicators} is 
the wide variety of possible outcomes using the GMD collection through 
{help datalibweb}. For instance, in the case of poverty estimates, {cmd:indicators} 
calculates the headcount, gap, and severity FGT family metrics for three poverty lines 
(US $1.9, $3.2, $5.5 a day at 2011 PPP values), using all the welfare variables available 
in each file of the GMD collection. Note that this set of results is produced for 
every single file, including all versions of the same survey. Thus, this set of calculations 
provides the user with several advantages. [1] It is useful for replicability purposes 
of estimates done with old versions of the same survey. [2] It may be used as 
the unique repository of socioeconomic indicators that are used in different reports 
or projects. [3] It serves as historical record of socioeconomic indicators produced
with the GMD collection. [4] it can be accessed by a dummy-proof system that does not 
requires from the user any knowledge of directory paths or filenames. 

{marker fstructure}{...}
{title:Folder Structure}

{pstd}
{ul: main directory:} As of today (17jul2018), {cmd:indicators} stores its results in the folder 
{browse "\\wbgfscifs01\gtsd\02.core_team\02.data\01.Indicators"}. Hereafter, this 
folder is called the main directory. 

{pstd}
{ul: dta files:} within the main directory there are two types of .dta files 
and a set of sub-folders. Among the .dta files, there is a set of them that begin 
with the 'repo' prefix, which are used as 
input files that mainly contain the list of surveys used in the calculation of 
indicators. On the other hand, you may find those that begin by the prefix 
'indicators', which  are considered output files and contain information organized in
long or wide format (see options {it:load} and {it:shape(string)}). There is an 
additional file called {stata indicators report:indicators_reportfile.dta}, 
that contains a record of the successes and failures of the {cmd:indicators} 
process (see repo in the type 'auxiliary files' of instructions).

{pstd}
{ul: sub-folders:} The three sub-folder are '_aux', '_datasignature', and '_vintage'. 
[1] The '_aux' folder contains auxiliary information that is not part of the full system 
and might be eventually changed by something more efficient. For instance, as of now
this folder contains the file 'Datalib_all_DTAs_EUSILC.txt' that contains the inventory
of GPWG2 filenames (see option {it:gpwg2} for more information). [2] Folder '_datasignature'
contains the .dtasig file created by {cmd:indicators} with the signature stamp of 
every single dataset created in the {cmd:indicators} process. Each .dta file in the 
main directory has a unique data signature that is saved along with the file when 
this is created. If the data signature of each of the files is different from the 
previous version, {cmd:indicators} will create a new version of the fil. If the data
signature is the same, no new file is created. [3] Finally, '_vintage' folder has all the 
different versions of each file in the creation process. Each of the files within 
'_vintage' contains a suffix with the date and of it creation. The format of the
suffix is store in the format %tcDDmonCCYY_HH:MM:SS. For instance, to retrieve the creation
date of file indicators_pov_1847087877000.dta, you may do something like this: 

{p 8 10 2}. local filename indicators_pov_1847087877000.dta{p_end}
{p 8 10 2}. if regexm("`filename'", "([0-9]+)") local date = regexs(1){p_end}
{p 8 10 2}. disp %tcDDmonCCYY_HH:MM:SS `date'{p_end}

{marker calcset}{...}
{title:Set of Instructions}

{pstd}
The instruction indicates {cmd:indicators} what to do, whereas the options provided 
indicate how to do it. There are two types of instructions. [1] set of calculations, or
[2] auxiliary files. set of calculations the set of indicators to calculate
or update (apologies for redundancy). For ease of typing,  ahosrthand has been assigned 
to each set of calculations. 

		Instruction{col 35}Set of calculations
		{hline 45}
		{cmd:pov }{col 35}FGT family
		{cmd:ine }{col 35}Inequality indicators
		{cmd:shp }{col 35}Shared Prosperity
		{cmd:key }{col 35}Key Indicators
		{cmd:wdi }{col 35}WDI indicators
		{cmd:all }{col 35}All the above
		{hline 45}
		{cmd:    }{col 35}
		Instruction{col 35}auxiliary files
		{dup 45:-}
		{cmd:repo}{col 35}Repository
		{cmd:report}{col 35}Report file procedure
		{hline 45}

{dlgtab:Set of calculations}
{phang}
{opt pov} refers to the FGT family metrics of poverty. If option {it:load} is not 
provided, {cmd:indicators} will calculate the FGT family metrics for all the files 
available in {it:countries()} (or {it: region()}) and {it:year()}. To avoid accidental 
execution of calculation of indicators, there is no default country or region. if the 
user wants to execute all countries available, he may use option {it:countries(all)}. 
If option {it:load} if provided (i.e., {stata indicators pov, load}), 
{cmd:indicators} will load file {it:indicators_pov_wide.dta} unless option 
{it:shape(long)} is provided to load instead {it:indicators_pov_long.dta}.

{phang}
{opt ine} follows the same logic than instruction {it:pov} but instead of calculating 
the FGT family of poverty metrics it calculates the Gini and Theil. More Inequality 
indexes are planned to be added, but these two are the ones that are used in most of 
the projects. 

{phang}
{opt shp} calculates a set of statistics that are necessary for estimating shared prosperity indicators. 
The main statistics are [1] the mean welfare of the total population, [2] the mean welfare 
of the bottom 40, and [3] the mean welfare of the top 60. However, other statistics 
are calculated for the ease of the user. In the 
{stata indicators shp, load:indicators_shp_wide.dta} file, all the variables with the 
preffix 'values' correspond to the set of shared prosperity statistics. The user can 
remove the preffix by typing {stata rename values* *}. The result is:

		Var. name{col 35}Var. Label
		{hline 53}
		Smean{col 35}Sum of welfare of Tot. population
		Nmean{col 35}No. of obs in Tot. population
		mean {col 35}Mean welfare of Tot. population
		Sb40 {col 35}Sum of welfare of the Bottom 40
		Nb40 {col 35}No. of obs in the Bottom 40
		b40  {col 35}Mean welfare of Bottom 40
		Nt60 {col 35}No. of obs in the Top 60
		St60 {col 35}Sum of welfare of the Top 60
		t60  {col 35}Mean welfare of Top 60
		t10  {col 35}Mean welfare of the Top 10
		{hline 53}

{phang}
{opt key} refers to the key indicators used in the "Key Indicators" table of the PEB. 
This set of calculations is rarely used in other contexts besides the PEB. However, 
they might be useful in several instances. The variables with the preffix 'values' 
refer to a dichotomic division of the population based their position in the welfare 
distribution relative to a particular threshold (e.g., poor/non-poor). The user can 
remove the prefix by typing {stata rename values* v*}. The result is:

		Var. name{col 35}Var. Label
		{hline 45}
		v190p_{col 35}Poor at US $1.9 a day
		v190np{col 35}Non-poor at US $1.9 a day
		v320p_{col 35}Poor at US $3.2 a day
		v320np{col 35}Non-poor at US $3.2 a day
		v550p_{col 35}Poor at US $5.5 a day
		v550np{col 35}Non-poor at US $5.5 a day
		vB40__{col 35}Botton 40
		vT60__{col 35}Top 60
		{hline 45}

{pmore}
Note a couple of things. First, the suffix '_' is used for completion so 
that all the variable names have the length. Second, variable with 'p_' and 
'pn' suffix, as well as VB40__ and vT60__, complement each other. This redundancy 
of information is essential for the purposes of the PEB. 

{pmore}
variable {it:precase} refers to the breakdown of the population based on their 
demographic or geographic status. The values in variable {it:precase} are not evident 
because their shape has a specific intention in the PEB project. However, if they are 
requires in other poject, these are their corresponding meanings:

		Value{col 35}Meaning
		{hline 65}
		edu1{col 35}Without education (age 16 and older)
		edu2{col 35}Primary education (age 16 and older)
		edu3{col 35}Secondary education (age 16 and older)
		edu4{col 35}Tertiary/post-secondary education (age 16 and older)
		gag1{col 35}0 to 14 years old
		gag2{col 35}15 to 64 years old
		gag3{col 35}65 and older
		gen1{col 35}Females
		gen2{col 35}Males
		rur1{col 35}Urban population
		rur2{col 35}Rural population
		{hline 65}

{phang}
{opt all} does all the calculations above opening the GMD file only once. 

{dlgtab:Auxiliary files}

{phang}
{opt repo} creates or loads the repository files. Option {it:load} simply 
loads the main repository file into Stata, {stata indicators repo, load:repo_vc_all_GMD.dta}. 
Option {it:createrepo} creates or updates the current repository with all the GMD 
collection available in datalibweb. Note that wrk files are not included in {cmd:indicators}. 
The main repository file, {stata indicators repo, load:repo_vc_all_GMD.dta}, contains all 
the variables in the repository file created by datalibweb with two more additions. First, 
it includes a set of variables with the prefix 'vc_' for vintage control of the different 
repositories that have been used. These variables contain three values with respect to 
the previous vc_ variable: 1 = same as before, 2 = new data, 3 = old data. If the user 
wants to do the calculation with new data only, he may use option {it:newonly} and 
the corresponding set of calculations in the instruction section. Second, some databases 
from the EUSILC collection that are not available through the regular repository of dataliweb 
are appended to the repository file created by datalibweb and then merged into the previous 
main repository file. This collection is named GPWG2 and its module is UDB-C. 

{phang}
{opt report} loads the report file, {stata indicators report:indicators_report.dta}, and 
display a couple of tables with some information. {err: this function is under development}. 

{marker options}{...}
{title:Options} {err:This section is in process}
{dlgtab:Main}
{phang}
{opt coun:tries(string)} Set of three-digit country codes using WDI standard. Note 
that, in contrast to {help datalibweb##param:datalibweb}'s option {it:country}, 
{cmd:indicators}' option {it:countries } accepts more than one country digit and 
shorthand like "all" to refer to a larger set of countries. 

{phang}
{opt y:ears(numlist)}  

{phang}
{opt newonly}  

{dlgtab:Repository}
{phang}
{opt repo:sitory(string)}  

{phang}
{opt reporoot(string)}  

{phang}
{opt createrepo}  

{phang}
{opt gpwg2}  

{marker load}{...}
{dlgtab:Load data}
{phang}
{opt load} This option allows the user to load any file created by {cmd:instructions}. 
The basic syntax is {cmd:indicators {it:instruction}, load}, where {it:instruction} refers 
to a set of {help indicators##calcset:calculations} or the repo file. By using option 
{it:shape()} the user may request the data in long format, as the default is wide format. 
In addition, the user may load any vintage version by using the option 
{help indicators##vcdate:{it:vcdate()}}. See this example {help indicators##loadex1:below}.

{phang}
{opt shape(string)}  

{dlgtab:Debugging}
{phang}
{opt pause}  

{phang}
{opt trace(string)}  

{phang}
{opt noi}  

{marker vcdate}{...}
{dlgtab:Advanced}
{phang}
{opt vcdate(string)} Select any vintage version of the data requested. There are 
two variations of this option [1] {cmd:vcdate}(pick) or {cmd:vcdate}(choose), in which
data displays all the versions available in the results window so that the user can click 
on the version desired. [2] {cmd:vcdate}({it:date}) in {it:date} could be entered in two ways, 
[2.1] %tcDDmonCCYY_HH:MM:SS date-time form such as '30jan2019 15:17:56' or [2.2] in 
Stata internal form {help datetime##s2:SIF} like 1864480676000. Notice that, 
{cmd:disp %13.0f clock("30jan2019 15:17:56", "DMYhms")} results in 1864480676000.

{phang}
{opt welfare:vars(string)}  

{dlgtab:Seldom used}

{phang}
{opt reg:ions(string)}  

{phang}
{opt filen:ames(string)}  

{phang}
{opt mod:ule(string)}  

{phang}
{opt plines(string)}  

{phang}
{opt cpivintage(string)}  

{phang}
{opt veralt(string)}  

{phang}
{opt vermast(string)}  

{phang}
{opt wbo:data(string)}  

{phang}{dup 80:-}


{marker examples}{...}
{title:Examples}
{dlgtab:Basic use}

{phang}[1]Calculate poverty indicators for all countries and all databases. 

{p 10 10 2}. indicators pov, countries(all){p_end}

{phang}[2]Calculate inequality indicators for new data only with respect to previous
version of {help datalibweb} repository. Note that option {it:countries()} is required. 

{p 10 10 2}. indicators ine, countries(all) newonly{p_end}

{phang}[3]Calculate Shared prosperity for one country, one year, and one collection. 
For this example, it would be Mexico, 2016, PovCalNet collection.

{p 10 10 2}. indicators shp, countries(MEX) year(2016) type(PCN){p_end}

{phang}[4]Calculate all indicators for all databases. {err: This function may take }
{err:more than 10 hours to run, for it loads about 3,000 files.}

{p 10 10 2}. indicators all, countries(all){p_end}

{dlgtab:Repository}

{phang}[1]Create general repository. Note that option {it:createrepo} is required. If not 
specified, then error. 

{p 10 10 2}. indicators repo, createrepo{p_end}

{phang}[2]Create GPWG2 repository and add to general repository. 

{p 10 10 2}. indicators repo, createrepo gpwg2{p_end}

{dlgtab:Load data}

{phang}[1]Load last version available of indicators file with poverty estimates (Wide format).

{p 10 10 2}. indicators pov, load{p_end}

{phang}[2]Load indicators file with inequality estimates in long format. 

{p 10 10 2}. indicators ine, load shape(long){p_end}

{phang}[3]Select vintage version to restore file indicators_ine to a particular version. 
This is possible only by clicking in the Stata results window. Two variations:

{p 10 10 2}. indicators ine, load vcdate(pick){p_end}
{p 10 10 2}. indicators ine, load vcdate(chooose){p_end}

{phang}[4]load indicators_ine to a particular version. This is possible only by 
specifying the exact date and time ({err:Note the syntax similarity to option restore}). 
Two variations:

{p 10 10 2}. indicators ine, {it:load} vcdate(20dec2018 15:51:03){p_end}
{p 10 10 2}. indicators ine, {it:load} vcdate(1860940263000){p_end}

{marker loadex1}{...}
{phang}[5]The same as example [4] above but in long format

{p 10 10 2}. indicators ine, {it:load} vcdate(20dec2018 15:51:03) shape(long){p_end}
{p 10 10 2}. indicators ine, {it:load} vcdate(1860940263000) shape(long){p_end}


{dlgtab:Load repository or report file}
{phang}[1]Load repository file (No long format available)

{p 10 10 2}. indicators repo, load {p_end}

{phang}[2]Load Report file of error and success of the process. Note that option 
{it:load} is not required

{p 10 10 2}. indicators report{p_end}

{dlgtab:Restore}

{phang}[1]Select vintage version to restore file indicators_ine to a particular version. 
This is possible only by clicking in the Stata results window. Three variations:

{p 10 10 2}. indicators ine, restore{p_end}
{p 10 10 2}. indicators ine, restore vcdate(pick){p_end}
{p 10 10 2}. indicators ine, restore vcdate(chooose){p_end}

{phang}[2]Restore indicators_ine to a particular version. This is possible only by 
specifying the exact date and time ({err:Note the syntax similarity to option load}). 
Two variations:

{p 10 10 2}. indicators ine, {err:restore} vcdate(20dec2018 15:51:03){p_end}
{p 10 10 2}. indicators ine, {err:restore} vcdate(1860940263000){p_end}


{marker files}{...}
{title:Explanation of files}{err: Section in process}

{pstd}
The {cmd:indicators} package is composed of one involving routing, indicators.ado, and
several independent subroutines, indicators_*.ado. 

{phang}
{opt indicators.ado}  


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:indicators} stores the following characteristics:

{p2colset 10 34 34 4}
{p2col:{cmd:_dta[datasignature_si] }}data signature{p_end}
{p2col:{cmd:_dta[datetimeSIF]      }}date and time of creation in Stata internal form {help datetime##s2:SIF}{p_end}
{p2col:{cmd:_dta[datetimeHRF]      }}date and time of creation in Human readable form {help datetime##s2:HRF}{p_end}
{p2col:{cmd:_dta[datetimeSIF_rf]   }}date and time of restoring file in SIF{p_end}
{p2col:{cmd:_dta[datetimeHRF_rf]   }}date and time of restoring file in HRF{p_end}
{p2col:{cmd:_dta[shape]            }}Shape of data{p_end}
{p2col:{cmd:_dta[calcset]          }}set of calculations{p_end}



{title:Author}
{p}

{p 4 4 4}R.Andres Castaneda, The World Bank{p_end}
{p 6 6 4}Email {browse "mailto:acastanedaa@worldbank.org":acastanedaa@worldbank.org}{p_end}

