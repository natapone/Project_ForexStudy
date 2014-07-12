# USAGE
# source("forex_study.R")
# data=get_caret_train_set("data/forex", "EURUSDe", "M1", 10000, n_period_forecast=15)
# plot_predictors(data)
# plot_simplify(data)
# m  = forex_train_model(data)
# d1 = model_improve_1(data)
# model_improve_2(d1)
# model_improve_3(d1)

library(caret)
library("ggplot2")
library(quantmod)
library("Hmisc")
library("kernlab")
library("RWeka")

model_file_name = "hmm_forex_model"
model_file_type = "RData"

model_improve_3 <- function(data) {
    modelFit = forex_train_model(data, train_method="M5")
    return (modelFit)
}

model_improve_2 <- function(data) {
    modelFit = forex_train_model(data, train_method="svmPoly")
    return (modelFit)
}

model_improve_1 <- function(data) {
    
    # remove no information data (ADX)
    remove <- c("ADX", "MFI", "BBAND")
    d1 = data[,!(names(data) %in% remove)]
    
    modelFit = forex_train_model(d1, name_ext="improve1")
    return (d1)
}

forex_train_model <- function(data, train_test_ratio = 0.6, seed = 1234, train_method="glm", name_ext="") {
    set.seed(seed)
#     print(head(data))
    inTrain <- createDataPartition(y=data$ROR, p=train_test_ratio, list=FALSE)
    
    training <- data[inTrain,]
    testing  <- data[-inTrain,]
    
    # use simple Generalized linear model
    modelFit <- train(ROR ~.,data=training, method=train_method)
    print(modelFit)
    
#modelFit
    matrix = forex_test_model(modelFit, training, testing)
    print(matrix)
    message("===========")
    
    # plot predition result
    plot_predict_result_vs_test_set(modelFit, training, testing, name_ext=name_ext)

    return (modelFit)
}

forex_test_model <- function(modelFit, training, testing) {
    predictions <- predict(modelFit,newdata=testing)
    
    # simplify result
    # ROR > 0  is PROFIT
    # ROR <= 0 is LOSS
    
    pr = predictions
    pt = testing$ROR
    
    pr[pr > 0] = 1
    pr[pr <= 0] = -1
    
    pt[pt > 0] = 1
    pt[pt <= 0] = -1
    
    confusionMatrix(pr,pt)
    
}

# Measure accuracy from relationship between prediction result and test set
plot_predict_result_vs_test_set <- function(modelFit, training, testing, name_ext="") {
    
    predictions <- predict(modelFit,newdata=testing)
    
    pr = predictions
    pt = testing$ROR
    
    file_name = "images/predict_result_vs_test_set"
    file_name = paste(file_name, modelFit$method, sep="_")
    if( nchar(name_ext) > 0 ) {
        file_name = paste(file_name, name_ext, sep="_")
    }
    file_name = paste(file_name, "png", sep=".")
    
    message("Save: ", file_name)
    png(file_name, width = 800, height = 800)
    
    data = data.frame(
            "prediction" = pr,
            "actual" = pt
        )
    
    p_min = -0.005
    p_max = 0.005
    qq <- qplot(prediction,actual,data=data,
                xlim = c(p_min, p_max),
                ylim = c(p_min, p_max),
                xlab = "Predicted rate of return",
                ylab = "Actual rate of return"
            ) +
            geom_smooth(
                method='lm', formula=y~x) +
            geom_abline(intercept=0,slope=1,color="red")
    
# qq = ggplot(data, aes(x=prediction, y=actual)) +
#     geom_point(size=5) +    # Use hollow circles
#     geom_smooth(method=lm) + coord_fixed()
    
    print(qq)
    dev.off()
}

plot_predictors <- function(data) {
    png("images/plot_predictors.png", width = 1024, height = 1024)
    
    # Analyse relation ship between each predictor (indicator)
    qq = featurePlot(x=data[,c("RSI","ADX","MACD","MFI","BBAND")],
                y = data$ROR,
                plot="pairs", pch=20,cex=0.25)
    
    print(qq)
    dev.off()
}

plot_simplify <- function(data, path ="images") {
    
    predictor_name = colnames(data)
    # remove Rate of return
    remove = c ("ROR")
    predictor_names = predictor_name [! predictor_name %in% remove]
    
    # loop plot predictors
    for (idx in 1:length(predictor_names)) {
        
        p_name = predictor_names[idx]
        file_name = paste("plot_simplify", p_name, sep = "_")
        file_name = paste(file_name, "png", sep = ".")
        file_name = paste(path, file_name, sep = "/")
        
        message("Save: ", file_name)
        png(file_name, width = 800, height = 400)
        
        # simplify rate of return
        cutROR <- cut2(data$ROR,g=6)
        
        qq = qplot(cutROR,data[,idx], data=data,
                   fill=cutROR,
                   geom=c("boxplot"),
                   xlab = "Rate of return levels",
                   ylab = p_name
        ) +
        geom_smooth(method='lm',formula=y~x,aes(group = 1)) 
#         + theme(legend.position="none")
        
        print(qq)
        dev.off()
    }
}

