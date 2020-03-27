readonly release_src="${BATS_TEST_DIRNAME}/../../release"

MY_TMPDIR="${BATS_TMPDIR}/$$"
MY_VERSION='1.0'

debug() {
    echo "$@" >> "${TEST_LOG}"
}

in_test_dir() {
  local work_dir="${MY_TMPDIR}/$1"
  mkdir -p "${work_dir}"
  cp "${release_src}" "${work_dir}"
  cd "${work_dir}"
}

init_with_origin() {
  local origin_dir="${MY_TMPDIR}/$1"
  mkdir -p "${origin_dir}"
  git init --bare "${origin_dir}"
  git init .
  git remote add origin "file://${origin_dir}"
  git add .
  git commit -m 'Sync to origin'
  git push --set-upstream origin master
}

setup_valid_dir() {
  in_test_dir "$1"
  echo "VERSION=${MY_VERSION}-SNAPSHOT" > build.properties
  init_with_origin "$1_origin"
}

sync_with_origin() {
  git add .
  git commit -m 'Sync to origin'
  git push
}
