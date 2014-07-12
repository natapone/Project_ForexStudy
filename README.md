# Project Forex Fast Forecast Study
Study relationship between technical indicators and future Forex price

## Background
Technical analysis is a methodology for forecasting  the direction of prices through past market data, primarily price and volume. Technical indicator normally apply to daily data. It would be interesting if we try to apply a minute data which much more variant and uncertainty.

### Technical indicator
Technical indicator has ability to reflect current status of price. Technical analysis uses indicators to help identify momentum, trends and volatility. Prediction power comes from analyser who interprete the signal. 

## Hypothesis
We try to proof that technical indicator has enough power to predict the price in future. We will use very short time scale (1 minute period) to show how well this system handle inconsistent data.


## Scope of study
In this study, we will use intelligent system to put indicator's signal together and forecast future price in form of [Rate of Return](http://en.wikipedia.org/wiki/Rate_of_return).

### List of indicators
Indicators which identify momentum, trends and volatility from price and volume.

* [RSI](http://stockcharts.com/school/doku.php?id=chart_school:technical_indicators:relative_strength_index_rsi): identifies momentum, determines overbought and oversold conditions.
* [MACD](http://stockcharts.com/school/doku.php?id=chart_school:technical_indicators:moving_average_convergence_divergence_macd): offers trend following and momentum.

* [ADX](http://stockcharts.com/school/doku.php?id=chart_school:technical_indicators:average_directional_index_adx) : measures trend strength without regard to trend direction.

* [BBand](http://stockcharts.com/school/doku.php?id=chart_school:technical_indicators:bollinger_bands): are volatility bands placed above and below a moving average.

* [MFI](http://stockcharts.com/school/doku.php?id=chart_school:technical_indicators:money_flow_index_mfi):  is an oscillator that uses both price and volume to measure buying and selling pressure.

### Price and volume data
We use USD - EUR exchange rate from [Exness](https://www.exness.com/) which is free and up to date.

### Forecast period
Target for forecasting is 15 minutes ahead which traders can plan their strategy and rate of return is significantly different.

## Study design

### 1) Define error measurement
We decide to use regression model because this study aims to forecast rate of return in next 15 minutes. Regression analysis usually applies root-mean-square error (RMSE) as an error measurement. It shows deviations of the predictions from the true values. Less number is preferred.

### 2) Split data
Amount of transaction for test and train is 6000 between 2014.06.03 to 2014.06.10. We split 60/40 for training/testing following rule of thumb.

### 3) Analyse features
The model uses indicator values as its feature. We plot all features against each others too 

*Execute R code*
```
# Prepare raw data
source("forex_study.R")`
data=get_caret_train_set("data/forex", "EURUSDe", "M1", 10000, n_period_forecast=15)
```

#### Plotting features
https://raw.githubusercontent.com/natapone/Project_ForexStudy/master/Images/plot_predictors.png
![GitHub Logo](https://raw.githubusercontent.com/natapone/Project_ForexStudy/master/Images/plot_predictors.png)

Focus on top rows, Rate of return (ROR) is plotted as **y**. We can roughly see that RSI, MFI and BBAND have similar relationship with ROR. MACD gathers around center , lower right and top left. ADX doesn't give any clue.

#### Simplify plot

Plots are simplify as Boxplot to easily determine if there is a relationship between indicator and rate of return or not. To Simplify the plot, ROR is grouped in to 6 levels and linear regression line is drew on them to indicate how does indicator response to reate of return.

#### RSI
![Simplify plot RSI](https://raw.githubusercontent.com/natapone/Project_ForexStudy/master/Images/plot_simplify_RSI.png)

#### ADX
![Simplify plot ADX](https://raw.githubusercontent.com/natapone/Project_ForexStudy/master/Images/plot_simplify_ADX.png)

#### MACD
![Simplify plot MACD](https://raw.githubusercontent.com/natapone/Project_ForexStudy/master/Images/plot_simplify_MACD.png)

#### MFI
![Simplify plot MFI](https://raw.githubusercontent.com/natapone/Project_ForexStudy/master/Images/plot_simplify_MFI.png)

#### BBAND
![Simplify plot BBAND](https://raw.githubusercontent.com/natapone/Project_ForexStudy/master/Images/plot_simplify_BBAND.png)

Now we can verify that ADX give no information about rate of return.

## Machine learning
We choose generalized linear model (GLM) because it is flexible generalization for ordinary linear regression.

### Training
*Execute R code*
```
forex_train_model(data)
```
**Result of GLM training**
*Measure GLM RMSE*
```
Generalized Linear Model 

3552 samples
   5 predictors

No pre-processing
Resampling: Bootstrapped (25 reps) 

Summary of sample sizes: 3552, 3552, 3552, 3552, 3552, 3552, ... 

Resampling results

  RMSE      Rsquared  RMSE SD   Rsquared SD
  0.000222  0.708     1.38e-05  0.0315     

```

### Testing
RMSE number is good for comparing model. but it doesn't give any picture of how well it predict. We interprete the result by;

* If rate of return > 0, count as **PROFIT (1)**

* If rate of return <= 0, count as **LOSE (-1)**

And plot confusion matrix to visualization of the performance of an algorithm.

*Measure GLM accuracy*
```
Confusion Matrix and Statistics

          Reference
Prediction   -1    1
        -1 1015  200
        1   230  920
                                         
               Accuracy : 0.8182         
                 95% CI : (0.802, 0.8335)
    No Information Rate : 0.5264         
    P-Value [Acc > NIR] : <2e-16         
                                         
                  Kappa : 0.6358         
 Mcnemar's Test P-Value : 0.162          
                                         
            Sensitivity : 0.8153         
            Specificity : 0.8214         
         Pos Pred Value : 0.8354         
         Neg Pred Value : 0.8000         
             Prevalence : 0.5264         
         Detection Rate : 0.4292         
   Detection Prevalence : 0.5137         
      Balanced Accuracy : 0.8183         
                                         
       'Positive' Class : -1    
```
GLM model accuracy from estimation above is 81.8% which is quite high. But there is a room for improvement

#### Visualize prediction result
We plot prediction result against actual rate of return to show how effective the algorithm is. The diagonal line(red) is ideal condition, dot closer to the line is preferred. Linear regression line(blue) of the plot shows relationship between prediction and actual. Blue line should be on red line in ideal case.

*Prediction result vs test set of GLM*
![prediction result vs test set](https://raw.githubusercontent.com/natapone/Project_ForexStudy/master/Images/predict_result_vs_test_set_glm.png)

## Improvement
We analyse in further detail to optimize the model.

### Improvement1: remove non-information input
Simplify plots show that ADX give no relationship to rate od return. RSI, MFI and BBAND return similar pattern. We can remove some indicators to keep model as simple as possible. We rebuild model again with RSI and MACD then look at the result.

*Execute R code*
```
d1 = model_improve_1(data)
```

*Measure RMSE of GLM improvement*
```
Generalized Linear Model 

3552 samples
   2 predictors

No pre-processing
Resampling: Bootstrapped (25 reps) 

Summary of sample sizes: 3552, 3552, 3552, 3552, 3552, 3552, ... 

Resampling results

  RMSE      Rsquared  RMSE SD   Rsquared SD
  0.000224  0.7       1.41e-05  0.0312     
```

*Measure accuracy*
``` 
Confusion Matrix and Statistics

          Reference
Prediction   -1    1
        -1 1021  156
        1   224  964
                                          
               Accuracy : 0.8393          
                 95% CI : (0.8239, 0.8539)
    No Information Rate : 0.5264          
    P-Value [Acc > NIR] : < 2.2e-16       
                                          
                  Kappa : 0.6787          
 Mcnemar's Test P-Value : 0.0005881       
                                          
            Sensitivity : 0.8201          
            Specificity : 0.8607          
         Pos Pred Value : 0.8675          
         Neg Pred Value : 0.8114          
             Prevalence : 0.5264          
         Detection Rate : 0.4317          
   Detection Prevalence : 0.4977          
      Balanced Accuracy : 0.8404          
                                          
       'Positive' Class : -1  
```

*Prediction result vs test set of GLM improvment*
![prediction result vs test set](https://raw.githubusercontent.com/natapone/Project_ForexStudy/master/Images/predict_result_vs_test_set_glm_improve1.png)

The result shows that RMSE is slightly increase but accuracy is about 2% increase even we remove three indicators. We can use only RSI and MACD to build the model without decrease its prediction power.

### Improvement2: Non linear model
Take a look at RSI vs ROR closely, we can see that the relationship is not linear. We plot regression line again with non-linear smoothing technique.

*Plot non-linear RSI*
![Scatter plot RSI vs rate of return, lowess smoothing](https://raw.githubusercontent.com/natapone/Project_ForexStudy/master/Images/predict_result_vs_test_set_glm_improve1.png)

We use [svmPoly](http://en.wikipedia.org/wiki/Polynomial_kernel) or Support Vector Machines with Polynomial Kernel which is non linear model. 

*Execute R code*
```
model_improve_1(d1)
```

*Measure RMSE of svmPoly*
```
Support Vector Machines with Polynomial Kernel

3552 samples
   5 predictors

No pre-processing
Resampling: Bootstrapped (25 reps)

Summary of sample sizes: 3552, 3552, 3552, 3552, 3552, 3552, ...

Resampling results across tuning parameters:

  degree  scale  C     RMSE      Rsquared  RMSE SD   Rsquared SD
  1       0.001  0.25  3e-04     0.629     2.19e-05  0.0258    
  1       0.001  0.5   0.000274  0.667     2.02e-05  0.029     
  1       0.001  1     0.000253  0.685     1.85e-05  0.0322    
  1       0.01   0.25  0.000238  0.692     1.71e-05  0.0348    
  1       0.01   0.5   0.000234  0.693     1.6e-05   0.036     
  1       0.01   1     0.000232  0.693     1.58e-05  0.0367    
  1       0.1    0.25  0.000231  0.693     1.56e-05  0.0374    
  1       0.1    0.5   0.00023   0.693     1.56e-05  0.0376    
  1       0.1    1     0.00023   0.693     1.56e-05  0.0377    
  2       0.001  0.25  0.000273  0.668     2.02e-05  0.029     
  2       0.001  0.5   0.000253  0.686     1.85e-05  0.0321    
  2       0.001  1     0.00024   0.692     1.75e-05  0.0344    
  2       0.01   0.25  0.00023   0.701     1.67e-05  0.0373    
  2       0.01   0.5   0.000228  0.702     1.62e-05  0.0375    
  2       0.01   1     0.000227  0.702     1.63e-05  0.0382    
  2       0.1    0.25  0.000225  0.703     1.75e-05  0.0397    
  2       0.1    0.5   0.000225  0.703     1.77e-05  0.0398    
  2       0.1    1     0.000225  0.703     1.79e-05  0.0401    
  3       0.001  0.25  0.00026   0.681     1.91e-05  0.0309    
  3       0.001  0.5   0.000244  0.691     1.76e-05  0.0335    
  3       0.001  1     0.000236  0.695     1.69e-05  0.0353    
  3       0.01   0.25  0.000223  0.712     1.62e-05  0.037     
  3       0.01   0.5   0.00022   0.716     1.59e-05  0.0368    
  3       0.01   1     0.000218  0.721     1.6e-05   0.0359    
  3       0.1    0.25  0.000217  0.724     2.49e-05  0.0449    
  3       0.1    0.5   0.000219  0.72      2.82e-05  0.0445    
  3       0.1    1     0.000221  0.717     3.01e-05  0.0436    

RMSE was used to select the optimal model using  the smallest value.
The final values used for the model were degree = 3, scale = 0.1 and C = 0.25.

The optimal RMSE = 0.000218
```

*Measure accuracy of svmPoly*
```
Confusion Matrix and Statistics

          Reference
Prediction   -1    1
        -1 1043  152
        1   202  968
                                         
               Accuracy : 0.8503         
                 95% CI : (0.8353, 0.8645)
    No Information Rate : 0.5264         
    P-Value [Acc > NIR] : < 2.2e-16      
                                         
                  Kappa : 0.7005         
 Mcnemar's Test P-Value : 0.009206       
                                         
            Sensitivity : 0.8378         
            Specificity : 0.8643         
         Pos Pred Value : 0.8728         
         Neg Pred Value : 0.8274         
             Prevalence : 0.5264         
         Detection Rate : 0.4410         
   Detection Prevalence : 0.5053         
      Balanced Accuracy : 0.8510         
                                         
       'Positive' Class : -1
```

*Prediction result vs test set of svmPoly*
![prediction result vs test set](https://raw.githubusercontent.com/natapone/Project_ForexStudy/master/Images/predict_result_vs_test_set_svmPoly.png)

Changing model to non-linear improves 5% accuracy but slope of prediction result and actual is slightly worse.

### Improvement3: Partition data
M5 = Model Tree

regression trees Model
http://en.wikipedia.org/wiki/Regression_tree

Prediction trees use the tree to represent the recursive partition.

## Conclusion
Self fullfil prediction

