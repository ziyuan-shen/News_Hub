# Central News Hub

## Introduction

[News API](https://newsapi.org/) gives you access to breaking news headlines 
and historical articles from over 30,000 news sources. The purpose of this exam 
is to use their API to create an RShiny news deck (dashboard). A free account 
with News API will grant you 500 requests per day and allow you to query 
articles up to one month old. Breaking news headlines do have a 15 minute 
time delay.


Create three helper functions, one for each API endpoint. 

1. Create `get_sources()` with arguments `category` and `api_key`. This function
   serves as a wrapper for News API's "Sources" endpoint.

2. Create `get_headlines()` with arguments `sources`, `q`, `page_size`,
   `page`, and `api_key`. This function serves as a wrapper for News API's 
   "Top headlines" endpoint.
   
3. Create `get_historic()` with arguments `q`, `q_title`, `sources`, `from`,
   `to`, `sort_by`, `page_size`, `page`, `api_key`. This function serves
   as a wrapper for News API's "Everything" endpoint.
   
For all functions, sources are only be a subset of CNN, Fox News, 
The Wall Street Journal, and Reuters. The country will always be United States,
and the language will always be English.

Function:

- Each function should return a tidy data frame
- Each function should include basic input checks

<br/>

## News Hub App

Create a Shiny app that serves as a central news hub. It is embedded in the Rmd file.

App features:

1. The user should be able to specify any of the `get_*()` function parameters.

2. Action button(s) are used that only retrieve News API data when
   the button is clicked.
   
3. Content shown include the 
   article's title, link, author, image, etc. Read More button is made by incorporating a
   [modal dialog box](https://shiny.rstudio.com/reference/shiny/latest/modalDialog.html).


<a style="font-size:2.6em;" href="https://ziyuan-shen.shinyapps.io/Central_News_Hub/">Run App</a></br>
**Note:** 25 hrs usage limit for shinyapps.io free account