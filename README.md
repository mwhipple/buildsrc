# buildsrc

A collection of build related shell scripts and recipes.

## Metadata

- Status: Active
- Type: Library
- Versioning: Semantic Versioning
- Documentation: This file and the source files
- Maintainers: [CODEOWNERS](CODEOWNERS)
- Contact/Questions/Issues: [GitHub Issues](https://www.github.com/mwhipple/buildsrc/issues)
- Contributions: Contributions are welcome.
  Open an Issue first for any non-trivial PR to verify the suitability of envisioned changes.

## Overview

This repository serves as a consolidated home for assorted build
logic.  Initially this will entail this being the canonical
representation for any such scripts which can then be copied and
pasted as needed into desired locations.  If warranted, a more
automated means of updating the scripts will be provided.

Each script initially will be fairly self contained, so individual
scripts should include all their relevant documentation.

## Installation

There are a couple factors to consider when installing buildsrc and
these should inform how you choose to install the scripts.

The first is one of bootstrapping/self-reference. It is likely that
the build system in use may help manage dependencies and may use the
scripts herein to do that, resulting in a paradoxical cycle where
you'd preferably be using buildsrc to be able to retrieve
buildsrc. Another factor is extensibility. These scripts are likely to
favor simplicity over flexibility and therefore some unconventional
uses may best be addressed by locally modifying or augmenting the
scripts. Both of the above lead to a situation where there is no one
size fits all installation method and one should be adopted based on
relevant forces and taste.

### Some Options

This is an evolving list; if you have a new option just add it here,
ideally with some guidance around how it compares with other options.

### Copypasta

The simplest solution is to copy and paste scripts from this
repository to your project. Each script herein is designed to be
self-contained to support this use. This has the advantage that there
is no required tooling, there are no impediments to local
modifications, and each script can be managed independently. It has
the notable disadvantage of introducing third-party code into your
source code repository (which is a non-issue if modifications are made
to these scripts).

## Git Submodule

A viable option (if using git) is to pull this repository in as a
submodule. This has the advantages of being manageable through a
simple git command, keeping this code out of your main source
directory, and allowing for controlled updates to the buildsrc
version. This is slightly more complex than copypasta, treats all of
the contained scripts as a unit (rather than allowing scripts to
change independently), and can complicate extension. An example
command to configure this approach could be something like (from the
project root):

```bash
mkdir -p buildsrc
git submodule add https://github.com/mwhipple/buildsrc buildsrc/bc
```

This would link this project to the buildsrc/bc directory which could
allow any local build scripts to be added to the buildsrc
directory. If looking to do anything beyond pulling in a copy of these
scripts, make sure to have an understanding of git submodules.

A fresh checkout may not include the submodule so this can be
complemented by a make target such as:

```make
buildsrc/bc/%: ; git submodule init && git submodule update
```

at the top of a Makefile (prior to any includes) which will update the
submodule as needed.

## Performing a Code Release

The provided `release` script will perform a code release for your project.

### Defining Your Version

The current version of the software in repository should be
defined using a property file that indicates the version. This file
will be read from and written to by the release script, and in normal
use the release script should be the primary means of updating the
version in this file. Conventionally this can be accomplished through
a `build.properties` file in the root of the project which contains
a line such as:

```bash
VERSION=1.0.0-SNAPSHOT
```

Any filename can be provided for the properties file, though currently
the VERSION property should match the pattern above. Some level of
variation could be supported if needed.

### SNAPSHOT versions

It is recommended the version file normally carries a qualifier such
as -SNAPSHOT when a release is not underway.  This makes sure that the
code accurately reflects its associated version, and more importantly
that any artifacts produced outside of a release clearly indicate that
they are not a release and cannot be confused with any released
artifacts with which they may share a version.

### Configuration

The release script should be executable and passed the name of the
properties file containing the version. For example:

```bash
./buildsrc/release build.properties
```

If using make then the recipe should be roughly the same. Most likely
some variables will be used instead:

```make
BUILD_SRC := buildsrc/
PROP_FILE := build.properties

release: ; ${BUILD_SRC}release ${PROP_FILE}
.PHONY: release
```

### What release does

From the perspective of this script a code release corresponds to a
prepared snapshot of your code which should serve as the source for
any further published artifacts. The focus of this script is therefore
to verify that your code is in a consistent state and then create an
annotated git tag to represent the release. This includes any steps
necessary to ensure that the code that is contained within the tag
accurately and completely reflects that state which was used to
produce any deliverables produced for the version.

The release script:

1. checks that the working directory is fully synchronized with the
canonical git ref

2. updates the project version (to remove any qualifier and indicate a
release version)

3. creates and pushes a tag for the version

4. updates the project to a post-release version and commits and
pushes that change

At the end of this flow the release has been pushed in a relatively
atomic way and the working directory is moved forward to be ready to
work on the next version.

### Auto-Confirmation of Prompts

If you are confident that the script will perform a release using
the correct version and post-release version then setting the
`AUTO_VERSION` environment variable to a truthy value will
auto-confirm the prompts for those values thereby providing an
fully automated/non-interactive release process.

### Branch Releases

In addition to releases intended for wide consumption, it may be
useful to "release" something which is still in flux. This is likely
to be the case if the standard development process involves fully
continuous deployments but some form of more controlled promotion is
necessary to use the produced artifacts outside of the standard
development environment and temporary testing in such an environment
is desired.

To facilitate this these scripts have the notion of "branch
releases" which is enabled by setting the BRANCH_RELEASE environment
variable to a truthy value. This will produce the consistent git tag
while avoiding some of the more stringent or comprehensive release
machinery. Such releases will include a `-BRANCH` qualifier to indicate
that they are not proper releases.

### Hooks

The release script itself is primarily focused on the git transactions
necessary to produce a consistent git tag, but there is often likely
to be additional logic need to produce those tags. To support any such
logic, the release script provides hooks into the tag creation
process.

The hooks can be handled through either:

* adding executables to the `RELEASE_HOOK_DIR` directory (by default
the directory containing the release script)

* defining functions which are exposed to the release script during
invocation (this likely requires the use of `export -f`)

In both cases the handler must match a specified pattern and will be
passed parameters documented in the release script itself. Links to
the relevant sections of the script will be provided here.

If you wish to activate any of the handlers included in this project
and have already downloaded them during _Installatiion_, then they most
likely just need to be made executable if they are scripts. If they
define functions then they should be sourced and the functions exported.

The use of function hook handlers _could_ be made more convenient by
having the file sourced within the script but that would also involve
dealing with the assorted failure conditions so for now it's being
avoided. If there's a desire for such functionality then open an issue.

#### Supported Hooks

##### pre_release

After the new version has been selected but prior to pushing the tag,
the pre_release hook will be
called. https://github.com/mwhipple/buildsrc/blob/master/release#L390

##### release_version

In order to determine the identifier of the version to release the
release_version hook will be called.
https://github.com/mwhipple/buildsrc/blob/master/release#L295

##### release_postversion

In order to determine the identifier of the version to commit after
the release has been completed the release_postversion hook will be
called.
https://github.com/mwhipple/buildsrc/blob/master/release#L323

### Additional Configuration

It would normally be advisable to make sure that a project's release
workflow matches conventions and therefore additional configuration
would not be needed, but there may be cases where some aspects of
conformity are not readliy practicable. In cases where local conventions
can be established within a project the script should likely be
locally modified to match those conventions, but some configurable
parameters are exposed for those cases where intra-team consistency
may be out of reach.

#### Changing the Canonical Git Ref

The release script verifies that the current working directory is
fully in sync with a specific branch (normally `master`) on a
specific remote (normally `origin`) and will push the released
tag to that remote. In some workflows it may be desirable to allow
overriding of those conventions which can be accomplished through
setting the following environment variables.

#### `RELEASE_MASTER`

`RELEASE_MASTER` defaults to `master` and indicates the branch which
acts as the primary branch from which releases will be cut.

#### `RELEASE_REMOTE`

`RELEASE_REMOTE` defaults to `origin` and indicates the remote for
which the local ref should be in sync and to which the release tag
will be pushed.

### Troubleshooting

#### General Troubleshooting

The `RELEASE_VERBOSE` environment variable can be set to a truthy
value to output the commands that the `release` script executes.

#### The CHANGELOG hook isn't being run.

Check to make sure that the script is executable. Also try explicitly
setting the `RELEASE_HOOK_DIR` environment variable.


