all: data containers cycle

data: osrm-data brouter-data
containers: osrm-container brouter-container
cycle: cycle_brouter

walk: route_analysis.Rmd
	R -e 'library("rmarkdown"); old_path <- Sys.getenv("PATH"); Sys.setenv(PATH = paste(old_path, "/usr/local/bin", sep = ":")); rmarkdown::render(knit_root_dir = "./", output_dir = "./html", input = "./route_analysis.Rmd", output_file = "./html/route_analysis.html")'

cycle_osrm: cycling_route_analysis.Rmd
	R -e 'library("rmarkdown"); old_path <- Sys.getenv("PATH"); Sys.setenv(PATH = paste(old_path, "/usr/local/bin", sep = ":")); rmarkdown::render(knit_root_dir = "./", output_dir = "./html", input = "./cycling_route_analysis.Rmd", output_file = "./html/cycling_route_analysis.html")'

cycle_brouter: cycling_route_analysis_brouter.Rmd
	R -e 'library("rmarkdown"); old_path <- Sys.getenv("PATH"); Sys.setenv(PATH = paste(old_path, "/usr/local/bin", sep = ":")); rmarkdown::render(knit_root_dir = "./", output_dir = "./html", input = "./cycling_route_analysis_brouter.Rmd", output_file = "./html/cycling_route_analysis.html")'

osrm-container: ./docker/osrm/docker-compose.yml
	cd ./docker/osrm/; docker compose up -d

osrm-data:
	cd ./docker/osrm/; wget https://download.geofabrik.de/north-america/us/wisconsin-latest.osm.pbf -O ./data-raw/wisconsin-latest.osm.pbf
	cd ./docker/osrm/; docker run --rm -t -v "./data-foot:/data" -v "./data-raw/wisconsin-latest.osm.pbf:/data/wisconsin-latest.osm.pbf" osrm/osrm-backend osrm-extract -p /opt/foot.lua /data/wisconsin-latest.osm.pbf
	cd ./docker/osrm/; docker run --rm -t -v "./data-foot:/data" -v "./data-raw/wisconsin-latest.osm.pbf:/data/wisconsin-latest.osm.pbf" osrm/osrm-backend osrm-partition /data/wisconsin-latest.osrm
	cd ./docker/osrm/; docker run --rm -t -v "./data-foot:/data" -v "./data-raw/wisconsin-latest.osm.pbf:/data/wisconsin-latest.osm.pbf" osrm/osrm-backend osrm-customize /data/wisconsin-latest.osrm
	cd ./docker/osrm/; docker run --rm -t -v "./data-bicycle:/data" -v "./data-raw/wisconsin-latest.osm.pbf:/data/wisconsin-latest.osm.pbf" osrm/osrm-backend osrm-extract -p /opt/bicycle.lua /data/wisconsin-latest.osm.pbf
	cd ./docker/osrm/; docker run --rm -t -v "./data-bicycle:/data" -v "./data-raw/wisconsin-latest.osm.pbf:/data/wisconsin-latest.osm.pbf" osrm/osrm-backend osrm-partition /data/wisconsin-latest.osrm
	cd ./docker/osrm/; docker run --rm -t -v "./data-bicycle:/data" -v "./data-raw/wisconsin-latest.osm.pbf:/data/wisconsin-latest.osm.pbf" osrm/osrm-backend osrm-customize /data/wisconsin-latest.osrm

brouter-container: ./docker/brouter/docker-compose.yml
	cd ./docker/brouter; docker compose up -d

brouter-data:
	cd ./docker/brouter/; rm -rf ./brouter-bkup/; mv -v ./brouter/ ./brouter-bkup/; git clone https://github.com/abrensch/brouter.git
	cd ./docker/brouter/; wget -i segments.csv -P ./brouter/misc/segments4/
	cd ./docker/brouter/; cp safety.brf ./brouter/misc/profiles2/safety.brf
	cd ./docker/brouter/; rm -rf ./brouter-web-bkup/; mv -v ./brouter-web/ ./brouter-web-bkup/; git clone https://github.com/nrenner/brouter-web.git
	cd ./docker/brouter/brouter-web; cp keys.template.js keys.js;
	cd ./docker/brouter/brouter-web; cp config.template.js config.js
	cd ./docker/brouter; docker compose build
