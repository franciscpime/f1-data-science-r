library(shiny)

# what the user sees
ui <- fluidPage(
    titlePanel("My First Shiny App"),
    p("Hello, Formula 1!")
)

# logics that executes the R code
server <- function(input, output, session) {
    
}

# combine the 2 previous components and initializes the app
shinyApp(ui=ui, server=server)