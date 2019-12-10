#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

library(httr)
library(tidyverse)
library(jsonlite)
library(shiny)

get_sources <- function(category='', api_key=NULL) {
    if (!is.character(category) | length(category)==0) {
        stop('Please input valid category')
    }
    if (length(category)>1) {
        stop('Only one category is accepted')
    }
    if (!category %in% c('business', 'entertainment', 'general', 'health', 'science', 'sports', 'technology')) {
        stop('category must be one of business, entertainment, general, health, science, sports, technology')
    }
    if (is.null(api_key)) {
        stop('api_key must not be NULL')
    }
    url <- paste0("https://newsapi.org/v2/sources?category=", category, "&language=en&country=us&apiKey=", api_key)
    r <- content(GET(url))
    if (r$status == 'error') {
        stop(paste0(r$code, '\n', 'Error Message: ', r$message))
    } else {
        df <- as.tibble(do.call(rbind, r$sources))
        if (nrow(df) == 0) {
            return(df)
        } else {
            df <- df %>%
                unnest(colnames(df)) %>%
                filter(name %in% c('CNN', 'Fox News', 'The Wall Street Journal', 'Reuters'))
            return(df)
        }
    }
}

check_sources <- function(sources) {
    if (!is.character(sources) | length(sources)==0) {
        stop('please input valid sources')
    }
    for (i in seq_along(sources)) {
        if (!sources[i] %in% c('cnn', 'fox-news', 'the-wall-street-journal', 'reuters')) {
            stop('sources should only be a subset of cnn, fox-news, the-wall-street-journal, and reuters')
        }
    }
}

get_headlines <- function(sources=c('cnn', 'fox-news', 'the-wall-street-journal', 'reuters'), q="", page_size=20, page=1, api_key=NULL) {
    check_sources(sources)
    #if (!is.character(q)) {
    #stop('q should be a string')
    #}
    if (!is.numeric(page_size) | page_size<=0 | page_size>100 | as.integer(page_size)!=page_size) {
        stop('page_size should be a positive integer less or equal than 100')
    }
    if (!is.numeric(page) | page<=0 | as.integer(page)!=page) {
        stop('page should be a positive integer')
    }
    if (is.null(api_key)) {
        stop('api_key must not be NULL')
    }
    url <- paste0("https://newsapi.org/v2/top-headlines?country=us&q=", q, "&pageSize=", page_size, "&page=", page, "&apiKey=", api_key)
    r <- content(GET(url))
    if (r$status == 'error') {
        stop(paste0(r$code, '\n', 'Error Message: ', r$message))
    } else {
        df <- as.tibble(do.call(rbind, r$articles))
        if (nrow(df) == 0) {
            return(df)
        } else {
            df$id <- lapply(df$source, `[[`, 'id')
            df$name <- lapply(df$source, `[[`, 'name')
            df <- df %>%
                select(-source)
            df <- df %>%
                unnest(colnames(df)) %>%
                filter(id %in% sources)
            return(df)
        }
    }
}

get_dttm <- function(dttm) {
    if ((!is.null(dttm)) & (dttm!="")) {
        if (!is.character(dttm)) {
            stop('from and to should be a valid date or date time if specificed')
        } else if (!is.na(as.POSIXct(dttm, format="%Y-%m-%dT%H:%M:%OS"))) {
            return(format(as.POSIXct(dttm, format="%Y-%m-%dT%H:%M:%OS"), "%Y-%m-%dT%H:%M:%OS"))
        } else if (!is.na(as.Date(dttm, format="%Y-%m-%d"))) {
            return(as.Date(dttm, format="%Y-%m-%d"))
        } else {
            stop('from and to should be a valid date or date time in the form like 2019-11-18 or 2019-11-18T07:13:34')
        }
    } else {
        return(NULL)
    }
}

