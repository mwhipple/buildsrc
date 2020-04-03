##
# This file provides a date based versioning strategy.
#
# To use this strategy the file should be sourced and
# the functions exported as necessary.
#
# While version numbers make sense for anything offering
# for which there are likely to be multiple active versions and
# the consumers have a fair amount of control over the version used,
# in cases where there is only a single intended active version
# (such as a CD'ed SaaS service) versioning which implies multiple
# tracks is unlikely to fit naturally. In such scenarios a
# more practical option may be to use date based versions
# which convey the singular revision history and help capture
# what code was active at a given point in time, reflecting
# the evolution of the service underneath consumers.
#
# These functions provide such a strategy where any release
# is given a version based on the day of release and a 0-based
# counter indicating the order of the current release
# within the current day.
#
# Following the release the qualifier `-NEXT` will be appended
# to the released version to indicate that the code is not
# part of a release and would be building towards whatever the
# NEXT release may be (the version of which would not yet be known).
##

release_version() {
    local today
    today=$(date '+%Y-%m-%d')
    case $1 in
	${today}-*)
	    local tail
	    local -i next_serial
	    tail="${1#${today}-}"
	    (( next_serial=${tail%%-*}+1 ))
	    echo "${today}-${next_serial}"
	    ;;
	*)
	    echo "${today}-0"
	    ;;
    esac
}

release_postversion() {
    echo "$1-NEXT"
}
