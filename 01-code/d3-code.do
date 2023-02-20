* Syntax for Day 3 of "Linear Regression in R/Stata" course
* ECPR Winter School in Methods and Techniques, Bamberg University
* February 25-March 1, 2019
* Author: Constantin Manuel Bosancianu
* Last edit: February 17
* Stata version: 17.0 (MP)

* Set working directory for the current day. On your machine, please
* replace this folder path with the one you use for the Winter
* School documents.
cd C:\Users\bosancianu\iCloudDrive\Documents\05-ECPR-MS\2019\Winter\Reg


* We will first start with the data set from yesterday, to illustrate
* how OLS handles categorical predictors, and then we will move to the
* issue of making inferences in OLS.

* IF you keep your Stata script and the data file in the SAME 
* folder then please delete from the folder path below the
* part with "\02-data". If you leave it the way I wrote the path,
* the assumption is that your Stata script is in a folder, and 
* that in this folder there is a subfolder called "02-data", where 
* the data set is placed.



**** CATEGORICAL PREDICTORS ****
use ".\02-data\02-Education-states-followup.dta"

* The last model we tested yesterday
regress csat exp_scale per_scale

* We noticed in the first day fairly large regional differences in
* terms of SAT scores.
tab region, sum(csat)

* One lingering issue is whether the regional distinctions we observed
* are due to differences in education spending, or percentage of
* graduates taking the SAT, or rather another factor? We can try to
* test for this by adding an indicator variable - first, let's see
* about the North East.

* Create an indicator variable for the region.
recode region (1=0) (2=1) (3=0) (4=0), gen(neast)
label variable neast "Indicator variable: state is in Northeast"

* The annoying part is that the District of Columbia is not actually
* part of a region. So as not to lose the case, I coded it manually as
* belonging to the North East
replace neast=1 if state=="District of Columbia"
replace region=2 if state=="District of Columbia"

regress csat exp_scale per_scale neast
list state region expense csat if csat < 900
* It will be a bit easier if we have the models in a comparison table,
* so this next section of code simply does this table and displays it
* on the screen.

* Run first model and store output
eststo: regress csat exp_scale per_scale
* Run second model and store output
eststo: regress csat exp_scale per_scale neast

* Display coefficients, with standard errors, plus R-squared and adjusted
* R-squared
esttab, se ar2

* Questions:
* 1) How do you interpret the effect of being a state in the North East?
* 2) How come it's now POSITIVE?

* Clear from memory the stored model results
eststo clear

bysort neast: egen perc_mean = mean(percent) 
bysort neast: egen csat_mean = mean(csat)

by neast: summarize perc_mean csat_mean


* Multiple categories can also be handled easily. Say that instead of
* just comparing the North East with everyone else, we wanted to see
* how each region is doing. That can also be checked very easily.

regress csat exp_scale per_scale i.region

* The omitted category in this case is "West". How would you interpret
* the intercept value in this case? Furthermore, how would you
* interpret the value of the coefficient for "North East"?

* If you're not happy with the reference category selected
* automatically by Stata, you can always force a specific reference
* category with the aid of a small function.

* This ("ib3.") makes the third category a reference category
regress csat exp_scale per_scale ib3.region

* Just remember, forcing a reference category will also change the
* interpretation of the intercept, compared to the previous model.
* However, the interpretation of the other predictors is not changed.
* Nor is their effect size altered.

clear all





**** INFERENCE SECTION ****

* We start with a new data set today, obtained from Round 7 of the
* European Social Survey. The data refers to Great Britain, and was
* collected in 2014. As the data is in .CSV format, both R and Stata
* users will have to work with the codebook ("Codebook-ESS-data.pdf").

* Install a package needed later on in the script
ssc install ftest

* If your data file and this syntax file are in the same folder, then
* you can delete the part with "\03Data" in the code below.

import delimited ".\02-data\03-Practice-data-ess.csv"

label variable ppltrst "Trust in other people"
label variable hinctnta "Household net income (in deciles)"
label variable mbtru "Union membership"
label variable age15 "Rescaled age"

* Now, before we start, it is only fair to say that the most proper
* model for this data is not a linear regression, but rather an
* ordered logit. This would treat the measurement scale of
* satisfaction with democracy as a proper set of 11 categories,
* arranged in order of intensity, and not as a continuous scale (where
* any value between 0 and 10 is possible). The dangers in using a
* linear regression on such a 0-10 ordered scale are that predictions
* frequently fall in between adjacent categories (e.g., 3.675), or
* that predictions might fall outside of the bounds of the scale
* (e.g., 12). Nevertheless, I will use such a model for this dependent
* variable. There are two main reasons for this. For one, you
* frequently encounter such models being used for ordinal data in
* applied work, so it's worthwhile to show an example. Second, very
* frequently the substantive results from a linear model will be very
* similar to those obtained with a ordered logit. In this sense, then,
* we are not abusing the data as much as would seem at first glance.
* Even so, I'd like to stress this once more: the most appropriate
* model for this dependent variable is an ordered logit.

