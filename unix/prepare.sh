ps_tms_dir=$1
ps_tms_dir_len=${#ps_tms_dir}

license=$2
license_len=${#license}

if [[ $ps_tms_dir_len -lt 1 ]]; then
  echo "Not found ps_tms_dir args ($1)"
  exit 1
fi

if [[ $license_len -lt 1 ]]; then
  echo "Not found license args ($2)"
  exit 1
fi

current_dir=$PWD

frontend_work_dir="$current_dir/work-dirs/front-end-server"
importer_work_dir="$current_dir/work-dirs/importer-service"
ps_tms_work_dir="$current_dir/work-dirs/ps-tms-server"

frontend_dir="$ps_tms_dir/ps-front-end-server"
importer_dir="$ps_tms_dir/importer-service"
ps_tms_server_dir="$ps_tms_dir/ps-tms-server"

echo "-------------- WORK --------------"
echo "Current           -> $current_dir"
echo "Frontend          -> $frontend_work_dir"
echo "Importer          -> $importer_work_dir"
echo "PSTMS server      -> $ps_tms_work_dir"
echo "License           -> $license"
echo "----------------------------------"

echo ""

echo "-------------- ROOT --------------"
echo "PS TMS ROOT       -> $ps_tms_dir"
echo "Frontend          -> $frontend_dir"
echo "Importer          -> $importer_dir"
echo "PSTMS server      -> $ps_tms_server_dir"
echo "----------------------------------"

echo ""

read -p "Is correct: [y/n]: " is_correct

if [[ $is_correct == "n" ]]; then
  echo "Stopper by user ..."
  exit 1
fi

mkdir $importer_work_dir
mkdir $ps_tms_work_dir

cp "$importer_dir/src/main/resources/application.properties" "$importer_work_dir/application.properties"
cp "$importer_dir/src/main/resources/log4j2.xml" "$importer_work_dir/log4j2.xml"
cp "$importer_dir/src/main/resources/log4j-import.xml" "$importer_work_dir/log4j-import.xml"
touch "$importer_work_dir/memory.limit"

# pstms
cp "$ps_tms_server_dir/src/main/resources/application.properties" "$ps_tms_work_dir/application.properties"
cp "$ps_tms_server_dir/src/main/resources/log4j2.xml" "$ps_tms_work_dir/log4j2.xml"
touch "$ps_tms_work_dir/memory.limit"
cp "$ps_tms_server_dir/target/test-classes/ps-tms-scheme.jar" "$ps_tms_work_dir/ps-tms-scheme.jar"
