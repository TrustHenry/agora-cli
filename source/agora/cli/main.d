/*******************************************************************************

    Entry point for the Agora CLI

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.cli.main;

/// Workaround for issue likely related to dub #225,
/// expects a main() function and invokes it after unittesting.
version (unittest) void main () { } else:

/// Application entry point
private int main ()
{
    //  To do
    //  Parse Command Line
    //  Make Transaction
    //  Send Transaction

    return 0;
}
