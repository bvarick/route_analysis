getLTSForRoute <- function(i) {

  # Filter the routes for the current student number
  current_route <- routes %>% filter(student_number == i)

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