get_historic <- function(q="", q_title="", sources=c('cnn', 'fox-news', 'the-wall-street-journal', 'reuters'), from=NULL, to=NULL, sort_by="publishedAt", page_size=20, page=1, api_key=NULL) {
    check_sources(sources)
    sources <- paste(sources, collapse=',')
    from <- get_dttm(from)
    to <- get_dttm(to)
    if (!sort_by %in% c('relevancy', 'popularity', 'publishedAt')) {
        stop('sort_by must be one of relevancy, popularity, publishedAt')
    }
    if (!is.numeric(page_size) | page_size<=0 | page_size>100 | as.integer(page_size)!=page_size) {
        stop('page_size should be a positive integer less or equal than 100')
    }
    if (!is.numeric(page) | page<=0 | as.integer(page)!=page) {
        stop('page should be a positive integer')
    }
    if (is.null(api_key)) {
        stop('api_key must not be NULL')
    }
    url <- paste0("https://newsapi.org/v2/everything?q=", q, "&qInTitle=", q_title, "&sources=", sources, "&from=", from, "&to=", to, "&language=en&sortBy=", sort_by, "&pageSize=", page_size, "&page=", page, "&apiKey=", api_key)
    r <- content(GET(url))
    if (r$status == 'error') {
        stop(paste0(r$code, '\n', 'Error Message: ', r$message))
    } else {
        df <- as.tibble(do.call(rbind, r$articles))
        if (nrow(df)==0) {
            return(df)
        } else {
            df$id <- lapply(df$source, `[[`, 'id')
            df$name <- lapply(df$source, `[[`, 'name')
            df <- df %>%
                select(-source)
            df <- df %>%
                unnest(colnames(df)) 
            return(df)
        }
    }
}

news_key <- "a169100e35944348ba801c2a47862390"

