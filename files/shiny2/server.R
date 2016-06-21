library(shiny)
library(lubridate)
library(ggplot2)

VASICEKnegloglike<-function(param,data,times)
{ 
  n.obs<-length(data)
  dum<-sort.list(times)
  data<-data[dum]
  times<-times[dum]
  delta<-diff(times,1)
  mv<-data[1:(n.obs-1)]*exp(-param[2]*delta)+param[1]*(1-exp(-param[2]*delta))
  variance<-param[3]^2*(1-exp(-2*param[2]*delta))/(2*param[2])
  VASICEKnegloglike<--sum(log(dnorm(data[2:n.obs],mv,sqrt(variance))))/n.obs
}

MCCall<-function(d, T, Pparam, K, r0, rfree)
{
  ## simulation parameters 
  m <- as.integer(T * 52)          # subintervals
  dt <- T / m            # time difference in each subinterval
  f <- rep(0, d)         # payoff
  r <- matrix(rep(0, (m+1)*d), ncol = d) # initialize r
  r[1, ] <- r0           # set starting point 
  
  
  theta<-Pparam[1]
  kappa<-Pparam[2]
  sig<-Pparam[3]
  
  for (j in 1:d) {         # next trial 
    for (i in 2:(m + 1)) { # next time step 
      dr <- kappa*(theta-r[i-1, j])*dt + sig*sqrt(dt)*rnorm(1)
      r[i, j] <- r[i-1, j] + dr
    }
    f[j] <- exp(-rfree * T) * max(r[m+1,j] - K, 0)
  }
  
  EstiCall<-round(mean(f), 4)
  return(EstiCall)
}

MCDelta<-function(T,K, r, rfree)
{
  d<-500
  ru<-r+0.5
  rd<-r-0.5
  cu<-MCCall(d, T, VASparam , K, ru, rfree)
  cd<-MCCall(d, T, VASparam , K, rd, rfree)
  delt<-(cu-cd)/(ru-rd)
  return(delt)
}
  
# Load Raw data

spliceddata<-as.matrix(na.omit(read.csv("FRED-DSWP10-weekly.csv",na.strings = "#N/A", header = TRUE)))
obs<-as.numeric(spliceddata[,2])
N<-length(obs)-1
dt<-1/52
data<-obs[2:(N+1)]
lagdata<-obs[1:N]
dates<-decimal_date(as.Date(spliceddata[,1]))

VASparam<-c()
thetaadj<-0
kappadj<-0
sigmaadj<-0

KArray<-seq(0,6,0.5)
tstCall <- rep(0, length(KArray)) 

notePxPV<-0
ppRate<-0
rArray<-seq(0,6,0.5)

deltHedges<-data.frame()

