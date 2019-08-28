/*******************************************************************************

    Entry point for the Agora CLI

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.cli.main;

import agora.cli.CommandLine;

import vibe.core.core;

/// Application entry point
import std.getopt;
import std.stdio;

/// Workaround for issue likely related to dub #225,
/// expects a main() function and invokes it after unittesting.
version (unittest) void main () { } else:

/// Application entry point
private int main (string[] args)
{
    CommandLine cmdLine;
    try
    {
        auto help = parseCommandLine(cmdLine, args);
        if (help.helpWanted)
        {
            defaultGetoptPrinter("The Agora cli", help.options);
            return 0;
        }
    }
    catch (Exception ex)
    {
        writefln("Error parsing command-line arguments '%(%s %)': %s", args,
            ex.message);
    }

    try
    {
        //  To do
        //  Make Transaction
        //  Send Transaction
        return 0;
    }
    catch (Exception ex)
    {
        writefln("Failed to processing. Error: %s", ex.message);
        return 1;
    }
}
