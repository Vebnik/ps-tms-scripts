ps_tms_dir=$1
ps_tms_dir_len=${#ps_tms_dir}

current_dir=$PWD

if [[ $ps_tms_dir_len -lt 1 ]]; then
  echo "Not found ps_tms_dir args ($1)"
  exit 1
fi

frontend_build_dir="$ps_tms_dir/ps-front-end-server/target"
frontend_ui_static_dir="$ps_tms_dir/ps-tms-frontend-ui/public"
importer_build_dir="$ps_tms_dir/importer-service/target"
ps_tms_server_build_dir="$ps_tms_dir/ps-tms-server/target"

VERSION="4.0.3"
SKIP_TESTS="true"
THREADS_COUNT="12"

chmod +x "$ps_tms_dir/mvn/bin/mvn"

cd "$ps_tms_dir"

"./mvn/bin/mvn" \
  -DfinalVersion=$VERSION \
  -DskipTests=$SKIP_TESTS \
  clean \
  -T $THREADS_COUNT \
  install

cd "$current_dir"

rm -r builds

mkdir "$current_dir/builds/"

cp "$frontend_build_dir/ps-front-end-server-bin.zip" "$current_dir/builds/ps-front-end-server-bin.zip"
mkdir "$current_dir/builds/ps-front-end-server-bin"
unzip "$current_dir/builds/ps-front-end-server-bin.zip" -d "$current_dir/builds/ps-front-end-server-bin"
ln -s $frontend_ui_static_dir "$current_dir/builds/ps-front-end-server-bin/release/static"

cp "$importer_build_dir/importer-service-bin.zip" "$current_dir/builds/importer-service-bin.zip"
mkdir "$current_dir/builds/importer-service-bin"
unzip "$current_dir/builds/importer-service-bin.zip" -d "$current_dir/builds/importer-service-bin"

cp "$ps_tms_server_build_dir/ps-tms-server-bin.zip" "$current_dir/builds/ps-tms-server-bin.zip"
mkdir "$current_dir/builds/ps-tms-server-bin"
unzip "$current_dir/builds/ps-tms-server-bin.zip" -d "$current_dir/builds/ps-tms-server-bin"
cp "$ps_tms_server_build_dir/test-classes/ps-tms-scheme.jar" "$current_dir/builds/ps-tms-server-bin/release/ps-tms-scheme.jar"
