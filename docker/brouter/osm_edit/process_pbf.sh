#!/bin/bash
set -e

cd /osm_edit

touch lastmaprun.date

JAVA='java -Xmx2600m -Xms2600m -Xmn32m'

BROUTER_PROFILES="/profiles2"

BROUTER_JAR="/brouter.jar"

PLANET_FILE="/osm_edit/pbf_files/wisconsin-latest_edited.osm.pbf"

SRTM_PATH="/osm_edit/srtm"

rm -rf tmp
mkdir tmp
cd tmp
mkdir nodetiles
${JAVA} -cp ${BROUTER_JAR} -DavoidMapPolling=true btools.mapcreator.OsmCutter ${BROUTER_PROFILES}/lookups.dat nodetiles ways.dat relations.dat restrictions.dat ${BROUTER_PROFILES}/all.brf ${PLANET_FILE}

mkdir ftiles
${JAVA} -cp ${BROUTER_JAR} -Ddeletetmpfiles=true -DuseDenseMaps=true btools.mapcreator.NodeFilter nodetiles ways.dat ftiles

${JAVA} -cp ${BROUTER_JAR} -Ddeletetmpfiles=true -DuseDenseMaps=true btools.mapcreator.RelationMerger ways.dat ways2.dat relations.dat ${BROUTER_PROFILES}/lookups.dat ${BROUTER_PROFILES}/trekking.brf ${BROUTER_PROFILES}/softaccess.brf

mkdir waytiles
${JAVA} -cp ${BROUTER_JAR} -Ddeletetmpfiles=true -DuseDenseMaps=true btools.mapcreator.WayCutter ftiles ways2.dat waytiles

mkdir waytiles55
${JAVA} -cp ${BROUTER_JAR} -Ddeletetmpfiles=true -DuseDenseMaps=true btools.mapcreator.WayCutter5 ftiles waytiles waytiles55 bordernids.dat

mkdir nodes55
${JAVA} -cp ${BROUTER_JAR} -Ddeletetmpfiles=true -DuseDenseMaps=true btools.mapcreator.NodeCutter ftiles nodes55

mkdir unodes55
${JAVA} -cp ${BROUTER_JAR} -Ddeletetmpfiles=true -DuseDenseMaps=true btools.mapcreator.PosUnifier nodes55 unodes55 bordernids.dat bordernodes.dat ${SRTM_PATH}

mkdir segments
${JAVA} -cp ${BROUTER_JAR} -DuseDenseMaps=true btools.mapcreator.WayLinker unodes55 waytiles55 bordernodes.dat restrictions.dat ${BROUTER_PROFILES}/lookups.dat ${BROUTER_PROFILES}/all.brf segments rd5

rm -rf /osm_edit/segments4_lastrun
cp -R /osm_edit/segments4 /osm_edit/segments4_lastrun
mv /osm_edit/tmp/segments/ /osm_edit/segments4/
rm -rf /osm_edit/tmp
