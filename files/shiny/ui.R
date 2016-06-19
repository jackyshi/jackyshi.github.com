library(shiny)

shinyUI(fluidPage(
  titlePanel("PGN on CMS"),
  sidebarLayout(
    
    sidebarPanel(
      fileInput('file1', 'Choose CSV File',
                accept=c('text/csv', 
                         'text/comma-separated-values,text/plain', 
                         '.csv')),
      sliderInput("n", "Strike Price:",
                  min = 0.5, max = 6, value = 2.5, step = 0.5)
      ),
      
    mainPanel(plotOutput("plot"))
  )
))
    