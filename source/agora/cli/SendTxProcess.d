/*******************************************************************************

    The Agora CLI sub-function for sendtx command

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.cli.SendTxProcess;

import agora.cli.CLIResult;
import agora.common.Amount;
import agora.common.crypto.Key;
import agora.common.Data;
import agora.common.Hash;
import agora.consensus.data.Block;
import agora.consensus.data.Transaction;
import agora.node.API;

import std.format;
import std.getopt;
import std.stdio;

public alias APIMaker = API delegate (string address);

/// Option required to send transaction
private struct SendTxOption
{
    /// IP address of node
    public string host;

    /// Port of node
    public ushort port;

    /// Hash of the previous transaction
    public string txhash;

    /// The index of the output in the previous transaction
    public uint index;

    /// The seed used to sign the new transaction
    public string key;

    /// The address key to send the output
    public string address;

    /// The amount to spend
    public ulong amount;
}

/// Parse the ommand-line arguments of sendtx (--version, --help)
public GetoptResult parseSendTxOption (ref SendTxOption op, string[] args)
{
    return getopt(
        args,
        "ip|i",
            "IP address of node",
            &op.host,

        "port|p",
            "Port of node",
            &op.port,

        "txhash|t",
            "Hash of the previous transaction",
            &op.txhash,

        "index|n",
            "The index of the output in the previous transaction",
            &op.index,

        "amount|a",
            "The amount to spend",
            &op.amount,

        "dest|d",
            "The address key to send the output",
            &op.address,

        "key|k",
            "The seed used to sign the new transaction",
            &op.key
            );
}

/// Print help
public void printSendTxHelp (ref string[] outputs)
{
    outputs ~= "usage: agora-cli sendtx --ip --port --txhash --index --amount --dest --key";
    outputs ~= "";
    outputs ~= "   sendtx      Send a transaction to node";
    outputs ~= "";
    outputs ~= "        -i --ip      IP address of node";
    outputs ~= "        -p --port    Port of node";
    outputs ~= "        -t --txhash  Hash of the previous transaction that";
    outputs ~= "                     contains the Output which the new ";
    outputs ~= "                     transaction will spend";
    outputs ~= "        -n --index   The index of the output in the previous";
    outputs ~= "                     transaction which will be spent";
    outputs ~= "        -a --amount  The amount to spend";
    outputs ~= "        -d --dest    The address key to send the output";
    outputs ~= "        -k --key     The seed used to sign the new transaction";
    outputs ~= "";
}

/*******************************************************************************

    Input an arguments, generate the transaction and send it to the node

    Params:
        args = Cli command line arguments

*******************************************************************************/

public int sendTxProcess (string[] args, ref string[] outputs,
                            APIMaker api_maker)
{
    SendTxOption op;
    GetoptResult res;

    try
    {
        res = parseSendTxOption(op, args);
        if (res.helpWanted)
        {
            printSendTxHelp(outputs);
            return CLI_SUCCESS;
        }
    }
    catch (Exception ex)
    {
        printSendTxHelp(outputs);
        return CLI_EXCEPTION;
    }

    bool isValid = true;

    if (op.host == "")
        op.host = "localhost";

    if (op.port == 0)
        op.port = 2826;

    if (op.txhash.length == 0)
    {
        if (isValid) printSendTxHelp(outputs);
        outputs ~= "Previous Transaction hash is not entered.[--txhash]";
        isValid = false;
    }

    if (op.amount == 0)
    {
        if (isValid) printSendTxHelp(outputs);
        outputs ~= "Amount is not entered.[--amount]";
        isValid = false;
    }

    if (op.address.length == 0)
    {
        if (isValid) printSendTxHelp(outputs);
        outputs ~= "Address is not entered.[--dest]";
        isValid = false;
    }

    if (op.key.length == 0)
    {
        if (isValid) printSendTxHelp(outputs);
        outputs ~= "Key is not entered.[--key]";
        isValid = false;
    }

    if (!isValid)
        return CLI_INVALIDE_AGUMENTS;

    // create the transaction
    auto key_pair = KeyPair.fromSeed(Seed.fromString(op.key));

    Transaction tx =
    {
        [Input(Hash.fromString(op.txhash), op.index)],
        [Output(Amount(op.amount), PublicKey.fromString(op.address))]
    };

    auto signature = key_pair.secret.sign(hashFull(tx)[]);
    tx.inputs[0].signature = signature;

    // connect to the node
    string ip_address = format("http://%s:%s", op.host, op.port);
    auto node = api_maker(ip_address);

    // send the transaction
    node.putTransaction(tx);

    return CLI_SUCCESS;
}
