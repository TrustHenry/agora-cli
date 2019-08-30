/*******************************************************************************

    The Agora CLI test for sendtx command

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.SendTxProcess;

import agora.cli.CLIResult;
import agora.cli.SendTxProcess;
import agora.common.Amount;
import agora.common.crypto.Key;
import agora.common.Data;
import agora.common.Hash;
import agora.consensus.data.Block;
import agora.consensus.data.Transaction;
import agora.node.API;


class TestNode : API
{
    /// Contains the transaction cache
    private Transaction[Hash] tx_cache;

    private KeyPair key_pair;

    /// Ctor
    public this ()
    {
        key_pair = KeyPair.random();
    }

    /// GET /public_key
    public override PublicKey getPublicKey () pure nothrow @safe @nogc
    {
        return this.key_pair.address;
    }

    /// GET: /network_info
    public override NetworkInfo getNetworkInfo () pure nothrow @safe @nogc
    {
        return NetworkInfo();
    }

    public override void putTransaction (Transaction tx) @safe
    {
        auto tx_hash = hashFull(tx);
        if (this.hasTransactionHash(tx_hash))
            return;

        this.tx_cache[tx_hash] = tx;
    }

    /// GET: /hasTransactionHash
    public override bool hasTransactionHash (Hash tx) @safe
    {
        return (tx in this.tx_cache) !is null;
    }

    /// GET: /block_height
    public ulong getBlockHeight ()
    {
        return 0;
    }

    /// GET: /blocks_from
    public const(Block)[] getBlocksFrom
        (ulong block_height, size_t max_blocks)
        @safe
    {
        return null;
    }

    /// GET: /merkle_path
    public Hash[] getMerklePath (ulong block_height, Hash hash) @safe
    {
        return null;
    }
}

unittest
{
    import std.format;
    import std.stdio;

    import geod24.LocalRest;

    string txhash = "0xc40cdf55475fa9d6d65beb3ae3f4026bd7c0c6e419165f6b36ccad6bc7cf95580b8f88df527742012ff9cd72f53f77b4798488c27d66366937777de7ca8e2082";
    uint index = 0;
    string key = "SCT4KKJNYLTQO4TVDPVJQZEONTVVW66YLRWAINWI3FZDY7U4JS4JJEI4";
    string address = "GCKLKUWUDJNWPSTU7MEN55KFBKJMQIB7H5NQDJ7MGGQVNYIVHB5ZM5XP";
    ulong amount = 1000;

    string[] args =
        [
            "program-name",
            "sendtx",
            "--ip=localhost",
            "--port=2826",
            format("--txhash=%s", txhash),
            format("--index=%d", index),
            format("--amount=%d", amount),
            format("--dest=%s", address),
            format("--key=%s", key),
            "--dump"
        ];
    string[] outputs;

    auto node = RemoteAPI!API.spawn!TestNode();
    auto res = sendTxProcess(args, outputs, (address) {
        return node;
    });
    assert (res == CLI_SUCCESS);

    Transaction tx =
    {
        [Input(Hash.fromString(txhash), index)],
        [Output(Amount(amount), PublicKey.fromString(address))]
    };
    Hash send_txhash = hashFull(tx);
    auto key_pair = KeyPair.fromSeed(Seed.fromString(key));
    tx.inputs[0].signature = key_pair.secret.sign(send_txhash[]);

    foreach(ref line; outputs)
        writeln(line);

    assert(node.hasTransactionHash(send_txhash));
}
