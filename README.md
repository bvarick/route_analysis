## Routes for walking to school
This script generates maps to analyze the potential walking routes for students to their school.

- I excluded the addresses of the students from the repository.
- The actual route generation is done with OSRM, I run it locally in a docker container.
- The basemap is pulled from Stadia Maps. The usage of the script is well within the free tier, you'll need an API key from them.

## Example figures
This script will generate a few figures:
### A heatmap of student addresses:
![example address figure](examples/example-addresses.png)

### A map of all the walking routes within the walk boundary:
![example routes figure](examples/example-routes.png)

### A map of those routes colored by the level of traffic stress to bike
![example routes-lts figure](examples/example-routes-lts.png)

## Using make
The command `make route_analysis` will run *route_analysis.Rmd* which
is an R markdown file containing the original R script *route_analysis.R*