* If we are being honest, there are not that many variables in voting
* behavior that are truly continuous, and therefore suitable for a
* linear model estimated with OLS.

* Take a look at the data for a bit.
list in 1/6

univar age15
histogram age15, frequency xtitle(Age (rescaled))

univar eduyrs
histogram eduyrs, frequency xtitle(Years of education)

univar hinctnta
histogram hinctnta, frequency xtitle(Household net income)

* Try a scatterplot
twoway (scatter stfdem hinctnta, jitter(5)), /// 
	ytitle(Satisfaction with democracy) ///
	xtitle(Household net income)

* Unfortunately, scatterplots aren't very useful in this case. Even
* with the jittering function, they can't really show whether there is
* a relationship between the two variables. This is a standard
* occurrence when using ordered data with a limited number of categories.

* A much more useful approach is to simply compute a mean of
* satisfaction with democracy for each level of income of our
* respondents. That ought to give us a rough idea whether higher
* income is associated with a higher level of satisfaction.

bysort hinctnta: egen sat_mean = mean(stfdem) 
label variable sat_mean "Mean level of satisfaction with democracy, per income group"

by hinctnta: summarize sat_mean

* Aside for some slight deviations, there seems to be a positive
* relationship between the two. As income increases, so does
* satisfaction with democracy.

* With education it will be slightly more difficult to spot the trend,
* as we have 31 categories. I will collapse them into 6, so as to
* make the pattern clearer.

recode eduyrs (0/5=1) (6/10=2) (11/15=3) (16/20=4) (21/25=5) (26/30=6), ///
	gen(educ06)

bysort educ06: egen sat_mean2 = mean(stfdem) 
label variable sat_mean2 "Mean level of satisfaction with democracy, per educational group"

by educ06: summarize sat_mean2

drop educ06 sat_mean sat_mean2

* There also seems to be a positive relationship between these two variables

* How is the correlation between these two predictors (education and income)?
spearman eduyrs hinctnta

* Doesn't look that bad

* Before starting with the model, I will listwise delete all
* observations with missing information on any of the variables. This
* is so as to make sure that all models are estimated on exactly the
* same sample.

drop if stfdem==.
drop if male==.
drop if agea==.
drop if eduyrs==.
drop if mbtru==.
drop if hinctnta==.
drop if ppltrst==.
drop if clsprty==.








**** INFERENCE IN REGRESSION ****

* Start by running a simple model of satisfaction with democracy.
* First, though, let's make sure income has a meaningful "0" value, so
* as to be able to interpret the intercept in a sensible way.

replace hinctnta = hinctnta - 1

regress stfdem hinctnta

* Questions:
* 1) How do you interpret the intercept in this instance?
* 2) How do you interpret the effect of income?
* 3) Are they statistically significant? How can you tell?

* With STATA you already get the confidence intervals displayed in
* the output. If you don't want the default 95% confidence level,
* you can ask for any other value. You don't even need to run the
* regression again. Just typing "regress" will print out again the
* previous model's output

regress, level(99)

* 99% confidence intervals are wider than the 95% confidence
* intervals, but this is normal. If you want to have a higher degree
* of certainty, you'd better enlarge your universe of possibilities.
* Taking this to the limit, a 100% confidence interval will be...
* - infinity to + infinity. Also note that there is nothing special 
* about the 95% confidence level. It was chosen a long time ago (by 
* R. A. Fisher) as a convenient threshold, and scientists have followed 
* that convention to this day. It is just that, though: a convention. It 
* doesn't have deeper mathematical properties. If you wanted to you could 
* use 0.10 or 0.15 as a threshold, although, the power of a convention is
* strong: you will frequently have to justify the choice.

regress stfdem male age15 hinctnta eduyrs

* Question: What does it mean that the significance test for education
* produces a p-value that is much, much lower than the corresponding
* p-value for gender? STATA users can't see this automatically in the
* output, but it can be deduced from the t value, which is much higher
* for trust than it is for income. A higher t value produces a lower
* p value.

* You can see from the F-test for Model 2 that at least some of the
* coefficients are not 0 (redundant information, given that we already
* examined the significance tests for each coefficient).

* What if we wanted to compare Model 1 with Model 2, though? We could
* see whether any of the added predictors have effects that are
* different from 0.

