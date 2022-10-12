# Description

Software and a toolkit for creating a bridge between heterogeneous blockchains for data transferring between them.

## How to use

1. Implement `MessageProcessor` interface in your project
2. Call bridge's method `initMessage` by contract  address (list of address below). 
3. Contract generate `Message`
4. Caller must send some `Gas` (or other token) for fee
5. Volhv (relay part of Mastermost) will get system event `MessageCreated`
6. Volhv call destination contract in destination network with data from your `Message`
7. (optional) Volhv return data to your `MessageProcessor`

### Who is mister Volhv?

Volhv is a cluster nodes which should monitoring Bridge contract in several blockchains. 

When they found event `MessageCreated` they must 
1. Get fee from caller. __Do you want get fee too?__ Run volhv and raise money.
2. Generate signature by treshold signature scheme wia sMPC 
3. Call `Bridge` contract for execute Message by method `executeMsgs`

## Networks

- [ ] Ethereum mainnet
- [ ] Goerli
- [ ] ...

## Contribution

If you found issuue: [New Issue](https://github.com/druzhcom/mastermost/issues/new)

If you know how to improve something [Pull Request](https://github.com/druzhcom/mastermost/pulls)
