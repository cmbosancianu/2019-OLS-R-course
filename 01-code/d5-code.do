* Syntax for Day 5 of "Linear Regression in R/Stata" course
* ECPR Winter School in Methods and Techniques, Bamberg University
* February 25-March 1, 2019
* Author: Constantin Manuel Bosancianu
* Last edit: February 28
* Stata version: 17.0 (MP)


* We start with a coverage of interactions, which allow us to understand how the
* effect of a predictor varies over the values of another predictor in the
* regression model. This allows us to construct more sophisticated hypotheses,
* which don't have to assume that a 1-unit increase in predictor X will ALWAYS
* lead to a BETA increase in the outcome.

* Set the working directory for the project
cd C:\Users\bosancianu\iCloudDrive\Documents\05-ECPR-MS\2019\Winter\Reg

import delimited ".\02-data\03-Practice-data-ess.csv"

label variable ppltrst "Trust in other people"
label variable hinctnta "Household net income (in deciles)"
label variable mbtru "Union membership"
label variable age15 "Rescaled age"



**** INTERACTIONS ****
* We will be using the same ESS data as in Day 3, as that has a number
* of dichotomous variables.

* Before we run any models, we have to clean the data a bit
replace hinctnta = hinctnta - 1

* Instead of adopting the standard "subtracting the mean" approach, I will just 
* use the median, which is 13.
generate edu_scale = eduyrs - 13
label variable edu_scale "Rescaled education of respondent"

* Basic model
regress stfdem male age15 hinctnta c.edu_scale mbtru ppltrst 

* Is the effect of gender constant across all levels of education, though? A
* multiplicative interaction would help us answer this question.

* STATA has 2 operators for interaction: "#" and "##". When you add an
* interaction with "#", you have to make sure that the main terms in
* that interaction are added as predictors as well. When using "##"
* STATA automatically adds the main terms in the regression equation.

* The "c." forces STATA to consider "edu_scale" as continuous, while
* the "i." forces it to consider "male" as categorical. To get the
* "marginsplot" code below to work, I had to search for an answer
* here: https://www.statalist.org/forums/forum/general-stata-discussion/general/1331994-marginsplot-dimension-errors.
* The relevant answer was by Ariel Karlinsky, on April 4, 2016. There
* they present 4 ways of specifying the same model, and suggest that
* the first actually doesn't work, but the rest do. I them tried the
* syntax and... lo and behold... it works!

regress stfdem i.male age15 hinctnta mbtru ppltrst ///
	edu_scale i.male#c.edu_scale

* It turns out that it's not.

* Questions:
* 1) How do you interpret the effect of gender?
* 2) How do you interpret the effect of education?
* 3) How do you interpret the effect of the interaction term?

* In this case it's fairly easy to interpret the effect from the table
* of results itself. In other cases, though, it's not that easy. This
* is why the preferred way of presenting these results is to plot them
* graphically.

margins

* If you just type "margins", STATA predicts the value of satisfaction
* with democracy for each observation, and then displays the average of
* the predicted values.

* Here you tell it that you'd like to see the effect of gender, for each
* level of education.
margins, dydx(1.male) at(edu_scale=(-13(1)14)) vsquish
marginsplot, yline(0)

* Remember that interactions are symmetric, so you can also look at how the
* effect of education varies depending on gender
margins, dydx(edu_scale) at(male=(0 1))
marginsplot, yline(0)







**** LOGISTIC REGRESSION ****
* We would like to analyze the determinants of closeness to a
* particular party. Given the rising levels of alienation toward
* established political movements we have seen in advanced
* democracies of late, such a question certainly deserves an
* exploration. Who are the people most disenchanted with established
* political actors, and who might be tempted to support alternative
* movements?

* Some inspiration can always come from looking at the data through
* crosstabs and graphics.

mean agea eduyrs hinctnta, over(clsprty)


* At first glance, it would seem that it's younger people who tend to
* report not feeling close to any party. No distinction based on
* education can be seen, and only a slight one based on income.

* Will these differences still remain, once we control for other
* variables? This is where regression comes in.
* The command for a logistic regression is "logit", and it has
* roughly the same format as that for linear regression: the outcome
* is listed first, followed by the list of predictors (if more than
* one).
logit clsprty male age15 edu_scale mbtru hinctnta ppltrst

* Just remember, the coefficients are expressed in logged odds.
* If you want them expressed in odds ratios, simply ask for the
* output to be presented as such.
logit, or
* Now you can see that the table heading for the column clearly
* indicates that odds ratios are displayed.

* Plotting predicted probabilities using our old friend, "margins"
margins, at(edu_scale=(-7(1)7)) atmeans vsquish post
marginsplot

* Doing the same procedure through More Clarify isn't that much more
* difficult.
postsim, saving(sims) seed(5534): logit stfdem male age15 edu_scale hinctnta ///
	mbtru ppltrst
simqoi using sims, ev at( (mean) _all edu_scale=(-7/7))

* EOF