* We use the "eststo" command to store model results
regress stfdem hinctnta
eststo model1

regress stfdem male age15 hinctnta eduyrs mbtru ppltrst
eststo model2

* Do the F-test comparison between the models
ftest model1 model2

* Indeed, at least some of these added predictors have coefficients
* which are different from 0. The F-test value is 29.89, and is
* statistically significant at the 0.05 level.




**** PRESENTING RESULTS ****

* In most journals, you will likely be required to present a table of
* regression results, as we generated yesterday. That's the standard
* approach.

* The slightly cooler way is to present the coefficients graphically,
* and maybe put the table of actual results in the online appendix.
* STATA already has the "marginsplot" command, which can do this, but
* sometimes you may not want to run "margins" beforehand just so as to
* obtain a plot like this.
ssc install coefplot

* We can run the regression again, without displaying the results
quietly regress stfdem male age15 hinctnta eduyrs

* This suppresses the constant from being plotted, and draws a line
* of no effect at 0.
coefplot, drop(_cons) xline(0)

coefplot, drop(_cons) xline(0) xtitle(Regression results)

* You can even do slightly more sophisticated things with it, like
* comparing different model estimates. The "quietly" option simply
* runs the regression without displaying the output in the console.

quietly regress stfdem male age15 hinctnta eduyrs
eststo model1
quietly regress stfdem male age15 hinctnta eduyrs mbtru ppltrst
eststo model2

coefplot (model1, label(First model)) (model2, label(Second model)), ///
	drop(_cons) xline(0)
	
* There are very many customizations that can be done with this command.
* If you're interested in using it further, please take a look at:
* http://www.stata.com/meeting/germany14/abstracts/materials/de14_jann.pdf	


* The final way, though, is my favorite. There are multiple reasons
* for this, but the main one is that it presents what people actually
* care about: how does the outcome change when the predictor changes?
* Coefficients are not so intuitive for an audience that has had no
* contact with statistics. Changes in the outcome are simple enough
* for most people to understand.


* In order for the "margins" command to work properly, you have to define
* the variable you're interested in as categorical. This is what "i." in
* front of the variable names does below. "c." defines variables as
* continuous.
quietly regress stfdem i.male c.age15 i.hinctnta c.eduyrs i.mbtru ////
	c.ppltrst, vsquish noheader

* Present marginal effects of income on satisfaction with democracy
margins hinctnta

* "margins" can also be used to compare the change in satisfaction with
* democracy that would be achieved from a change in one of the predictors
quietly regress stfdem i.male c.age15 i.hinctnta c.eduyrs i.mbtru ////
	c.ppltrst, vsquish noheader
margins, dydx(male)

* You can also show the effects in a graphical format
quietly regress stfdem i.male c.age15 i.hinctnta c.eduyrs i.mbtru ////
	c.ppltrst, vsquish noheader
margins hinctnta
marginsplot









**** BONUS PACKAGE: CLARIFY ****
* Yet another way of presenting results can be done with the counterpart
* of the "clarify" package in R - more_clarify. (more information (pun
* intended) about it can be found here: 
* https://ideas.repec.org/c/boc/bocode/s457851.html)
ssc install more_clarify

* So here's how it works, with only 2 commands:
* 1) "postsim": estimate a regression and simulate its coefficients;
* 2) "simqoi": obtain the predicted value of the outcome based on the
* values of the predictors you specify

postsim, saving(sims) seed(5582): regress stfdem male age15 hinctnta eduyrs ///
	mbtru ppltrst

* In this example, we simulate the expected value of satisfaction with
* democracy, with all predictors held at their mean values, except
* income, which is allowed to vary from the 3rd to the 8th decile.
simqoi using sims, ev at( (mean) _all hinctnta=(2/7))

* Now you have a predicted expected value of satisfaction with democracy
* for someone who goes from the bottom 30% to the top 80% of income,
* while holding everything else constant

* The difference between "predicted" and "expected" values is subtle.
* When doing the simulations, "expected values" simply take into
* account the uncertainty that comes from the SEs. "Predicted
* values" take into account both the uncertainty in the SEs, and the
* one stemming from the fact that the model does not fit the data
* perfectly. This is why predicted values will usually be more spread
* out than expected values.

simqoi using sims, seed(47109) ev at( (mean) _all hinctnta=(2/7))

simqoi using sims, seed(47109) pv at( (mean) _all hinctnta=(2/7))

* In our case here, they are massively spread out, simply because the
* model fits the data so poorly.

* The cool thing is that the "at" approach can work even for more
* than 1 variable at the same time.

simqoi using sims, seed(58275) ev at( (mean) _all hinctnta=(2/7) mbtru=(0/1))

* EOF
