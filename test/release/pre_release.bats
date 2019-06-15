#!/usr/bin/env bats

load test_helper

@test 'When a pre_release script exists, invoke with expected args.' {
  setup_valid_dir 'pre_release_script'
  echo 'echo "Hooked $@"' > pre_release_echo
  chmod +x pre_release_echo
  sync_with_origin
  AUTO_VERSION=true run ./release build.properties
  [[ "${output}" =~ Hooked\ build\.properties\ 1\.0 ]]
}

@test 'When a pre_release function exists, invoke with expected args.' {
  setup_valid_dir 'pre_release_fn'

  pre_release_test() { echo "Function called with: $@"; }
  export -f pre_release_test

  AUTO_VERSION=true run ./release build.properties
  [[ "${output}" =~ Function\ called\ with:\ build\.properties\ 1\.0 ]]
}

@test 'When multiple pre_release functions exist, invoke each with expected args.' {
  setup_valid_dir 'pre_release_fn'

  pre_release_test() { echo "Function called with: $@"; }
  pre_release_2() { echo "Second called with: $@"; }
  export -f pre_release_test pre_release_2

  AUTO_VERSION=true run ./release build.properties
  [[ "${output}" =~ Function\ called\ with:\ build\.properties\ 1\.0 ]]
  [[ "${output}" =~ Second\ called\ with:\ build\.properties\ 1\.0 ]]
}

@test 'When a pre_release script and function exist, invoke both types.' {
  setup_valid_dir 'pre_release_script'
  echo 'echo "Hooked $@"' > pre_release_echo
  chmod +x pre_release_echo
  sync_with_origin

  pre_release_test() { echo "Function called with: $@"; }
  export -f pre_release_test

  AUTO_VERSION=true run ./release build.properties
  [[ "${output}" =~ Hooked\ build\.properties\ 1\.0 ]]
  [[ "${output}" =~ Function\ called\ with:\ build\.properties\ 1\.0 ]]
}

@test 'When multiple pre_release scripts exist, invoke each.' {
  setup_valid_dir 'pre_release_script'
  echo 'echo "Hooked $@"' > pre_release_echo
  echo 'echo "Another"' > pre_release_another
  chmod +x pre_release_echo
  chmod +x pre_release_another
  sync_with_origin
  AUTO_VERSION=true run ./release build.properties
  [[ "${output}" =~ Hooked\ build\.properties\ 1\.0 ]]
  [[ "${output}" =~ Another ]]
}

@test 'When a pre_release scripts is not executable, do not invoke.' {
  setup_valid_dir 'pre_release_script'
  echo 'echo "Hooked $@"' > pre_release_echo
  sync_with_origin
  AUTO_VERSION=true run ./release build.properties
  [[ ! "${output}" =~ Hooked\ build\.properties\ 1\.0 ]]
}

