* Syntax for Day 1 of "Linear Regression in R/Stata" course
* ECPR Winter School in Methods and Techniques, Bamberg University
* February 25-March 1, 2019
* Author: Constantin Manuel Bosancianu
* Last edit: February 17
* Stata version: 17.0 (MP)

* Time constraints prevent us from going into basic data manipulation
* procedures in Stata: recoding, labeling variables, or plotting.

* The data for today refers to the average SAT level in each of the 51
* American states, and what it is impacted by. The example scales
* easily to other settings, such as comparisons between countries in
* the PISA rankings, or between schools within a decentralized
* education system. The data comes from Lawrence Hamilton, "Statistics
* with STATA version 9" (2005), in a Stata format. It originates from
* data collected around 1990-1991.

* Set the working directory for the project - please replace this with
* the path that you've created on your computer.
cd C:\Users\bosancianu\iCloudDrive\Documents\05-ECPR-MS\2019\Winter\Reg

* Install a command we will need further down in the script
ssc install univar

* Read the data - this assumes that the data set is in a subfolder
* called "Data", and that this subfolder is placed in your main
* project folder.

use ".\02-data\01-Education-states.dta"

* See how the data looks in general
describe

* Show the first few rows of data
list in 1/6

* Everything looks fairly OK (nothing that we wouldn't expect). You
* notice that there are some missing values on some of the variables.



**** EXPLORING THE DATA ****

* The beginning of any regression analysis is a thorough exploration
* of the data. The goal for this is to understand features of your
* data that might be obscured by a simple mean or a standard
* deviation, e.g. outliers, or clusters.

histogram csat, frequency

* Nothing too odd there - a few states cluster around the values of
* 900 and 1000, but that's not particularly worrying at this stage.

* Higher average scores
list state region expense csat if csat > 1000
* Lower average scores
list state region expense csat if csat < 900

* What about per capita expenditure for primary and secondary education?
histogram expense, frequency width(200) xtitle(Per capita expenditure)

* Most are between 4,000 and 5,000 USD per capita.

* Higher average expenditure
list state region expense csat if expense > 6000
* Lower average expenditure
list state region expense csat if expense < 4000

* Curiously, some of the states which have among the highest average
* expenditures in the US, are also the ones with the lowest average
* SAT scores. Then again, Arkansas and Alabama are also in the list,
* with pretty high SAT scores for quite little expenditure on education.

* How is the relationship between SAT scores and expenditures?

twoway (scatter csat expense), ytitle(Combined SAT score) ///
	xtitle(Expense on Education)

twoway (scatter csat expense, mlabel(state)), ytitle(Combined SAT score) ///
	xtitle(Expense on Education)


* The relationship looks negative - states which spend more per
* student also register worse results in the SAT, on average. It's
* also interesting to note that the relationship might not be linear,
* in fact (we'll deal with this a bit later).

* How do the variables actually look in terms of distribution?
univar csat expense

* How strong is the relationship between the two variables?
correlate csat expense, covariance
* Curiously, in Stata both covariance and correlation are handled
* by the "correlate" function. This gives you a matrix, where the
* diagonal is the correlation/covariance of the variable with
* itself. The off-diagonal cells are the actual correlations or
* covariances you requested.

* You can see that the direction of the relationship is clearly
* indicated (negative). However, it's hard to tell just from the
* output whether this is a strong relationship or not, as we have no
* reference points.

* Additionally, the value depends on the scale of the variables.
* Consider for a bit what would happen if expenditure on education
* wouldn't be measured in USD but in 1,000s of USD.

generate exp_thous = expense / 1000
label variable exp_thous "Expense on education (in 1,000s USD)"

correlate csat exp_thous, covariance

* We now have a value for the covariance that is 1,000 times lower,
* but this doesn't mean the second covariance is smaller than the
* first, at least in how it describes the strength of association
* between the two variables.

* This is where the correlation helps, because it is scale invariant.
correlate csat expense
correlate csat exp_thous

* -0.47 would be considered a moderate correlation between the two
* -variables.

* Stata can check for many correlations at the same time.
correlate metro energy toxic green

* The R users have another command here, where we force the output
* from the correlation function to only display 2 decimals. In Stata
* this isn't needed, as Stata automatically truncates the output at
* 4 decimals.


* Remember, however, that the correlation is a good description of a
* linear relationship. If the association is not linear, then
* correlation might deceive you.

*-----------
* The R users have a few functions here, where I show R's capabilities
* to generate corrgrams (Friendly, Michael. 2002. "Corrgrams: Exploratory 
* Displays for Correlation Matrices." The American Statistician, 56, 316–324. 
* http://datavis.ca/papers/corrgram.pdf). This functionality has not yet
* been implemented in STATA, to the best of my knowledge, so I can't supply
* any code for this. STATA does offer the option to generate scatterplot
* matrices, though, and with the "corrtable" command, to generate a table
* of correlations as well.
*-----------
ssc install corrtable

* Are the relationships truly linear here?
graph matrix metro energy toxic green

* Use the command responsibly - it's slooooooow
corrtable metro energy toxic green, flag1(abs(r(rho)) > 0.8) ///
        howflag1(mlabsize(*7)) flag2(inrange(abs(r(rho)), 0.5, 0.8)) ///
        howflag2(mlabsize(*6)) half

* How about another set of variables?
graph matrix expense income high college

corrtable expense income high college, flag1(abs(r(rho)) > 0.8) ///
        howflag1(mlabsize(*7)) flag2(inrange(abs(r(rho)), 0.5, 0.8)) ///
        howflag2(mlabsize(*6)) half


* Finally, let's try a t-test: we saw that some states in the South
* and North East of the US tended to have pretty low scores on the
* combined SAT score. Is this something we can show with a more
* rigorous analysis?

* Turn the "region" variable into an indicator variable, for whether
* the state is in the South or North West, or not.
recode region (1=0) (2=1) (3=1) (4=0), gen(sne)
label variable sne "Indicator variable: state is in South or Northeast"

* Might the averages be so similar?
mean csat, over(sne)
* It looks as if states from the South and Northeast score much lower,
* on average, on the SAT

* Are these differences large enough, though?
ttest csat, by(sne)





**** SIMPLE LINEAR REGRESSION ****

* We will first try a simple linear regression, so as to see how
* things look, and how the standard output for such an analysis looks
* in Stata

* For this, we use a standard command in Stata, called "regress" (you
* can shorten it as "reg")
* "regress" needs a outcome variable (which goes first), followed by a
* predictor.
regress csat expense

* The output is split up in a few tables, but focus now only on the
* bottom table; in particular, look at the first column in that section, 
* labelled "Coef.". That's where your coefficients ("a" and "b" from our 
* slides) are.

* Questions:
* 1) How would you interpret a = 1060.73?
* 2) How would you interpret -0.022? (you will need to look back at
* the codebook, to see how the variables are coded)

* EOF