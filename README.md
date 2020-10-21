# Analysis of the level of happiness of the Belgian population using data obtained from the European Social Survey using Logistic Regression in SAS 4GL and SAS Enterprise Guide.

### Author: Adrian Żelazek

The aim of this work is to determine the determinants of the subjective sense of happiness of Belgian citizens. Binary logistic regression was used for the analysis. The project was made using SAS 4GL language and SAS Enterprise Guide tool.

Using the model, three research hypotheses will be verified to verify whether the satisfaction with democracy, health level and meetings with friends influence the subjective level of happiness. The source of data in the analysis is a sample from the ninth round of the European Social Survey. The data source in the analysis is a sample from the ninth round of the European Social Survey. The level of feeling of happiness as an explained variable. For the purposes of the model two categories had to be distinguished, therefore levels 0-7 of feeling happy were marked as unhappy and 8-10 as happy.

### Programming language and tool
* SAS 4GL
* SAS Enterprise Guide

### Actions performed and results
1. 22 explanatory variables were included in the collection: both demographic (e.g., age, gender) and behavioural variables, as well as attitudes towards important life and social issues.
2. exploratory analysis of the explanatory variables showed that:
* the level of happiness does not differ significantly in different age groups, it is also similar for both genders and people with different political views
* higher levels of education and income, as well as strong attachment to the country are accompanied by higher levels of happiness, as well as strong health, participation in a circle of friends, involvement in political life, good fun, self-determination, lack of children
* As part of the quota analysis, the relationship between the explanatory variable HPI, luck, and the individual explanatory variables before categorization was examined. 
The quota analysis of the explanatory variables showed that:
* Some of the variables were well balanced, e.g., the roach, where 614 women and 604 men declared to be happy and 285 women and 264 men declared to be unhappy. The same was true of the variable stfdem, for example, which expresses satisfaction with the operation of democracy in the state.
* Other variables were much less balanced, an example being the variable The luckiest group was group 6 - as many as 277 of the 368 respondents classified in this group were very lucky. In turn, the most unhappy people were classified in group 2 (122 people). 
* Most variables were not balanced.
4. Variables were prepared for modelling
5. model construction:
* To begin with, the tolerance coefficient and variance inflation were analyzed using the REG procedure to investigate the collinearity. The criterion was adopted that variables for which the tolerance is less than 0.4 will be removed from further analysis because they show collinearity. None of the variables met the criterion defined above, therefore all variables will be included in the next stage. 
* In the first phase it was checked whether the insignificant variables will not be disruptive. The selected variables were removed in order: from the variable with the highest value of p to the variable with the lowest value of p. Finally in this phase it was established that the variables ipudrst_cat and polintr_cat are disruptive variables, because after removing these variables the evaluation of the parameter at the variable health_cat=3 changed by more than 10%. 
* The second phase was aimed at finding potentially important interactions that could eventually be added to the model. For this purpose, 2 selection methods were used in the logistic procedure: stepping and progressive. As a result of each of them it turned out that the interaction assessed as statistically significant was mnactic_cat*hinctnta_cat 
* The final model was built in the third phase. The main interest variables (health_cat, sclmeet_cat, stfdem_cat), interfering variables (ipudrst_cat, polintr_cat) and the gndr variable - literature were forced here.
6. Model interpretation:
* In the beginning, a test of the global zero hypothesis was conducted: BETA=0. The p-values for all statistics were lower than the significance level of 0.05. The zero hypothesis that the evaluations of parameters at all variables and interactions of two variables are statistically insignificant should be rejected. 
* Then the combined tests were performed. The zero hypothesis that the evaluations of parameters at the variables of main interest and interactions were statistically insignificant was rejected. For the other variables, there were no grounds to reject the zero hypothesis, but these variables were left in the model because they were considered disruptive.
7. Parameters evaluation:
* Additionally, evaluations of parameters with variables of main interest (health_cat, sclmeet_cat, stfdem_cat) allow to state that research hypotheses set at the beginning of the study are reflected in the model. The parameters with the health_cat variable indicate that the better a person assesses his/her health, the happier he/she will be. In the case of sclmeet_cat it turns out that the less often he meets people, the less happy he will be. The parameters with the stfdem_cat variable also show that the less happy a person is with democracy in the country, the less happy he is.
* Then the odds quotient analysis was performed. For example, for the variable sclmeet_cat: the chances of being happy are 47% lower for category 1 and 32% lower for category 2 than for category 3.
8. Predictive power of the model:
* Predictive power is good, which was checked on the basis of D Somers, Gamma and Tau statistics values are greater than 0, but smaller than 0.5.
* The model also proved to be well matched to the data, which shows the results of Hosmer and Lemeshow compatibility test. The p-value is greater than the significance level of 0.05. There is no reason to reject the zero hypothesis that the model is well matched to the data.
9. Summary:
* As a result of work, the model built on the basis of ESS data concerning Belgian citizens. The variable explained in the model was the binary variable "happiness" divided into 2 categories: very happy and unhappy. The model is well suited to the data and the analysis of the maximum reliability and chance quotients allowed to confirm that the assumptions made in the research hypotheses for the studied group are true.
