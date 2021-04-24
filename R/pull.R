library(dplyr)
library(gbfs)
library(readr)
library(lubridate)

free_scooter_new <-
  gbfs::get_free_bike_status("https://data.lime.bike/api/partners/v1/gbfs/san_francisco/gbfs.json") %>%
  dplyr::mutate(lon = as.numeric(lon), lat = as.numeric(lat)) %>%
  dplyr::mutate(last_updated = with_tz(last_updated, tzone = "America/Los_Angeles"))

old_data <- readr::read_csv("https://raw.githubusercontent.com/joshyam-k/scheduled-commit-action/master/data-raw/lime.csv")

old_data <- old_data %>%
  dplyr::mutate(last_updated = with_tz(last_updated, tzone = "America/Los_Angeles"))

to_be_pushed <- rbind(free_scooter_new, old_data)

max <- max(to_be_pushed$last_updated)
new_min <- max(to_be_pushed$last_updated)

lubridate::day(new_min) <- lubridate::day(new_min) - 1

new_interval <- lubridate::interval(new_min, max)

to_be_pushed_filtered <- to_be_pushed %>%
  dplyr::filter(last_updated %within% new_interval)

write_csv(to_be_pushed_filtered, path = "data-raw/lime.csv" )
