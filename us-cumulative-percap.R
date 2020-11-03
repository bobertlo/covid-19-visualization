library(zip)
library(usmap)
library(ggplot2)
library(zoo)
library(tidyverse)
library(tidycensus)
library(magick)
library(GGally)
library(rgdal)

if (file.exists("census-api-key.R")) {
  source("census-api-key.R")
}

covid_data_hash = "1ac567f9937adb6748907631743fa69f8e2b21d9"

covid_data_url <- paste("https://github.com/CSSEGISandData/COVID-19/archive/", covid_data_hash, ".zip", sep="")
covid_data_destfile <- paste("covid19-", covid_data_hash, ".zip", sep="")
covid_data_path = paste("data/COVID-19-", covid_data_hash, "/csse_covid_19_data", sep="")

if (!file.exists(covid_data_destfile)) {
  download.file(covid_data_url, destfile = covid_data_destfile, mode="wb")
}

unzip(covid_data_destfile, exdir="data")

u_conf_path <- file.path(covid_data_path, "csse_covid_19_time_series", "time_series_covid19_confirmed_US.csv")
u_conf <- read.csv(u_conf_path)
u_names <- names(u_conf)
u_names[5] <- "fips"
names(u_conf) <- u_names
u_conf[12:length(u_conf)] <- sapply(u_conf[12:length(u_conf)], as.numeric)

u_cum <- u_conf[12:length(u_conf)]
u_dates <- seq_along(u_cum)
u_dates <- lapply(u_dates, function(x) format(as.Date("2020-01-22") + x))
names(u_cum) <- u_dates
u_cum$fips <- u_conf$fips

us_pop <- get_acs(geography = "county",
                  variables = "B01003_001")
us_pop$fips <- as.numeric(us_pop$GEOID)

u_comb <- left_join(us_pop, u_cum, by = c("fips" = "fips"))

output_dir = "us-cumulative-percap"
unlink(output_dir, recursive=TRUE)
dir.create(output_dir)

out_dates <- u_dates[39:length(u_dates)]
for (i in out_dates) {
  print(i)
  llab = paste("Confirmed COVID-19 Cases Per 100k People (JHU CSSE / US ACS)", i)
  u_comb$percap <- u_comb[[i]] / (u_comb$estimate / 100000)
  img <- plot_usmap(regions = "counties", data = u_comb, values = "percap", size=0.0001) + 
    scale_fill_continuous(low = "white", high = "red", name = llab, na.value="white", guide = guide_colourbar(barwidth = 15, barheight = 0.1, title.position = "top")) +
    theme(legend.position = "bottom", text = element_text(size = 4))
  ggsave(filename = paste(output_dir, "/", i, ".png", sep=""), plot=img,width=3,height=2.5,units="in",scale=1)
}
