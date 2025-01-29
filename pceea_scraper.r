library(ojsr)
library(dplyr)
library(stringr)

pceea_url <- "https://ojs.library.queensu.ca/index.php/PCEEA"
search_criteria <- "(story* OR anecdote* OR narrativ*) AND (\"engineering education\" OR \"engineering pedagogy\" OR \"engineering design\")"

print("Getting article URLs from search...")
article_url_data <- get_articles_from_search(pceea_url, search_criteria, verbose=FALSE)

# Get just the article URLs
article_urls <- unique(article_url_data$output_url)
unique_article_count <- length(article_urls)
print(paste("Found", unique_article_count, "unique article URLs."))

print("Getting unique article metadata...")
metadata <- get_html_meta_from_article(article_urls, verbose=FALSE)

# Initialize output dataframe
output_dataframe <- data.frame(title = character(), authors = character(), abstract = character())

print("Scraping article metadata...")
# iterate through unique article_urls
for (article_idx in 1:unique_article_count) {
    article_url <- article_urls[article_idx]
    
    # get article metadata
    article_metadata <- subset(metadata, metadata$input_url == article_url)

    # extract metadata rows for this article for the abstract, authors, and title
    abstract_row <- subset(article_metadata, article_metadata$meta_data_name == "DC.Description")
    author_rows <- subset(article_metadata, article_metadata$meta_data_name == "citation_author")
    title_row <- subset(article_metadata, article_metadata$meta_data_name == "DC.Title")

    # Get the actual abstract, authors, and title from the metadata rows
    abstract <- str_trim(abstract_row$meta_data_content)
    if (length(abstract) == 0) {
        abstract <- "No abstract available."
    }
    authors <- paste(author_rows$meta_data_content, collapse = "; ")
    title <- title_row$meta_data_content

    # add article metadata to output dataframe

    output_dataframe <- rbind(output_dataframe, data.frame("title"=title, "authors"=authors, "abstract"=abstract))
}


print("Writing search results to CSV...")
write.csv(output_dataframe, file="pceea_search_scrape.csv", row.names=FALSE)