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
{bf:indicators} {hline 2} <insert title here>

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:indicators}
anything
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt option1(string)}} .{p_end}
{synopt:{opt option2(numlist)}} .{p_end}
{synopt:{opt option3(varname)}} .{p_end}
{synopt:{opt te:st}} .{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
{cmd:indicators} does ... <insert description>

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt option1(string)}  

{phang}
{opt option2(numlist)}  

{phang}
{opt option3(varname)}  

{phang}
{opt te:st}  


{marker examples}{...}
{title:Examples}

{phang} <insert example command>

{title:Author}
{p}

<insert name>, <insert institution>.

Email {browse "mailto:firstname.givenname@domain":firstname.givenname@domain}

{title:See Also}

NOTE: this part of the help file is old style! delete if you don't like

Related commands:

{help command1} (if installed)
{help command2} (if installed)   {stata ssc install command2} (to install this command)
