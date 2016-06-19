setwd("D:/MFIN7009/project")

library(lubridate)

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


MCCall<-function(n, T, Pparam, K, r0, rfree)
{
  ## simulation parameters 
  m <- T * 52           # subintervals
  dt <- T / m            # time difference in each subinterval
  f <- rep(0, n)         # payoff
  r <- matrix(rep(0, (m+1)*n), ncol = n) # initialize r
  r[1, ] <- r0           # set starting point 
  
  
  theta<-Pparam[1]
  kappa<-Pparam[2]
  sig<-Pparam[3]
  
  for (j in 1:n) {         # next trial 
    for (i in 2:(m + 1)) { # next time step 
      dr <- kappa*(theta-r[i-1, j])*dt + sig*sqrt(dt)*rnorm(1)
      r[i, j] <- r[i-1, j] + dr
    }
    f[j] <- exp(-rfree * T) * max(r[m+1,j] - K, 0)
  }
  
  EstiCall<-round(mean(f), 4)
  return(EstiCall)
}

# Load Raw data

spliceddata<-as.matrix(na.omit(read.csv("FRED-DSWP10-weekly.csv",na.strings = "#N/A", header = TRUE)))
obs<-as.numeric(spliceddata[,2])
N<-length(obs)-1
dt<-1/52
data<-obs[2:(N+1)]
lagdata<-obs[1:N]
dates<-decimal_date(as.Date(spliceddata[,1]))


# Closed form estimators

bhat<-(sum(data*lagdata) - sum(data)*sum(lagdata)/N)/(sum(lagdata*lagdata) - sum(lagdata)*sum(lagdata)/N)
kappahat<--log(bhat)/dt
ahat<-sum(data)/N-bhat*sum(lagdata)/N
thetahat<-ahat/(1-bhat)
s2hat<-sum((data-lagdata*bhat-ahat)^2)/N
sigmahat<-sqrt(2*kappahat*s2hat/(1-bhat^2))

# use maximum likelihood estimation to adjust the parameter

tstVAS<-optim(par=c(thetahat,kappahat,sigmahat),fn=VASICEKnegloglike,method = "BFGS",  data=obs,times=dates)
thetaadj<-tstVAS$par[1]
kappadj<-tstVAS$par[2]
sigmaadj<-tstVAS$par[3]

# plot the data (or more accurately, the short rate)

plot(dates[2:(N+1)],data,type='l', xlab="date", ylab="10 USD mid swap rate", main="10 USD mid swap rate 2000-2015")
abline(h=thetaadj, lty=3)
text(dates[30], thetaadj, round(thetaadj,4))

# Monte Carlo simulation
n<-2000
T<-3
KArray<-seq(0.5,6,0.5)
r0<-obs[N+1]
rfree<-0.08
tstCall <- rep(0, length(KArray)) 
for(i in 1:length(KArray))
{
  tstCall[i]<-MCCall(n, T, tstVAS$par, KArray[i], r0, rfree)
}
plot(KArray,tstCall,type='l', xlab="Strike", ylab="Call Price", main="10 USD mid swap rate call price")
abline(v=KArray[5],h=tstCall[5], lty=3)
text(KArray[5], tstCall[5], tstCall[5])

dat = data.frame(callprice = tstCall, strikeprice = KArray)
ggplot(dat, aes(strikeprice, y=callprice)) +
  geom_area(fill="navyblue", colour="white", alpha=0.5)

