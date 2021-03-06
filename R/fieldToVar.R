fieldToVar <- 
  function(m,d,factors=TRUE, dates=TRUE, checkboxLabels=FALSE, vname)
  {    
    # Date variables
    if (grepl("date_", m$text_validation_type_or_show_slider_number) && dates){
      d <- as.POSIXct(d, format="%Y-%m-%d")  
    }
    
    #* Date time variables (no seconds)
    else if (grepl("datetime_dmy", m$text_validation_type_or_show_slider_number) && dates){
      d <- as.POSIXct(d, format="%Y-%m-%d %H:%M")
    }
    
    #* Date time variables (with seconds)
    else if (grepl("datetime_seconds_dmy", m$text_validation_type_or_show_slider_number) && dates){
      d <- as.POSIXct(d, format="%Y-%m-%d %H:%M:%S")
    }
    
    #* Time (MM:SS)
    else if (grepl("time_mm_ss", m$text_validation_type_or_show_slider_number) && dates){
      d <- chron::times(ifelse(!is.na(d), paste("00:", d, sep=""), d), format=c(times="h:m:s"))
    }
    
    #* Time (HH:MM)
    else if ("time" %in% m$text_validation_type_or_show_slider_number && dates){
      d <- chron::times(ifelse(!is.na(d), paste(d, ":00", sep=""), d), format=c(times="h:m:s"))
    }
    
    # Continuous variables
    else if ((!is.na(m$text_validation_type_or_show_slider_number) && 
                m$text_validation_type_or_show_slider_number %in% c('float','int') ) || 
               (m$field_type %in% c('calc')) )
    {
      
      suppressWarnings(d <- as.numeric(d))
      
      # Ordinal or Categorical variable with a label
    } 
    else if (m$field_type %in% c('select','radio','dropdown'))
    {
      # parses the string "0, Birth \\n 1, Death \\n 2, Unknown" into a
      # character vector for creating a factor
      w <- unlist(strsplit(m$select_choices_or_calculations,"[\n|]"))
      if (length(w)>0) 
      {
        if (length(w) == length(grep(',',w)))
        {
          w <- unlist(lapply(strsplit(w,',',perl=TRUE),
                             function(x)
                               c(x[1],paste(x[2:length(x)],collapse=','))
          ))
          w <- gsub('^\\s*','',w,perl=TRUE)
          w <- gsub('\\s*$','',w,perl=TRUE)
          # Create factor
          # Ignore warnings of NAs produced by coercion as this
          # is typically user entry error
          if (factors==TRUE)
          {
            suppressWarnings(
              d <- factor(tryCatch(as.integer(d),
                                   warning = function(cond) as.character(d)),
                          levels=w[seq(1,length(w),2)],
                          labels=w[seq(2,length(w),2)])
            )
            attr(d,'redcapLabels') <- w[seq(2,length(w),2)]
            attr(d,'redcapLevels') <- tryCatch(as.integer(w[seq(1, length(w),2)]),
                                               warning = function(cond) as.character(w[seq(1,length(w),2)]))
          }
          else
          {
            suppressWarnings(d <- tryCatch(as.integer(d), 
                                           warning = function(cond) as.character(d)))
            attr(d,'redcapLabels') <- w[seq(2,length(w),2)]
            attr(d,'redcapLevels') <- tryCatch(as.integer(w[seq(1, length(w),2)]),
                                               warning = function(cond) as.character(w[seq(1,length(w),2)]))
          }
        } 
        else if (length(w) == length(grep('^[0-9.]+$',w,perl=TRUE))) 
        {
          # Create integer since the meta data about choices are bungled.
          suppressWarnings(d <- as.integer(d))
        } 
      }
    }
    else if (m$field_type %in% c('yesno'))
    {
      if (factors){
        d <- factor(d, 0:1, c('No', 'Yes'))
        attr(d, 'redcapLabels') <- c('No', 'Yes')
        attr(d, 'redcapLevels') <- 0:1
      }
    }
    else if (m$field_type %in% c('truefalse'))
    {
      if (factors){
        d <- as.logical(d)
      }
    }
    else if (m$field_type %in% c('checkbox'))
    {
      if (factors & !checkboxLabels){
        d <- factor(d, 0:1, c('Unchecked', 'Checked'))
        attr(d, 'redcapLabels') <- c('Unchecked', 'Checked')
        attr(d, 'redcapLevels') <- 0:1
      }
      if (factors & checkboxLabels){
        #* convert choices to a matrix of options
        w <- unlist(strsplit(m$select_choices_or_calculations,"[\n|]"))
        w <- as.data.frame(do.call("rbind", strsplit(w, ",")), 
                           stringsAsFactors=FALSE)
        w <- sapply(w, function(x){ x <- gsub('^\\s*','',x,perl=TRUE);
                                    x <- gsub('\\s*$','',x,perl=TRUE);
                                    return(x)})
        #* get the suffix of the current variable
        suffix <- unlist(strsplit(vname, "___"))[2]
        
        #* match the label to the suffix
        lbl <- c("", w[w[, 1] == suffix, 2])
        
        d <- factor(d, 0:1, lbl)
        attr(d, 'redcapLabels') <- levels(d)
        attr(d, 'redcapLevels') <- 0:1
      }
    }
    
    d
  }
