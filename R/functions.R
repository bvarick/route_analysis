getLTSForRoute <- function(i, route_table) {

  # Filter the routes for the current student number
  current_route <- route_table %>% filter(student_number == i)

  # Find intersecting OBJECTIDs
  intersecting_ids <- relevant_buffer$OBJECTID[lengths(st_intersects(relevant_buffer, current_route)) > 0]

  # Filter relevant segments to calculate max and average lts
  relevant_segments <- bike_lts_buffer %>% filter(OBJECTID %in% intersecting_ids)

  # find all the segments of relevant_buffer that the current route passes through
  current_route_lts_intersection <- st_intersection(current_route, relevant_segments)

  # calculate segment length in meters
  current_route_lts_intersection$"segment_length" <- as.double(st_length(current_route_lts_intersection))

  # Return the result as a list
  result <- list(
    student_number = i
    , lts_max = max(current_route_lts_intersection$LTS_F)
    , lts_average = weighted.mean(current_route_lts_intersection$LTS_F, current_route_lts_intersection$segment_length)
    , lts_1_dist = sum(current_route_lts_intersection %>% filter(LTS_F == 1) %>% pull(LTS_F))
    , lts_2_dist = sum(current_route_lts_intersection %>% filter(LTS_F == 2) %>% pull(LTS_F))
    , lts_3_dist = sum(current_route_lts_intersection %>% filter(LTS_F == 3) %>% pull(LTS_F))
    , lts_4_dist = sum(current_route_lts_intersection %>% filter(LTS_F == 4) %>% pull(LTS_F))
    , route = as.data.frame(current_route_lts_intersection)
  )

  # Message for progress
  message(paste0("done - ", i))

  return(result)
}


routeChar <- function(route){

    if(is.na(route$messages)){
        return(NA)
    }

    text <- route$messages
    text <- gsub(x = text, pattern = "\\\"", replacement = "")
    text <- gsub(x = text, pattern = "\ ", replacement = "")
    text <- gsub(x = text, pattern = "\\[\\[", replacement = "")
    text <- gsub(x = text, pattern = "\\]\\]", replacement = "")
    foobar <- strsplit(text, split = "],[", fixed = TRUE)
    x <- lapply(foobar, function(x){strsplit(x, split = ",", fixed = TRUE)})
    xx <- unlist(x)
    m <- matrix(xx, ncol = 13, byrow = TRUE)
    names.vec <- m[1,]

    if(nrow(m) == 2){
        df <- data.frame(t(m[-1,]))
    }else{
        df <- data.frame(m[-1,])
    }

    names(df) <- names.vec

    df2 <- within(df, {
        Time <- as.numeric(Time)
        stageTime <- diff(c(0,Time))
        path <- grepl("highway=path", df$WayTags)
        residential <- grepl("highway=residential", df$WayTags)
        footway <- grepl("highway=footway", df$WayTags)
        primary <- grepl("highway=primary", df$WayTags)
        service <- grepl("highway=service", df$WayTags)
        cycleway <- grepl("highway=cycleway", df$WayTags)
        bike <- grepl("bicycle=designated", df$WayTags)
    })


    foo <- function(x){
        ifelse(x$path, "path", ifelse(x$residential, "residential", ifelse(x$footway, "footway", ifelse(x$primary, "primary", ifelse(x$service, "service", ifelse(x$cycleway, "cycleway", "other"))))))
    }

    df2 <- cbind(df2, highway = foo(df2))
    df2 <- df2 %>% group_by(highway) %>% summarize(T = sum(stageTime))

    df2 <- df2 %>% filter(!is.na(highway))


    if(!("cycleway" %in% df2$highway)){
        return(0)
    }else{
        return(df2[df2$highway == "cycleway",]$T)
    }

}
