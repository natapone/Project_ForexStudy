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
![GitHub Logo](https://raw.githubusercontent.com/natapone/Project_ForexStudy/master/Images/plot_predictors.png)

#### Simplify plot

## Machine learning


### Training
Training glm

### Testing
Testing 
>0
<= 0

## Improvement
not linear

Train with different algorithm

SVM

M5

## Conclusion
Self fullfil prediction

