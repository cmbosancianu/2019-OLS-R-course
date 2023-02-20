* Syntax for Day 2 of "Linear Regression in R/Stata" course
* ECPR Winter School in Methods and Techniques, Bamberg University
* February 25-March 1, 2019
* Author: Constantin Manuel Bosancianu
* Last edit: February 17
* Stata version: 17.0 (MP)

* We can continue with the SAT score data from yesterday. We will
* gradually add a bit more complexity to our model today, under the
* form of additional predictors.

* Set the working directory for the project
cd C:\Users\bosancianu\iCloudDrive\Documents\05-ECPR-MS\2019\Winter\Reg

* Install a needed package "estout". If the network installation does
* not work, please consult this page for instructions on how to install
* it (http://repec.org/bocode/e/estout/installation.html)
ssc install estout, replace

* Read the data from yesterday
use ".\02-data\01-Education-states.dta"






**** SIMPLE LINEAR REGRESSION (cont.) ****
* We start by running the model we finished yesterday's class with:
* CSAT <- educational expenses.

regress csat expense

* Of course, it makes no sense to talk about the predicted average SAT
* score for a state with 0 USD spent on education. We can solve this
* by rescaling the predictor.

mean(expense)
generate exp_scale = expense - 5235.961
label variable exp_scale "Rescaled (centered) educational expenditure"

regress csat exp_scale

* Now, at least, the intercept makes sense. How would you interpret it
* with this version of the predictor?



**** MODEL FIT ****

* 1) What is the residual standard error in the model?
* 2) How do you interpret the R-squared value?

* These are important summary statistics, and although sometimes they
* get abused (particularly the R-squared), they tell us important
* things. At the same time, they cannot replace a thorough look at how
* the model does in PREDICTING the data: where does it predict well,
* and where does it do poorly?

* For that, all you need to ask for is the predicted (fitted) values
* Stata uses the "predict" function, for which we supply the argument
* "xb" - meaning that we want the linear prediction
predict predcsat, xb
list predcsat

* In their raw form they don't tell us very much, so we might want to
* actually plot them against the actual values for "csat". This code
* also draws a diagonal line on the plot - if our model would have
* perfectly predicted the data, all the points would have aligned on
* the diagonal

twoway (scatter predcsat csat, mlabel(state)) ///
	(function x, range(csat) n(2)), ///
	ytitle(Predicted value SAT) xtitle(Actual value SAT)


* You can see that at low levels of SAT scores we are overpredicting,
* and at high levels of SAT scores, we are underpredicting. The
* differences are quite substantial: we are frequently talking about
* 50-100 SAT points.





**** MULTIPLE LINEAR REGRESSION ****

* What if we're actually dealing with a self-selection effect? A
* number of insights lead us to believe that this is the case:
* 1) As one of your colleagues has suggested, the SAT has a competitor,
* the ACT. Some students might opt for the SAT because they have a
* particular set of colleges they would like to attend, and they only
* apply to them.
* 2) Some states offer the SAT to all students free of charge (the
* recent list includes District of Columbia, Idaho, Maine). Others
* require it of their students (the recent list includes Colorado,
* Illinois, New Hampshire).
* 3) Some states might simply be better at incentivizing students to
* take the SAT, and at offering them assistance for the test, or
* publicizing the benefits of taking the SAT.

* Whatever the reason, if a larger group takes the SAT, we would
* expect that there is a greater diversity in test scorers, which
* means lower average scores. In states where students are allowed to
* self-select into taking the test, we expect better students to opt
* for it, and therefore we expect to see higher average scores. In
* this sense, it's not that some states are worse in educational
* provision than others - it's just a different composition of
* students taking the SAT.

correlate expense percent
* A pretty high correlation between the two.

* Perform the same centering for "percent" as well, so as not to
* interpret the intercept as the SAT score in a state where 0% of
* students take the SAT.

mean(percent)
generate per_scale = percent - 35.76471
label variable per_scale "Rescaled (centered) % of HS graduates taking SAT"

regress csat exp_scale per_scale


* Questions:
* 1) How do you interpret the effect of expenses on education?
* 2) How do you interpret the effect of percentage of high school
* students that take the SAT?
* 3) How do you interpret the R-squared value?
* 4) How does Model 3 do compared to Model 2, in terms of residual
* standard error?
* 5) How does Model 3 compare to Model 2 in terms of R-squared value
* and adjusted R-squared value.




**** PRESENTING REGRESSION RESULTS IN PAPERS ****

* Copying results by hand, at 11:30 PM the day before the submission
* deadline for the conference, jacked up on Red Bull, chocolate and
* peanuts, is a recipe for mistakes.

* There is really no need to do this, as Stata has a few commands
* to extract the needed quantities from a regression output,
* and export them in HTML or LaTeX format, for use in your papers.
* Before running the next bit of syntax, please make in the working 
* folder for today, a subfolder called "Output". This will be used 
* to export some regression comparison tables.

eststo: regress csat exp_scale
eststo: regress csat exp_scale per_scale

esttab using .\05-output\Table-1.rtf

* Go further in customizing the output
esttab using .\05-output\Table-1.rtf, replace label ///
	title(Regression comparison table) ///
	nonumbers mtitles("First model" "Second model") ///
	addnote("Source: Data from WSMT 2019.")

* Give custom labels to coefficients
* Also specify the format of the coefficients and standard errors
esttab using .\05-output\Table-1.rtf, b(a3) se(a3) replace label ///
	title(Regression comparison table) ///
	nonumbers mtitles("First model" "Second model") ///
	addnote("Source: Data from WSMT 2019.") ///
	coeflabels(expScale "Educ. expense" perScale "% students taking SAT")

* You can use the same code to export results to LaTeX
esttab using .\05-output\Table-1.tex, b(a3) se(a3) replace label ///
	title(Regression comparison table) ///
	nonumbers mtitles("First model" "Second model") ///
	addnote("Source: Data from WSMT 2019.") ///
	coeflabels(expScale "Educ. expense" perScale "% students taking SAT")

		
* As a matter of personal taste, I like regression tables where the
* main predictors of interest are placed at the top of the table. That
* way I don't have to scan a long regression table for the precise
* coefficient discussed in a paragraph. It is also helpful to separate
* with a line these main predictors from the statistical controls that
* are not really the main focus of the paper. You can easily do the
* first procedure, re-ordering, with the "reorder()" argument.

*  Save the data set, as we will need it tomorrow for one last demo
save .\02-data\02-Education-states-followup

* EOF
