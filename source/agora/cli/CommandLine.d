/*******************************************************************************


    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.cli.CommandLine;

import std.getopt;

/// Command-line arguments
public struct CommandLine
{
    /// Path to the config file
    public string host;
    public ushort port;

    public string txhash;
    public uint index;

    public string key;

    public string address;
    public ulong amount;
}

/// Parse the command-line arguments and return a GetoptResult
public GetoptResult parseCommandLine (ref CommandLine cmdline, string[] args)
{
    return getopt(
        args,
        "ip|i",
            "IP address of node",
            &cmdline.host,

        "port|p",
            "Port of node",
            &cmdline.port,

        "txhash|x",
            "Hash of input transaction",
            &cmdline.txhash,

        "index|n",
            "Index of input transaction",
            &cmdline.index,

        "amount|a",
            "Amount",
            &cmdline.amount,

        "address|t",
            "destination address",
            &cmdline.address,

        "key|k",
            "seed of key",
            &cmdline.key
            );
}