# Define UI for application that draws a histogram
ui <- fluidPage(
    navbarPage(title="News Hub",
               tabPanel("Get Sources",
                        fluidRow(
                            column(width=2,
                                   radioButtons("sources_category", "Category", c('business', 'entertainment', 'general', 'health', 'science', 'sports', 'technology'))
                            ),
                            column(width=1,
                                   br(),br(),br(),br(),br(),br(),br(),br(),
                                   actionButton("sources_update", "Update")
                            )
                        ),
                        fluidRow(
                            br(),br(),br()
                        ),
                        fluidRow(
                            dataTableOutput("sources")
                        )
               ),
               tabPanel("Get Headlines",
                        sidebarLayout(
                            sidebarPanel(
                                checkboxGroupInput("headlines_sources", "Sources", c('cnn', 'fox-news', 'the-wall-street-journal', 'reuters'), selected=c('cnn', 'fox-news', 'the-wall-street-journal', 'reuters')),
                                textInput("headlines_q", "Search All", ""),
                                sliderInput("headlines_pagesize", "pagesize", 20, 100, 20),
                                sliderInput("headlines_page", "page", 1, 20, 1),
                                actionButton("headlines_update", "Update")
                            ),
                            mainPanel(
                                lapply(1:100, function(i) {
                                    conditionalPanel(condition = paste0("output.headlines_nrow>=", i),
                                                     fluidRow(
                                                         fluidRow(
                                                             column(width=2,
                                                                    htmlOutput(paste0("headlines_row", i, "_image"))
                                                             ),
                                                             column(width=10,
                                                                    htmlOutput(paste0("headlines_row", i)),
                                                                    br(),
                                                                    actionButton(paste0("headlines_row", i, "_readmore"), "Read More")
                                                             )
                                                         ),
                                                         fluidRow(
                                                             br()
                                                         )
                                                     )
                                    )
                                }
                                )
                            )
                        )
               ),
               tabPanel("Get Historic",
                        sidebarLayout(
                            sidebarPanel(
                                textInput("historic_q", "Search All", ""),
                                textInput("historic_qtitle", "Search In Title", ""),
                                checkboxGroupInput("historic_sources", "Sources", c('cnn', 'fox-news', 'the-wall-street-journal', 'reuters'), selected=c('cnn', 'fox-news', 'the-wall-street-journal', 'reuters')),
                                textInput("historic_from", "From", placeholder="2019-11-18T07:13:34"),
                                textInput("historic_to", "To", placeholder="2019-11-18T07:13:34"),
                                radioButtons("historic_sortby", "Sort By", c('publishedAt', 'relevancy', 'popularity')),
                                sliderInput("historic_pagesize", "pagesize", 20, 100, 20),
                                sliderInput("historic_page", "page", 1, 20, 1),
                                actionButton("historic_update", "Update")
                            ),
                            mainPanel(
                                lapply(1:100, function(i) {
                                    conditionalPanel(condition = paste0("output.historic_nrow>=", i),
                                                     fluidRow(
                                                         fluidRow(
                                                             column(width=2,
                                                                    htmlOutput(paste0("historic_row", i, "_image"))
                                                             ),
                                                             column(width=10,
                                                                    htmlOutput(paste0("historic_row", i)),
                                                                    br(),
                                                                    actionButton(paste0("historic_row", i, "_readmore"), "Read More")
                                                             )
                                                         ),
                                                         fluidRow(
                                                             br()
                                                         )
                                                     )
                                    )
                                }
                                )
                            )
                        )
               )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    output$sources <- renderDataTable({
        input$sources_update
        sources_output <- isolate(get_sources(category=input$sources_category, api_key=news_key))
        sources_output
    })
    
    headlines_output <- reactive({
        input$headlines_update
        isolate(get_headlines(sources=input$headlines_sources, q=input$headlines_q, page_size=input$headlines_pagesize, page=input$headlines_page, api_key=news_key))
    })
    
    output$headlines_nrow <- reactive({
        nrow(headlines_output())
    })
    
    outputOptions(output, "headlines_nrow", suspendWhenHidden = FALSE) 
    
    lapply(1:100, function(i) {
        output[[paste0("headlines_row", i, "_image")]] <- renderText({
            paste0('<img src="',headlines_output()$urlToImage[i], '" style="width:100%;height:60%;"', '>')
        })
        output[[paste0("headlines_row", i)]] <- renderText({
            paste0(
                paste0('<div align="left"><strong>', headlines_output()$title[i], ' </strong></div>'),
                paste0('<div align="left">', format(as.POSIXct(headlines_output()$publishedAt[i]), "%Y-%m-%d %H:%M:%OS"), '</div>'),
                paste0('<div align="left">', headlines_output()$description[i], '</div>')
            )
        })
        observeEvent(input[[paste0("headlines_row", i, "_readmore")]], {
            showModal(modalDialog(
                title = headlines_output()$title[i],
                HTML(paste0('Author: ', headlines_output()$author[i], '<br><br> Content: <br>', headlines_output()$content[i], '<br><br>Link:<br>', headlines_output()$url[i]))
            ))
        })
    }
    )
    
    historic_output <- reactive({
        input$historic_update
        isolate(get_historic(q=input$historic_q, q_title=input$historic_qtitle, sources=input$historic_sources, from=input$historic_from, to=input$historic_to, sort_by=input$historic_sortby, page_size=input$historic_pagesize, page=input$historic_page, api_key=news_key))
    })
    
    output$historic_nrow <- reactive({
        nrow(historic_output())
    })
    
    outputOptions(output, "historic_nrow", suspendWhenHidden = FALSE) 
    
    lapply(1:100, function(i) {
        output[[paste0("historic_row", i, "_image")]] <- renderText({
            paste0('<img src="',historic_output()$urlToImage[i], '" style="width:100%;height:60%;"', '>')
        })
        output[[paste0("historic_row", i)]] <- renderText({
            paste0(
                paste0('<div align="left"><strong>', historic_output()$title[i], ' </strong></div>'),
                paste0('<div align="left">', format(as.POSIXct(historic_output()$publishedAt[i]), "%Y-%m-%d %H:%M:%OS"), '</div>'),
                paste0('<div align="left">', historic_output()$description[i], '</div>')
            )
        })
        observeEvent(input[[paste0("historic_row", i, "_readmore")]], {
            showModal(modalDialog(
                title = historic_output()$title[i],
                HTML(paste0('Author: ', historic_output()$author[i], '<br><br> Content: <br>', historic_output()$content[i], '<br><br>Link:<br>', historic_output()$url[i]))
            ))
        })
    }
    )
    
}

# Run the application 
shinyApp(ui = ui, server = server)
