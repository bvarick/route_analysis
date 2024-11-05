walk: route_analysis.Rmd
	R -e 'library("rmarkdown"); old_path <- Sys.getenv("PATH"); Sys.setenv(PATH = paste(old_path, "/usr/local/bin", sep = ":")); rmarkdown::render(knit_root_dir = "./", output_dir = "./html", input = "./route_analysis.Rmd", output_file = "./html/route_analysis.html")'

cycle: cycling_route_analysis.Rmd
	R -e 'library("rmarkdown"); old_path <- Sys.getenv("PATH"); Sys.setenv(PATH = paste(old_path, "/usr/local/bin", sep = ":")); rmarkdown::render(knit_root_dir = "./", output_dir = "./html", input = "./cycling_route_analysis.Rmd", output_file = "./html/cycling_route_analysis.html")'

container: ./docker/docker-compose.yml
	cd ./docker/; docker compose up -d

data:
	cd ./docker/; docker run -t -v "./data-foot:/data" -v "./data-raw/wisconsin-latest.osm.pbf:/data/wisconsin-latest.osm.pbf" osrm/osrm-backend osrm-extract -p /opt/foot.lua /data/wisconsin-latest.osm.pbf
	cd ./docker/; docker run -t -v "./data-foot:/data" -v "./data-raw/wisconsin-latest.osm.pbf:/data/wisconsin-latest.osm.pbf" osrm/osrm-backend osrm-partition /data/wisconsin-latest.osrm
	cd ./docker/; docker run -t -v "./data-foot:/data" -v "./data-raw/wisconsin-latest.osm.pbf:/data/wisconsin-latest.osm.pbf" osrm/osrm-backend osrm-customize /data/wisconsin-latest.osrm
	cd ./docker/; docker run -t -v "./data-bicycle:/data" -v "./data-raw/wisconsin-latest.osm.pbf:/data/wisconsin-latest.osm.pbf" osrm/osrm-backend osrm-extract -p /opt/bicycle.lua /data/wisconsin-latest.osm.pbf
	cd ./docker/; docker run -t -v "./data-bicycle:/data" -v "./data-raw/wisconsin-latest.osm.pbf:/data/wisconsin-latest.osm.pbf" osrm/osrm-backend osrm-partition /data/wisconsin-latest.osrm
	cd ./docker/; docker run -t -v "./data-bicycle:/data" -v "./data-raw/wisconsin-latest.osm.pbf:/data/wisconsin-latest.osm.pbf" osrm/osrm-backend osrm-customize /data/wisconsin-latest.osrm


clean: clean-data clean-figure clean-script

clean-data:
	rm -vf ./R/data/*.rds

clean-script:
	rm -rvf ./*.md

clean-figure:
	rm -rvf ./figure/

.PHONY: data

