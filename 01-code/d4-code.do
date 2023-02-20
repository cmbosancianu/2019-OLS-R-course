* Syntax for Day 4 of "Linear Regression in R/Stata" course
* ECPR Winter School in Methods and Techniques, Bamberg University
* February 25-March 1, 2019
* Author: Constantin Manuel Bosancianu
* Last edit: February 28
* Stata version: 17.0 (MP)

* We return to an old data set for today, the one we used in the first
* two days for the course. This is because it helps to discuss this
* topic with smaller data sets, where problematic observations can be
* reviewed with the help of additional data. After all, it might be
* hard to understand why respondent 1,037 has an extreme value on the
* outcome variable if we are unable to interview them again and find
* out more about them. If Texas has an extreme value, though, we might
* be able to search for background information which explains this.

* The use of that data set also means that some of the problems we
* discussed in the lecture this morning might not appear. I am sure
* such "perfect storm" data sets exist out there, but the one from
* today is not that one. The code should still work the same,
* regardless of the results.

* Set the working directory for the project
cd C:\Users\bosancianu\iCloudDrive\Documents\05-ECPR-MS\2019\Winter\Reg

* Read the data - we're back to a STATA format.
use ".\02-data\01-Education-states.dta"

* Let's run the model we last ran in class for this data.
* We first have to re-create all the variables we used in the model.
generate exp_scale = expense - 5235.961
label variable exp_scale "Rescaled (centered) educational expenditure"
generate per_scale = percent - 35.76471
label variable per_scale "Rescaled (centered) % of HS graduates taking SAT"
recode region (1=0) (2=1) (3=0) (4=0), gen(neast)
label variable neast "Indicator variable: state is in Northeast"
replace neast=1 if state=="District of Columbia"
replace region=2 if state=="District of Columbia"

regress csat exp_scale per_scale neast



**** LINEARITY ****
* We have to produce a component-plus-residual plot. STATA calls this a
* "augmented component plus residual" plot, which is why the function
* name is "cprplot"
cprplot exp_scale, lowess lsopts(bwidth(1))

* We are producing the plot, and then overlaying a lowess fit line,
* to see whether there are any significant departures from normality.

* It's maybe a bit of a stretch to call this a linear relationship,
* but given that it's a small sample, it's perhaps reasonably close to
* a linear one. Let's see what the other diagnostics tell us before we
* make a decision in this case.

cprplot per_scale, lowess lsopts(bwidth(1))



**** HOMOSKEDASTICITY ****
* First, a plot of fitted values (Y-hat) against studentized residuals.
* In STATA, this is obtained with the "rvfplot" command. However, because
* in STATA this uses raw residuals rather than standardized residuals, we
* have to do it by hand.

* Obtain studentized residuals
predict studres, rstudent
* Obtain fitted values
predict fitval, xb

* Do a scatterplot
twoway (scatter studres fitval) ///
	(lowess studres fitval), ///
	yline(0)

drop fitval

* It's a small sample size, so I would not automatically say there is
* heterogeneity

* Second, plots of predictors against studentized residuals
twoway (scatter studres exp_scale) ///
	(lowess studres exp_scale), ///
	yline(0)

twoway (scatter studres per_scale) ///
	(lowess studres per_scale), ///
	yline(0)




**** NORMALITY ****
* We would need a quantile comparison plot in this case, which is easily
* generated with the "qnorm" command

qnorm studres

* At least, overall, everything looks OK in terms of the normal
* distribution.

* This is another way to compare the two distributions.
kdensity studres, normal
* They seem fairly close to one another, particularly when
* considering the small sample size.



**** SPECIFICATION ERROR ****
* What other factors could be influencing average SAT scores?
* It turns out that a good case can be made for income. With higher
* average incomes, more can be invested in a child's education:
* special tutoring, books etc. At the same time, we might simply be
* dealing with reverse causality: in places with more capable students
* companies are interested in moving in and benefitting from the
* workforce, which means higher salaries.

* First, center income as well
generate inc_scale = income - 33.95657
label variable inc_scale "Rescaled (centered) income"

* Let's say that it might be the first.
regress csat exp_scale per_scale neast inc_scale

* There is an effect there, in the direction we expected. We also see
* that the effect of being in the Northeast of the US becomes
* stronger. Without this additional control we would have
* underestimated the SAT scores for Northeastern states.




**** COLLINEARITY ****
correlate expense percent income

* The correlations are pretty high here, but a bit below the threshold
* mentioned by Fox. In survey-based research you will typically not
* see such high correlations.




**** SOLVING PROBLEMS ****

histogram expense, bin(30) frequency

* A former participant's suggestion (Till Spanke, LSE): try different 
* transformations. "ladder" does this for a number of very common
* transformations, and then uses a chi^2 test to test for normality.
* As a user, try to choose the transformation with the LOWEST chi^2
* value.
ladder expense
gladder expense
* The distribution is a bit skewed here, which might be responsible
* for the problems we are seeing in the residuals. I will use a square
* root transformation

generate exp_sqr = 1/sqrt(expense)
 
