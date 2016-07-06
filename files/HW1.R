T<-1
n<-1000
dt<-T/n
d<-500
LHS<-rep(0,d)
RHS<-rep(0,d)

for(j in 1:d) {
  W<-rnorm(n+1)
  LHS[j]<-0
  for(i in 1:n) {
    Wt<-sum(W[1:i]*sqrt(dt))
    LHS[j]<-LHS[j]+(W[i+1]*sqrt(dt)*Wt)
  }
  
  RHS[j]<-((sum(W[1:n]*sqrt(dt)))^2-T)/2
}

plot(LHS,RHS)