plot_non_linear <- function(data, path ="images") {
    
    predictor_name = colnames(data)
    # remove Rate of return
    remove = c ("ROR")
    predictor_names = predictor_name [! predictor_name %in% remove]
    
    # loop plot predictors
    for (idx in 1:length(predictor_names)) {
        
        p_name = predictor_names[idx]
        file_name = paste("plot_non_linear", p_name, sep = "_")
        file_name = paste(file_name, "png", sep = ".")
        file_name = paste(path, file_name, sep = "/")
        
        message("Save: ", file_name)
        png(file_name, width = 800, height = 400)
        
        qq <- qplot(data$ROR,data[,idx],data=data) +
        geom_smooth(method='auto' )
        
        print(qq)
        dev.off()
    }
    
}

get_caret_train_set <- function(directory, symbol, timeframe, period, n_period_forecast=7) {
    # read from file
    p = read_symbol_data(directory, symbol, timeframe)
    
    ind_observe = n_period_forecast * 2
    ind_std_size = ind_observe * 3 # size of data affects level of momentum indicator
    period = period + ind_std_size
    
    # limit period
    data_count = nrow(p)
    index_start = 0
    if(data_count > period) {
        index_start = data_count - period + 1
    }
    
    p = p[complete.cases(p),]
    p = p[index_start:data_count, ]
    
    data_count = nrow(p)
    p_na = rep(NA, ind_std_size-1)
    p_rsi = p_na
    p_adx = p_na
    p_macd = p_na
    p_mfi = p_na
    p_bband = p_na
    
    for (idx in 1:(data_count - ind_std_size + 1) ) {
        p_sub = p[idx:(idx+ind_std_size-1),]
        
        # Prices object: high, low, close
        hlc <- data.frame(High = p_sub$high, Low = p_sub$low, Close = p_sub$close)
        
        # Indicators by subset
        p_sub_rsi = RSI(p_sub[,"close"], n=ind_observe)
        p_sub_adx = ADX(hlc, n=ind_observe)
        p_sub_macd = MACD(p_sub[,"close"], percent = TRUE)
        p_sub_mfi = MFI(hlc, volume=p_sub$volumn, n=ind_observe)
        p_sub_bband = BBands(hlc, n=ind_observe)
        
        p_rsi = append(p_rsi, p_sub_rsi[ind_std_size])
        p_adx = append(p_adx, p_sub_adx[ind_std_size, "ADX"])
        p_macd = append(p_macd, p_sub_macd[ind_std_size, "macd"] - p_sub_macd[ind_std_size, "signal"]  )
        p_mfi = append(p_mfi, p_sub_mfi[ind_std_size])
        p_bband = append(p_bband, p_sub_bband[ind_std_size, "pctB"])
        
    }
    
    # rate of return
    p_forecast_close = Delt(p[,"close"], k=n_period_forecast, type='log')
    
    message("Count indicator = ", length(p_rsi))
    
    # Create trainig set 
    p_ret = data.frame(
        "RSI"       = p_rsi,
        "ADX"       = p_adx,
        "MACD"      = p_macd,
        "MFI"       = p_mfi,
        "BBAND"     = p_bband,
#         "type"     = p_forecast_close[,1]
        "ROR"     = p_forecast_close[,1]
    )
    
    p_ret = p_ret[complete.cases(p_ret),]
    
    return(p_ret)
    
}

read_symbol_data <- function(directory, symbol, timeframe) {
    symbol_path <- read_symbol_path(directory, symbol, timeframe)
    message("Read symbol: ", symbol_path)
    
    # read data for each symbol
    con <- file(symbol_path, "r")
    symbol_data <- read.csv(con, header=F,)
    close.connection(con)
    
    # set column name
    colnames(symbol_data) <- c("date", "time", "open", "high", "low", "close", "volumn")
    symbol_data
}

read_symbol_path <- function(directory, symbol, timeframe) {
    
    file_name <- paste(symbol,timeframe_to_sec(timeframe),  sep = "")
    file_name <- paste(file_name,"csv", sep = ".")
    file_path <- paste(directory, file_name, sep = "/")
    
    #     message("Read file: ", file_path)
    file_path
}

# period to file name
# M1, M5, M15, H1 ,H4, D1, W1, MN
timeframe_to_sec <- function(p) {
    switch(p, 
           M1 = {
               return(1)},
           M5 = {
               return(5)},
           H1 = {
               return(60)},
           D1 = {
               return(1440)},
{
    return(0)
}
    )
}

save_model <- function (hm_model, file = model_file_name) {
    saveRDS(m, file)
}

load_model <- function (file = model_file_name) {
    readRDS(file)
}

resetPar <- function() {
    dev.new()
    op <- par(no.readonly = TRUE)
    dev.off()
    op
}