histogram exp_sqr, bin(30) frequency
 

histogram percent, bin(30) frequency
* No transformation can solve this one.
gladder percent

* I will go for the 1/sqrt transformation as the least bad solution.
generate perc_sqr = 1/sqrt(percent)
 
histogram income, bin(30) frequency
* A square root transformation could improve things a bit here as well. 
gladder income
 
generate inc_sqr = 1/sqrt(income)


* There also seemed to be some problem with non-constant error mean in
* some of the plots to check for homoskedasticity
twoway scatter csat percent, mlabel(state)


* So let's try for the model again, this time with the added "income"'
* predictor, which came out as significant.
drop studres

regress csat exp_sqr perc_sqr neast inc_sqr

* Some of the coefficients are different than before, but this is
* understandable given that we have changed the scale of
* measurement for some of these predictors.

* Generate diagnostic measures again
predict studres, rstudent

rvfplot, yline(0) mlabel(state)

rvpplot exp_sqr, yline(0)
rvpplot perc_sqr, yline(0)
rvpplot inc_sqr, yline(0)

qnorm studres

* Not everything is perfect, but it might be as best as we can do
* under the circumstances.








**** UNUSUAL AND INFLUENTIAL DATA ****
clear all

use ".\02-data\01-Education-states.dta"

twoway (scatter csat expense, mlabel(state)) (lfit csat expense), ///
	ytitle(Cumulative SAT score) xtitle(Education expense)
	
* Questions:
* 1) How would you designate South Carolina, or Iowa? Are they
* outliers, or/and cases with high or low leverage? Are they
* influential cases or not?
* 2) How would you designate the District of Columbia? Is it an
* outlier, or/and an observation with high or low leverage? Is it an
* influential case or not?


* Let's run the model we last ran in class for this data.
* We first have to re-create all the variables we used in the model.
generate exp_scale = expense - 5235.961
label variable exp_scale "Rescaled (centered) educational expenditure"
generate per_scale = percent - 35.76471
label variable per_scale "Rescaled (centered) % of HS graduates taking SAT"
recode region (1=0) (2=1) (3=0) (4=0), gen(neast)
label variable neast "Indicator variable: state is in Northeast"
replace neast=1 if state=="District of Columbia"

regress csat exp_scale per_scale neast


* I) Leverage
* Hat-values can be obtained through the "predict" command, executed after
* the "regress" command
predict hatval, hat

* The hat-values are added to the data set, ready for plotting
* The average hat value is (k+1)/n, where k is the number of predictors
* in the model, and n is the sample size. In our case, this is 4/51 = 0.0784
* 2 x 0.0784 = 0.1568
* 3 x 0.0784 = 0.2352

list if hatval > 0.2352

list if hatval > 0.1568

* Look also to see whether there are any close to the threshold
list if hatval > 0.1468

* Remember, though, that for small samples, 3x average hat-value is a
* better threshold than 2x average hat-value.


* II) Outliers
* For this we need studentized residuals
predict studres, rstudent

* We want to see which residuals are larger than 2 or smaller than -2
* These are the critical values of the t distribution for a very large
* number of degrees of freedom.
list studres state csat neast per_scale exp_scale if abs(studres) > 2


* III) Influence
* I will present here only Cook's D, although a few other measures, 
* such as DFBETA and DFBETAS have been proposed.
predict cookd, cooksd

* You can then make a bubble plot just like the one R has.
* All you need to is to specify the thresholds, and that the
* points should be weighted based on Cook's D

twoway (scatter studres hatval [pweight = cookd], msymbol(circle_hollow)), ///
	yline(2, lpattern(dash)) yline(-2, lpattern(dash)) ///
	xline(0.1568, lpattern(dash)) xline(0.2352, lpattern(dash)) ///
	ytitle(Studentized residuals) xtitle(Hat values)
	
* First row specifies the two variables, and that Cook's D will be the
* weight. In addition, I specified that the symbol ought to be a hollow
* circle. Two horizontal lines were drawn at the critical t values. Finally,
* two vertical lines were drawn at the thresholds for the hat-values.



**** ADDRESSING OUTLIERS ****

* In terms of outliers and influential cases, Alaska, District of
* Columbia, and Iowa seem to consistently appear in the list of 
* problematic observations.

* At this point, in the course of a real project, you might consult
* the specifics of these three cases and see whether they are similar
* in terms of a factor that is not included in our model. That same
* factor might be a predictor of average SAT scores. Including it in
* the model might solve the problems.

* A secondary strategy might be to remove these cases, and re-estimate
* the model. This should not be done automatically, though, but rather
* after some reflection as to whether this is the best course of action.

* Remove a few influential observations
drop if state=="Alaska"
drop if state=="District of Columbia"
drop if state=="Iowa"

regress csat exp_scale per_scale neast

* If you ever need additional code for some other diagnostics, not
* presented here, the following page has a few examples:
* http://stats.idre.ucla.edu/stata/webbooks/reg/chapter2/stata-webbooksregressionwith-statachapter-2-regression-diagnostics/

* EOF
