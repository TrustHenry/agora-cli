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
import agora.common.Amount;
import agora.common.crypto.Key;
import agora.common.Data;
import agora.common.Hash;
import agora.consensus.data.Block;
import agora.consensus.data.Transaction;
import agora.node.API;

import vibe.core.core;
import vibe.web.rest;

import std.format;
import std.getopt;
import std.stdio;

/// Application entry point
private int main (string[] args)
{
    try
    {
        sendTransaction(args);

        return 0;
    }
    catch (Exception ex)
    {
        writefln("Failed to processing. Error: %s", ex.message);
        return 1;
    }
}

/*******************************************************************************

    Input an arguments, generate the transaction and send it to the node

    Params:
        args = Cli command line arguments

*******************************************************************************/

public void sendTransaction (string[] args)
{
    CommandLine cmd;

    try
    {
        auto help = parseCommandLine(cmd, args);
        if (help.helpWanted)
            defaultGetoptPrinter("The Agora cli", help.options);
    }
    catch (Exception ex)
    {
        writefln("Error parsing command-line arguments '%(%s %)': %s", args,
            ex.message);
    }

    // create the transaction
    Transaction transaction;
    auto key_pair = KeyPair.fromSeed(Seed.fromString(cmd.key));
    Hash pre_tx_hash = cmd.txhash;
    Input input = Input(pre_tx_hash, cmd.index);

    Transaction tx =
    {
        [input],
        [Output(Amount(cmd.amount), key_pair.address)]
    };

    auto signature = key_pair.secret.sign(hashFull(tx)[]);
    tx.inputs[cmd.index].signature = signature;

    // connect to the node
    string ip_address = format("http://%s:%s", cmd.host, cmd.port);
    auto node = new RestInterfaceClient!API(ip_address);

    // send the transaction
    node.putTransaction(tx);
}
