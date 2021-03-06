\name{exportEvents}
\alias{exportEvents}
\alias{exportEvents.redcapDbConnection}
\alias{exportEvents.redcapApiConnection}
\title{Exports the Events for a Project}
\description{Retrieve a data frame giving the events, event names, and offsets for the events in a project.}

\usage{
\method{exportEvents}{redcapDbConnection}(rcon, arms, ...)
\method{exportEvents}{redcapApiConnection}(rcon, arms, ...)
}


\arguments{
  \item{rcon}{A REDCap connection object as generated by \code{redcapConnection}}
  \item{arms}{A vector of arm numbers that you wish to pull events for (by default, all events are pulled). }
  \item{...}{Arguments to be passed to other methods}
}

\details{
The data frame that is returned shows the event name, arm number, days offset, minimum offset, maximum offset, and 
unique event name.

When this function is called for a classic project, a character string is returned giving the API error message, 
'400: You cannot export events for classic projects' but without casting an error in R. This is by design and allows 
more flexible error checks in certain functions.}

\author{Benjamin Nutter}

\references{
Please refer to your institution's API documentation.

Additional details on API parameters are found on the package wiki at
\url{https://github.com/nutterb/redcapAPI/wiki/REDCap-API-Parameters}
}

\examples{
\dontrun{
> #*** Note: I cannot provide working examples without
> #*** compromising security.  Instead, I will try to 
> #*** offer up sample code with the matching results
> 
> #*** Create the connection object
> rcon <- redcapConnection(url=[YOUR_REDCAP_URL], token=[API_TOKEN])
> 
> exportEvents(rcon)
   event_name arm_num day_offset offset_min offset_max unique_event_name
1     Event 1       1          0          0          0     event_1_arm_1
2 Follow Up 1       1          1          0          0 follow_up_1_arm_1
3 Follow Up 2       1          2          0          0 follow_up_2_arm_1
}
}

\keyword{ methods }
