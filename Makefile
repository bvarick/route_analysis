route_analysis: R/route_analysis.Rmd
	R -e 'library("rmarkdown"); old_path <- Sys.getenv("PATH"); Sys.setenv(PATH = paste(old_path, "/usr/local/bin", sep = ":")); rmarkdown::render(knit_root_dir = "~/route_analysis/", output_dir = "~/route_analysis/html", input = "./R/route_analysis.Rmd", output_file = "./html/route_analysis.html")'

clean: clean-data clean-figure clean-script

clean-data:
	rm -vf ./R/data/*.rds

clean-script:
	rm -rvf ./*.md

clean-figure:
	rm -rvf ./figure/

.PHONY: data
