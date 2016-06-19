library(shiny)

shinyUI(fluidPage(
  titlePanel("Capital Gurantee Note - 10yr Constant Maturity Swap"),
  sidebarLayout(
    
    sidebarPanel(
      h4("Model Swap Rate"),
      actionButton("goEst", "Do Vasicek Maximum Likelihood Estimation"),
      h4("Call Price Simulation"),
      actionButton("goMC", "Do Monte Carlo Simulation"),
      sliderInput("n", "Strike Price:",
                  min = 0.5, max = 5, value = 2.5, step = 0.5),
      h4("PGN Struture (3 year)"),
      column(6,textInput("coupon", "Coupon", value=1)),
      column(6,textInput("par", "Par", value=100)),
      sliderInput("strike", "Strike Price:",
                  min = 0.5, max = 5, value = 2.5, step = 0.5),
      actionButton("goStruct", "Structure Note"),
      h4("Delta Hedge"),
      actionButton("goHedge", "Simulate Delta Hedge"),
      br()
      
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Model Swap Rate",
          column(4,
            tableOutput("Vasicek")
          ),
          column(8,
            plotOutput("datplot")
          )
        ),
        tabPanel("Call Price Simulation",
          column(3,
            tableOutput("MCvalues")
          ),
          column(9,
            plotOutput("callplot")
          )
        ),
        tabPanel("PGN Struture",
         column(3,
            p("Participation Rate"),
            verbatimTextOutput("prate"),
            p("Note Price"),
            verbatimTextOutput("notePX")
         ),
         column(9,
            plotOutput("noteplot")
         )
        ),
        tabPanel("Delta Hedge",
          column(3,
            tableOutput("DHvalues")
          ),
          column(9,
            plotOutput("dhplot")
          )
        )
      )
    )
  )
))
