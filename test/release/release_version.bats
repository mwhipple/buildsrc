#!/usr/bin/env bats

load test_helper

@test 'When no version is in file, use blank.' {
  in_test_dir 'missing_version'
  touch build.properties
  init_with_origin 'missing_version_origin'
  RELEASE_VERBOSE=true AUTO_VERSION=true run ./release build.properties
  [[ "${output}" =~ Releasing\ version:\ \'\' ]]
}

@test 'When blank version is in file, use blank.' {
  in_test_dir 'blank_version'
  echo 'VERSION=' > build.properties
  init_with_origin 'blank_version_origin'
  RELEASE_VERBOSE=true AUTO_VERSION=true run ./release build.properties
  [[ "${output}" =~ Releasing\ version:\ \'\' ]]
}

@test 'When non-qualified version is in file, use as is.' {
  in_test_dir 'release_version'
  echo 'VERSION=1.0' > build.properties
  init_with_origin 'release_version_origin'
  RELEASE_VERBOSE=true AUTO_VERSION=true run ./release build.properties
  [[ "${output}" =~ Releasing\ version:\ \'1\.0\' ]]
}

@test 'When qualified version is in file, remove that qualifier.' {
  in_test_dir 'qual_version'
  echo 'VERSION=1.0-SNAPSHOT' > build.properties
  init_with_origin 'qual_version_origin'
  RELEASE_VERBOSE=true AUTO_VERSION=true run ./release build.properties
  [[ "${output}" =~ Releasing\ version:\ \'1\.0\' ]]
}

@test 'When over-qualified version is in file, remove all qualifiers.' {
  in_test_dir 'qual_version'
  echo 'VERSION=1.0-SNAPSHOT-build1' > build.properties
  init_with_origin 'qual_version_origin'
  RELEASE_VERBOSE=true AUTO_VERSION=true run ./release build.properties
  [[ "${output}" =~ Releasing\ version:\ \'1\.0\' ]]
}

@test 'When no version is in file, use environment value if present.' {
  in_test_dir 'missing_env_version'
  touch build.properties
  init_with_origin 'missing_env_version_origin'
  RELEASE_VERBOSE=true VERSION=0.4 AUTO_VERSION=true run ./release build.properties
  [[ "${output}" =~ Releasing\ version:\ \'0\.4\' ]]
}

@test 'When blank version is in file, ignore environment value.' {
  in_test_dir 'blank_env_version'
  echo 'VERSION=' > build.properties
  init_with_origin 'blank_env_version_origin'
  RELEASE_VERBOSE=true VERSION=0.4 AUTO_VERSION=true run ./release build.properties
  [[ "${output}" =~ Releasing\ version:\ \'\' ]]
}

@test 'When RELEASE_VERSION is specified override value in the file.' {
  in_test_dir 'overridden_version'
  echo 'VERSION=1.0' > build.properties
  init_with_origin 'overridden_version_origin'
  RELEASE_VERBOSE=true RELEASE_VERSION=2.0 AUTO_VERSION=true run ./release build.properties
  [[ "${output}" =~ Releasing\ version:\ \'2\.0\' ]]
}

@test 'When build.properties.release already exists, return error status.' {
  in_test_dir 'stale_release'
  echo 'VERSION=1.0' > build.properties
  touch build.properties.release
  init_with_origin 'stale_release_origin'
  AUTO_VERSION=true run ./release build.properties
  (( "${status}" != 0 ))
}

@test 'When build.properties.release already exists, output fitting message.' {
  in_test_dir 'stale_release'
  echo 'VERSION=1.0' > build.properties
  touch build.properties.release
  init_with_origin 'stale_release_origin'
  AUTO_VERSION=true run ./release build.properties
  [[ "${output}" =~ file\ already\ exists. ]]
}
