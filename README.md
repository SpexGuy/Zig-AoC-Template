# Advent Of Code Zig Template

This repo provides a template for Advent of Code participants using Zig.  It contains a main file for each day, a build.zig file set up with targets for each day, and Visual Studio Code files for debugging.

### How to use this template:

The src/ directory contains a main file for each day.  Put your code there.  The build command `zig build dayXX [target and mode options] -- [program args]` will build and run the specified day.  You can also use `zig build install_dayXX [target and mode options]` to build the executable for a day and put it into `zig-cache/bin` without executing it.  By default this template does not link libc, but you can set `should_link_libc` to `true` in build.zig to change that.  If you have files with tests, add those files to the list of test files in build.zig.  The command `zig build test` will run tests in all of these files.

This repo also contains Visual Studio Code project files for debugging.  These are meant to work with the C/C++ plugin.  There is a debug configuration for each day.  By default all days are built in debug mode, but this can be changed by editing `.vscode/tasks.json` if you have a need for speed.

If you would like to contribute project files for other development environments, please send a PR.
