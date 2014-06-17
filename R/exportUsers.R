exportUsers <- function(rcon, date=TRUE, label=TRUE){
  #* parameters for the Users File Export
  .params <- list(token=rcon$token, content='user', format='csv')
  
  #* Export Users file and convert to data frame
  x <- postForm(uri=rcon$url,.params=.params,
                .opts=curlOptions(ssl.verifyhost=FALSE))
  x <- read.csv(textConnection(x), stringsAsFactors=FALSE, na.strings="")
  
  #* convert expiration date to POSIXct class
  if (date) x$expiration <- as.POSIXct(x$expiration, format="%Y-%m-%d")
  
  #* convert data export and form editing privileges to factors
  if (label){
    x$data_export <- factor(x$data_export, c(0, 2, 1), c("No access", "De-identified", "Full data set"))
    
    x[, 8:length(x)] <- lapply(x[, 8:length(x)], factor, c(0, 2, 1, 3),
                               c("No access", "Read only", "view records/responses and edit records", "Edit survey responses"))
  }
  
  return(x)
}