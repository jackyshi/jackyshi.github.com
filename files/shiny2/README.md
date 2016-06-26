## Capital Guarantee Note - 10yr Constant Maturity Swap ##
**version: 1.01**

### Introduction ###
This program contains all functions for structuring PGN, which includes 
Vasicek parameter estimation, calculate the Call Option price by Monte 
Carlo simulation, Participation Rate calculation and Delta Hedge simulation.

### Structure ###
All codes are written by R with Shiny(A web application framework).
"code" directory contains codes for both server-side (server.R) and 
client-side (ui.R).
"data" directory contains the weekly data of 10 year swap rate for 16 years
(FRED-DSWP10-weekly.csv).

- code 
	- server.R
	- ui.R
- data
	- FRED-DSWP10-weekly.csv 

### Run the program ###
**1. Please copy folder "code" and "data" to your own folder.**

e.g. "D:\MFIN7009\project" and then open RStudio, and run below command.

     >library(shiny)
     >runApp("D:/MFIN7009/project")

**2. Estimate Vasicek parameter by OLS and MLE.**

1. Click "Do Vasicek OLS and MLE" button on left panel.
2. The result will be shown on tab "Model Swap Rate" on right panel.
      
>OLS result: "Theta_Hat", "Kappa_Hat", "Sigma_Hat"

>MLE result: "Theta_Adj", "Kappa_Adj", "Sigma_Adj"

**3. Calculate the Call Option price by Monte Carlo simulation.**

1. Click "Do Monte Carlo Simulation" button on left panel.
2. The result will be shown on tab "Call Price Simulation" on right panel.
3. Drag the slider "Strike Price", you will see the Call price for each strike.

p.s. You can adjust the number of trails by change line 179 in "server.R"

    d<-1000

**4. Structure the Principal Guaranteed Notes.**

1. Enter "coupon" and "par" on left panel
2. Click "Structure Note" button on left panel.
3. The result will be shown on tab "PGN Structure" on right panel.
4. Drag the slider "Strike Price", you will see the participation rate be 
adjusted for different call, and the payoff is floored by the guarantee price.

**5. Delta Hedge simulation.**

1. Click "Simulate Delta Hedge" button on left panel.
2. The result will be shown on tab "Delta Hedge" on right panel.

p.s. Since the program numerically calculates the delta, 
you can adjust the number of trails by change line 81 in "server.R"

    d<-500

### Bug Fixes ###

After the presentation, we made below enhancements based on the feedback.

1. Use "set.seed()" in Monte Carlo simulation to gurantee same set of random
number being used for simulation.
2. Count the transaction fee for each delta hedge transaction.