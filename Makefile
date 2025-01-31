all: data containers cycle

data: osrm-data brouter-data
containers: osrm-container brouter-container
WI-cycle: WI-schools-cycle
cycle: cycle_brouter

walk: route_analysis.Rmd
	R -e 'library("rmarkdown"); old_path <- Sys.getenv("PATH"); Sys.setenv(PATH = paste(old_path, "/usr/local/bin", sep = ":")); rmarkdown::render(knit_root_dir = "./", output_dir = "./html", input = "./route_analysis.Rmd", output_file = "./html/route_analysis.html")'

cycle_osrm: cycling_route_analysis.Rmd
	R -e 'library("rmarkdown"); old_path <- Sys.getenv("PATH"); Sys.setenv(PATH = paste(old_path, "/usr/local/bin", sep = ":")); rmarkdown::render(knit_root_dir = "./", output_dir = "./html", input = "./cycling_route_analysis.Rmd", output_file = "./html/cycling_route_analysis.html")'

cycle_brouter: cycling_route_analysis_brouter.Rmd
	R -e 'library("rmarkdown"); old_path <- Sys.getenv("PATH"); Sys.setenv(PATH = paste(old_path, "/usr/local/bin", sep = ":")); rmarkdown::render(knit_root_dir = "./", output_dir = "./html", input = "./cycling_route_analysis_brouter.Rmd", output_file = "./html/cycling_route_analysis.html")'

route_to_school: route_to_school.Rmd
	R -e 'library("rmarkdown"); old_path <- Sys.getenv("PATH"); Sys.setenv(PATH = paste(old_path, "/usr/local/bin", sep = ":")); rmarkdown::render(knit_root_dir = "./", output_dir = "./html", input = "./route_to_school.Rmd", output_file = "./html/route_to_school.html")'

WI-schools-cycle: WI-schools-cycle.Rmd
	R -e 'library("rmarkdown"); old_path <- Sys.getenv("PATH"); Sys.setenv(PATH = paste(old_path, "/usr/local/bin", sep = ":")); rmarkdown::render(knit_root_dir = "./", output_dir = "./html", input = "./WI-schools-cycle.Rmd", output_file = "./html/WI-schools-cycle.html")'

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
	cd ./docker/brouter/; wget https://brouter.de/brouter/profiles2/safety.brf -O ./brouter/misc/profiles2/safety.brf
	cd ./docker/brouter/; rm -rf ./brouter-web-bkup/; mv -v ./brouter-web/ ./brouter-web-bkup/; git clone https://github.com/nrenner/brouter-web.git
	cd ./docker/brouter/brouter-web; cp keys.template.js keys.js;
	cd ./docker/brouter/brouter-web; cp config.template.js config.js
	cd ./docker/brouter; docker compose build

osm_edit_import_pbf:
	cd ./docker/osm_edit/; wget https://download.geofabrik.de/north-america/us/wisconsin-latest.osm.pbf -O ./osm-data/wisconsin-latest.osm.pbf
	cd ./docker/osm_edit/; rm ./osm-data/wisconsin-latest.osm; docker run -v ./osm-data:/osm-data ghcr.io/bvarick/osmosis:0.49.2 osmosis --read-pbf "/osm-data/wisconsin-latest.osm.pbf" --write-xml file="/osm-data/wisconsin-latest.osm"

osm_edit_refresh_base:
	cd ./docker/brouter/osm_edit; wget https://download.geofabrik.de/north-america/us/wisconsin-latest.osm.pbf -O ./pbf_files/wisconsin-latest.osm.pbf
	cd ./docker/brouter/osm_edit/srtm3/; wget -i srtm_tiles.csv -P ./

osm_edit_generate_pbf:
	cd ./docker/brouter/; docker run -v ./osm_edit:/osm_edit ghcr.io/bvarick/osmium-tool:2.21.0 osmium apply-changes /osm_edit/pbf_files/wisconsin-latest.osm.pbf /osm_edit/map_edited.osm -o /osm_edit/pbf_files/wisconsin-latest_edited.osm.pbf --overwrite

osm_edit_generate_brouter:
	docker run --rm --user "$(id -u):$(id -g)" --env PLANET=wisconsin-latest_edited.osm.pbf --env JAVA_OPTS="-Xmx2048M -Xms2048M -Xmn256M" --env PLANET_UPDATE=0 --volume ./docker/brouter/osm_edit/brouter-tmp:/brouter-tmp --volume ./docker/brouter/osm_edit/pbf_files:/planet --volume ./docker/brouter/osm_edit/srtm3:/srtm3:ro --volume ./docker/brouter/osm_edit/segments:/segments ghcr.io/mjaschen/brouter-routingdata-builder

