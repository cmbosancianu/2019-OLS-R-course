# Linear Regression with `R`/`Stata`: Estimation, Interpretation and Presentation

This course exposed participants to the rigorous application of linear regression models. Over five days we went through estimating these models, interpreting their results and judging how well the models fit the data. We gradually explored more complex specifications, learning how to deal with dichotomous predictors and interactions. We also focused on the assumptions which OLS models are based on, how to check for these in the data at hand, and how to handle situations when they are not met. Throughout the class, we emphasized presenting results as intuitively as possible for our audience, either through graphs or predicted values. This format hopefully served participants interested in a thorough coverage of linear models, both for immediate use and as a stepping stone for more advanced statistical procedures. The class was conducted primarily in `R`, but also shared `Stata` code for all procedures and models.

## Workshop schedule

### Day 1: From correlation to regression: revisiting the basics

We cover a few foundational concepts in statistics: correlation, standard error, *t* test, *t* and *z* distributions. We also make our first forays into the regression setup. In the lab part, we get familiar with `R` or `Stata`, and try a few basic data manipulation and transformation tasks. All of these tasks habitually have to be performed before running a regression.

Required readings:

- Moore, D. S., McCabe, G. P., & Craig, B. A. 2009. *Introduction to the Practice of Statistics*. 6th edition. New York: W. H. Freeman and Co. Chapters 5, 6, 7 and 8.
- Fox, J. 2008. *Applied Regression Analysis and Generalized Linear Models*. 2nd edition. Thousand Oaks, CA: Sage. Chapter 2.

(NB: For Moore et al (2009), there is no need to read each of the chapters carefully. Please only focus on the topics that you feel you might need a brush up on. The rest of the topics can be merely skimmed. If the 4 chapters from Moore et al. (2009) seem too intimidating, please at least check the 2 chapters from Field et al. (2012) below. For Fox (2008), focus more on sections 1 and 3 of the chapter – even there, not the sophisticated terms, just the general ideas and logic of the procedure.)

Optional readings:

- Field, Andy, Jeremy Miles, and Zoë Field. 2012. *Discovering Statistics Using R*. London: Sage Publications. Chapters 2 and 3.

### Day 2: OLS fundamentals: coefficients and model fit

We go through the estimation of OLS models and the interpretation of coefficients for simple and multiple regression. In the lab session, we run a few regressions in `R` or `Stata`, based on the code supplied by the instructor, and go through interpreting coefficients and measures of model fit once more. We also introduce a way of presenting effect sizes based on the `clarify` package for both `R` and `Stata`.

Required readings:

- Fox, J. 2008. *Applied Regression Analysis and Generalized Linear Models*. 2nd edition. Thousand Oaks, CA: Sage. Chapters 5.
- [if Fox seems too intricate] Field, Andy, Jeremy Miles, and Zoë Field. 2012. *Discovering Statistics Using R*. London: Sage Publications. Chapter 7 (sections 1 and 2, but without 7.2.4; section  6, but without 7.6.3 and 7.6.4).

Optional readings:

- Lewis-Beck, Michael S. 1980. *Applied Regression – An Introduction*. Quantitative Applications in the Social Sciences Series, Vol. 22. London: Sage. Chapter 1 and 3 (only pp. 47-51).
- Kutner, Michael H., Christopher J. Nachtsheim, John Neter, and William Li. 2005. *Applied Linear Statistical Models*. 5th edition. Boston: McGraw-Hill. Chapter 1.

### Day 3: Dummy variables and uncertainty of estimates

We discuss slightly more complex model specifications which include dummy variables. The bulk of the class, though, is devoted to understanding and interpreting uncertainty in our regression estimates. In the lab, we go through additional regression models, which involve dummies. Most of our empirical efforts, though, will be allocated to understanding where uncertainty in estimates comes from, how we can minimize it, and how we can responsibly present it to the audience.

Required readings:

- Fox, J. 2008. *Applied Regression Analysis and Generalized Linear Models*. 2nd edition. Thousand Oaks, CA: Sage. Chapter 6.
- Hardy, M. A. 1993. *Regression with Dummy Variables*. Quantitative Applications in the Social Sciences Series. London: Sage. Chapter 3.
- [if Fox seems too intricate] Field, Andy, Jeremy Miles, and Zoë Field. 2012. *Discovering Statistics Using R*. London: Sage Publications. Chapter 7 (section 7.2.4; sections 7.4, 7.5, 7.8, 7.11, 7.12).

Optional readings:

- Lewis-Beck, Michael S. 1980. *Applied Regression – An Introduction*. Quantitative Applications in the Social Sciences Series, Vol. 22. London: Sage. Chapter 2 and 3 (only pp. 51-52 and 66-71).
- Kutner, Michael H., Christopher J. Nachtsheim, John Neter, and William Li. 2005. *Applied Linear Statistical Models*. 5th edition. Boston: McGraw-Hill. Chapter 2.

### Day 4: Regression assumptions: violations and remedies

This session covers the assumptions underpinning OLS regression, what the implications of assumption violations are, and how to correct for them. The lab session will offer practical strategies of identifying assumption violations, and overcoming some of them through data transformations. We also see how estimates and model fit statistics change when correcting for some of these violations.

Required readings:

- Fox, J. 2008. *Applied Regression Analysis and Generalized Linear Models*. 2nd edition. Thousand Oaks, CA: Sage. Chapters 11 and 12.
- [if Fox seems too intricate] Field, Andy, Jeremy Miles, and Zoë Field. 2012. *Discovering Statistics Using R*. London: Sage Publications. Chapter 7 (sections 7.7 and 7.9).

Optional readings:

- Berry, W. D. 1993. *Understanding Regression Assumptions*. Quantitative Applications in the Social Sciences Series. London: Sage. Chapter 5. [*technical at times, but a thorough treatment*]
- Kutner, Michael H., Christopher J. Nachtsheim, John Neter, and William Li. 2005. *Applied Linear Statistical Models*. 5th edition. Boston: McGraw-Hill. Chapter 3.
- King, G., & Roberts, M. E. 2015. "How Robust Standard Errors Expose Methodological Problems They Do Not Fix, and What to Do About It." *Political Analysis* **23**(2), 159–179. [*the paper is a bit technical in some of the parts, so maybe skip those more mathematical sections, and try going for sections 1, 6 and 7*.]

### Day 5: Recap, multiplicative interactions in regression, and graphical presentations

In this last session, we review a few of the most important ideas covered in the past four days , based on participants' requests. I also introduce a way to test more sophisticated hypotheses, about how effects of a predictor vary, through the use of interactions. Finally, I show a few of the ways in which regression results can be presented to the audience, and discuss the strengths and weaknesses of each.

In the lab I show code for interactions, graphical presentations of results, and also allow for a recap of any topics participants feel we should cover again.

Required readings:

- Brambor, T., Clark, W. R., & Golder, M. 2005. "Understanding Interaction Models: Improving Empirical Analyses." *Political Analysis* **14**(1), 63–82.
- Gelman, A., Pasarica, C., & Dodhia, R. 2002. "Let's Practice What We Preach: Turning Tables into Graphs." *The American Statistician* **56**(2), 121–130.

Optional readings:

- Jaccard, J., & Turrisi, R. 2003. *Interaction Effects in Multiple Regression*. Quantitative Applications in the Social Sciences Series. London: Sage. Chapter 2.

**NB**: Previous versions of the code relied on the `Zelig` package for `R` and the `clarify` add-on for `Stata`, especially in the Day 2 session. With both packages being discontinued around 2018, a decision was made to replace this code with the `clarify` package from early 2023.