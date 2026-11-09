library(shiny)
library(bslib)
source("../scripts/03_exploratory_analysis/01_eda.R", chdir = TRUE)

theme <- bs_theme(
    version=5,
    bg="#F5F5F5",
    fg="#111318",
    primary="#6d6a6aff"
)

# what the user sees
ui <- page_sidebar(
    title="F1 Analytics",
    theme=theme,
    sidebar = sidebar(
        h3("Navigation"),
        p("Overview"),
        p("Drivers"),
        p("Teams"),
        p("Correlations"),
        p("Predictions"),
        p("Model Performance")
    ),
    h3("Season Overview"),
    p("Historical Formula 1 data analysis."),
    navset_card_tab(
        nav_panel(
            title="Overview", 
            card(
                full_screen = TRUE,
                card_header("Grid vs Finishing Position Correlation"),
                card_body(tableOutput("correlations"))
            )
        ),
        nav_panel(title="Drivers", tableOutput("performance"))
    ),
    
)

# logics that executes the R code
server <- function(input, output, session) {
    output$correlations <- renderTable(
        {correlation_by_season}, 
        hover=TRUE,
        bordered=TRUE,
        align='c'
    )

    output$performance <- renderTable(
        {pilots_performance},
        hover=TRUE,
        bordered=TRUE,
        align='c'
    )
}

# combine the 2 previous components and initializes the app
shinyApp(ui=ui, server=server)