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
```
forex_train_model(data)
```
**Result**
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

### Testing
RMSE number is good for comparing model. but it doesn't give any picture of how well it predict. We interprete the result by;

* If rate of return > 0, count as **PROFIT (1)**

* If rate of return <= 0, count as **LOSE (-1)**

And plot confusion matrix to visualization of the performance of an algorithm.

## Improvement
not linear

Train with different algorithm

SVM

M5

## Conclusion
Self fullfil prediction

