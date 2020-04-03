#!/usr/bin/env bats

load test_helper

@test 'When performing the first release use a date version with serial 0.' {
    in_test_dir 'date_first'

    echo 'VERSION=init' > build.properties
    init_with_origin 'date_first_origin'
    . "${release_src_dir}date_version.sh"
    export -f release_postversion release_version
    AUTO_VERSION=true run ./release build.properties
    today=$(date +%Y-%m-%d)
    mapfile -t logs < <(git log HEAD~2..HEAD --oneline --no-decorate | cut -d ' ' -f2-)
    [[ "${logs[0]}" == "Post release version ${today}-0-NEXT" ]]
    [[ "${logs[1]}" == "Update to version ${today}-0" ]]
}

@test 'When performing the first release of the day use a date version with serial 0.' {
    in_test_dir 'date_first_day'

    echo 'VERSION=2020-01-01-0-NEXT' > build.properties
    init_with_origin 'date_first_day'
    . "${release_src_dir}date_version.sh"
    export -f release_postversion release_version
    AUTO_VERSION=true run ./release build.properties
    today=$(date +%Y-%m-%d)
    mapfile -t logs < <(git log HEAD~2..HEAD --oneline --no-decorate | cut -d ' ' -f2-)
    [[ "${logs[0]}" == "Post release version ${today}-0-NEXT" ]]
    [[ "${logs[1]}" == "Update to version ${today}-0" ]]
}

@test 'When performing an additional release of the day use a date version with the next serial value.' {
    in_test_dir 'date_nth'
    today=$(date +%Y-%m-%d)

    echo "VERSION=${today}-14-NEXT" > build.properties
    init_with_origin 'date_nth_origin'
    . "${release_src_dir}date_version.sh"
    export -f release_postversion release_version
    RELEASE_VERBOSE=true AUTO_VERSION=true run ./release build.properties
    mapfile -t logs < <(git log HEAD~2..HEAD --oneline --no-decorate | cut -d ' ' -f2-)
    [[ "${logs[0]}" == "Post release version ${today}-15-NEXT" ]]
    [[ "${logs[1]}" == "Update to version ${today}-15" ]]
}
