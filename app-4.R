# Module 6 Assignment3
# Foley, Kevin
# Creating a Shiny App with Functions and a Dynamic Plot 

#library(ggthemes)

#---------------------these are to be loaded into console -----------------------------------------------------------------------------------
#install.packages("vroom")
#dir.create("neiss") #create a new directory names "neiss"
#lets download some files into the new dir "neiss"

#download <- function(name) {
#  url <- "https://github.com/hadley/mastering-shiny/raw/master/neiss/"
#  download.file(paste0(url, name), paste0("neiss/", name), quiet = TRUE)
#}
#download("injuries.tsv.gz")  #These are the slower original way to download the files
#download("population.tsv")
#download("products.tsv")
#----------------------------------------------------------------------------------------------------------------------------
# Libraries
library(shiny)
library(vroom)
library(tidyverse)
library(bslib)
# library(rsconnect)
#     rsconnect::deployApp('/app-4.R')

injuries <- vroom::vroom("neiss/injuries.tsv.gz") # this is the faster way to download larger files
products <- vroom::vroom("neiss/products.tsv")
population <- vroom::vroom("neiss/population.tsv")




# GUI-------------------------------------------------------------------------------------------------------------------------
ui <- fluidPage(
  theme = bs_theme(version = 4, bootswatch = "cyborg"), # changes the background, buttons, text
  fluidRow(column(  #Fluid row puts the items on the same row, a column has 12 wide?
    4,
    selectInput(
      "code",
      "Product",
      choices = setNames(products$prod_code, products$title),
      width = "100%"
    )
  ),
  column(4, selectInput(
    "y", "Y axis", c("rate", "count")
  )),
  column(4, numericInput("majic", "How many Rows?", value = 5, min = 0, max = 10)),  # this is the change number of rows 
  ),
  #fluidRow(
   # column(4, actionButton("story", "Tell me a story" , icon("skull-crossbones"), # I thought this was pretty funny
  #  ,style= "color: #fff ; background-color: #135CC5 ;border-color: #FFF77A"  #337ab7  #2e6da4
   # )),
  #  column(10, textOutput("narrative"))),
    
  #fluidRow(column(8,selectInput("code", "Product", choices = products$prod_code,products$title,width = "100%")),
  #       column(2,selectInput("y","Y axis",c("rate" ,"count")))),
  fluidRow(
    column(4, tableOutput("diag")),
    column(4, tableOutput("body_part")),
    column(4, tableOutput("location"))
  ),
  fluidRow(column(12, plotOutput("age_sex"))),
  #action button on the bottom
  fluidRow(column(2, actionButton(
    "story", "Tell me a story",  icon("skull-crossbones"), # I thought this was pretty funny
    style= "color: #fff ; background-color: #135CC5 ;border-color: #FFF77A"  #337ab7  #2e6da4
  )),
  column(10, textOutput("narrative")))
)
#-----------------------------------------GUI----End--------------------------------------------------------------------------

# Server----------------------------------------------------------------------------------------------------------------------
server <- function(input, output, session) {
  count_top <- function(df, var, n = 5) {  #Not sure how to get a selected input into here for n
    df %>% 
      mutate({{ var }} := fct_lump(fct_infreq({{ var }}), n = n)) %>%
      group_by({{ var }}) %>%
      summarise(n = as.integer(sum(weight)))
  }
  prod_codes <- setNames(products$prod_code, products$title)
  
  #this solved the issue for numeric input
  table_input <- reactive(input$majic)  # this needs to be called as a function to update the # of rows...
  
    selected <- reactive(injuries %>% filter(prod_code == input$code))
  output$diag <-
    renderTable(count_top(selected(), diag, n = table_input()), width = "100%")
  output$body_part <-
    renderTable(count_top(selected(), body_part, n = table_input()), width = "100%")
  output$location <-
    renderTable(count_top(selected(), location, n = table_input()), width = "100%")
  
  #output$diag <- renderTable(selected() %>% count(diag, wt = weight, sort = TRUE))
  #output$body_part <- renderTable(selected() %>% count(body_part, wt = weight, sort = TRUE))
  #output$location <- renderTable(selected() %>% count(location, wt = weight, sort = TRUE))
  summary <- reactive({
    selected() %>%
      count(age, sex, wt = weight) %>%
      left_join(population, by = c("age", "sex")) %>%
      mutate(rate = n / population * 1e4)
  })
  output$age_sex <- renderPlot({
    if (input$y == "count") {
      summary() %>%
        ggplot(aes(age, n, colour = sex)) +
        geom_line() +
        labs(y = "Estimated number of injuries")+
        #theme_economist() 
        theme(strip.background = element_rect( fill = "gray"),
              plot.background = element_rect(fill = "gray"))
    } else {
      summary() %>%
        ggplot(aes(age, rate, colour = sex)) +
        geom_line(na.rm = TRUE) +
        labs(y = "Injuries per 10,000 people")+
        #theme_economist() 
        theme(strip.background = element_rect( fill = "gray"),
              plot.background = element_rect(fill = "gray"))
    }
  }, res = 96)
  
  narrative_sample <- eventReactive(list(input$story, selected()),   #this only works when the button is pushed
                                    selected() %>% pull(narrative) %>% sample(1))
  output$narrative <- renderText(narrative_sample())
  
}
  #output$age_sex <- renderPlot({summary() %>%  # original script
  #    ggplot(aes(age, n, colour = sex)) +
   #   geom_line() +
  #    labs(y = "Estimated number of injuries")
  #}, res = 96)
#}
#-------------------------------------------------SERVER---END----------------------------------------------------------------

# Run the application 
shinyApp(ui = ui, server = server)