shinyServer(function(input, output) {
  
  v <- reactiveValues(doEst = FALSE, doMC = FALSE, doMCPlot = FALSE, 
                      doStruct = FALSE, doHedge = FALSE)

  observeEvent(input$goEst, {
    v$doEst <- input$goEst
  })
  
  observeEvent(input$goMC, {
    v$doMC <- input$goMC
  })
  
  observeEvent(input$goStruct, {
    v$doStruct <- input$goStruct
  })
  
  observeEvent(input$goHedge, {
    v$doHedge <- input$goHedge
  })
  
  observeEvent(input$n, {
    v$doMCPlot <- TRUE
  })
  
  output$Vasicek <- renderTable({
    
    if (v$doEst == FALSE) return()
    
    # Closed form estimators
    
    bhat<-(sum(data*lagdata) - sum(data)*sum(lagdata)/N)/(sum(lagdata*lagdata) - sum(lagdata)*sum(lagdata)/N)
    kappahat<--log(bhat)/dt
    ahat<-sum(data)/N-bhat*sum(lagdata)/N
    thetahat<-ahat/(1-bhat)
    s2hat<-sum((data-lagdata*bhat-ahat)^2)/N
    sigmahat<-sqrt(2*kappahat*s2hat/(1-bhat^2))
    
    # use maximum likelihood estimation to adjust the parameter
    
    tstVAS<-optim(par=c(thetahat,kappahat,sigmahat),fn=VASICEKnegloglike,method = "BFGS",  data=obs,times=dates)
    
    VASparam<<-tstVAS$par
    
    thetaadj<<-round(tstVAS$par[1],6)
    kappadj<<-round(tstVAS$par[2],6)
    sigmaadj<<-round(tstVAS$par[3],6)
    
    # Compose data frame
    data.frame(
      Vasicek_Parameter = c("Theta_Hat", 
               "Kappa_Hat",
               "Sigma_Hat",
               "Theta_Adj", 
               "Kappa_Adj",
               "Sigma_Adj"),
      Value = as.character(c(round(thetahat,6),
                             round(kappahat,6),
                             round(sigmahat,6),
                             thetaadj, 
                             kappadj,
                             sigmaadj)), 
      stringsAsFactors=FALSE)
  })
  
  output$datplot <- renderPlot({
    
    if (v$doEst == FALSE) return()
    
    # plot the data (or more accurately, the short rate)
    
    #plot(dates[2:(N+1)],data,type='l', xlab="date", ylab="10 USD mid swap rate", main="10 USD mid swap rate 2000-2015")
    #abline(h=thetaadj, lty=3)
    #text(dates[30], thetaadj, round(thetaadj,4))
    
    res<-data.frame(Date=dates[2:(N+1)], Rate=data)
    ggplot(data=res, aes(x=Date, y=Rate)) +
      geom_line() +
      geom_hline(yintercept = thetaadj) + 
      annotate("text", label = round(thetaadj,4), x=dates[30], y=thetaadj, size=5, colour = "blue") +
      xlab("Date") +
      ylab("10 UsD swap rate") +
      ggtitle("10 USD swap rate 2000-2015") +
      theme(text = element_text(size=15))
  })
  
  output$MCvalues <- renderTable({
    
    if (v$doMC == FALSE) return()
    
    # Monte Carlo simulation
    d<-1000
    T<-3
    #KArray<-seq(0.5,6,0.5)
    r0<-obs[N+1]
    rfree<-0.008
    #tstCall <- rep(0, length(KArray)) 
    for(i in 1:length(KArray))
    {
      tstCall[i]<<-MCCall(d, T, VASparam , KArray[i], r0, rfree)
    }
    v$doMCPlot <- TRUE
    
    data.frame(
      call_price = tstCall,
      strike_price = KArray, 
      stringsAsFactors=FALSE)
  })
  
  output$callplot <- renderPlot({
    
    if (v$doMCPlot == FALSE) return()
    
    index<-as.integer(input$n/0.5)+1
    #plot(KArray,tstCall,type='l', xlab="Strike", ylab="Call Price", main="10 USD mid swap rate call price")
    #abline(v=KArray[index],h=tstCall[index], lty=3)
    #text(KArray[index], tstCall[index], tstCall[index])
    
    res<-data.frame(Strike=KArray, CallPx=tstCall)
    ggplot(data=res, aes(x=Strike, y=CallPx)) +
      geom_line() +
      geom_hline(yintercept = tstCall[index], linetype='dotdash') + 
      geom_vline(xintercept = KArray[index], linetype='dotdash') + 
      annotate("text", label = tstCall[index], x=KArray[index], y=tstCall[index], size=5, colour = "blue") +
      xlab("Strike") +
      ylab("Call Price") +
      ggtitle("10 USD mid swap rate call pice") +
      theme(text = element_text(size=15))
  })
  
  output$prate <- renderText({
    
    if (v$doStruct == FALSE) return
    
    T<-3
    rfree<-0.008
    notePxPV<<-as.numeric(input$par)+T*as.numeric(input$coupon)
    cDiscount<-0
    for(i in 1:T)
      cDiscount<-cDiscount+as.numeric(input$coupon)*exp(-rfree*i)
    pDiscount<-as.numeric(input$par)*exp(-rfree*T)
    
    index<-as.integer(as.numeric(input$strike)/0.5)+1
    
    if(tstCall[index]>0){
      ppRate<<-(notePxPV-cDiscount-pDiscount)/tstCall[index]
    }
    ppRate
  })
  
  output$notePX <- renderText({
    if (v$doStruct == FALSE) return
    
    as.integer(notePxPV)
  })
  
  output$noteplot <- renderPlot({
    if (v$doStruct == FALSE) return
    
    if (is.finite(ppRate) && ppRate>0){
      
      payOff <- rep(0, length(rArray)) 
      for(i in 1:length(rArray)){
        payOff[i]<-notePxPV+max(rArray[i]-as.numeric(input$strike),0)*ppRate
      }
      
      #plot(rArray,payOff,type='l', xlab="Swap Rate", ylab="Payoff", main="Payoff of PGN")
    
      res<-data.frame(rate=rArray, pf=payOff)
      ggplot(data=res, aes(x=rate, y=pf)) +
        geom_line() +
        xlab("Swap Rate") +
        ylab("Payoff") +
        ggtitle("Payoff of PGN") +
        theme(text = element_text(size=15))
    }
  })
  
  output$DHvalues <- renderTable({
    
    if (v$doHedge == FALSE) return()
    
    d<-12
    dt<-1/d
    m<-3*d
    rfree<-0.008
    r <- rep(0,m)  
    delt <- rep(0,m+1)  
    cash <- rep(0,m+1)
    r[1] <- obs[N+1]        # set starting point 
    delt[1] <- MCDelta(3, input$strike, r[1], rfree)
    cash[1] <- 100
    
    for(i in 1:(m-1)) {
      dr <- kappadj*(thetaadj-r[i])*dt + sigmaadj*sqrt(dt)*rnorm(1)
      r[i+1] <- r[i] + dr
      tau<-(m-i)/d
      delt[i+1]<- MCDelta(tau, input$strike, r[i+1], rfree)
      cash[i+1]<- exp(rfree*dt)*cash[i] - (delt[i+1]-delt[i])*r[i+1]
    }
    
    HedgeValue=exp(rfree*dt)*cash[m] + delt[m]*r[m]
    cash[m+1] = HedgeValue - max(r[m]-2.5,0)
    
    if(r[m]> 2.5) {
      delt[m+1]=1
    } else {
      delt[m+1]=0
    }
  
    deltHedges<<-data.frame(
      Period = 0:m,
      Delta = delt, 
      Cash = cash,
      stringsAsFactors=FALSE)
  })
  
  output$dhplot <- renderPlot({
    
    if (v$doHedge == FALSE) return()
    #plot(deltHedges$Period,deltHedges$Cash,type='h', xlab="Period", ylab="Cash", main="Delta Hedge Cash Flow")
    
    res<-data.frame(pd=deltHedges$Period, dh=deltHedges$Cash)
    ggplot(data=res, aes(x=pd, y=dh)) +
      geom_bar(stat="identity") +
      xlab("Period") +
      ylab("Cash") +
      ggtitle("Delta Hedge Cash Flow") +
      theme(text = element_text(size=15))
  })
})