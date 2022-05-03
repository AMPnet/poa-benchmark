# Private Blockchain Benchmark Tool

Tests the throughput of the given blockchain network.
This simple tools allows for connecting to arbitrary EVM blockchain network and calling the state changing function on the predeployed smart contract.

## File structure

The deployed smart contract source code and the artifact must be stored in the ```src``` subfolder. The deployed smart contract is then registered in the ```networks/networkconfig.json```.

In the given ```networks/networkconfig.json.example``` example the `Swapper` is registered under the `"swapper"` id and referenced as such in the benchmark specification.

The benchmark specification can be found in ```benchmarks/config.yaml```. Config in this repo is going to spawn 50 worker processes (`test.worker.number=50`) simulating 50 different clients connected to the blockchain network.
This pool of workers combined will generate load of 10 transactions per second (`test.rounds.rateControl.opts.tps=10`), and in total 20000 transactions will be generated and broadcasted (`test.rounds.txNumber=20000`). Workload (`test.rounds.workload.module`) is pointing to the `benchmarks/workloads/swap.js` file. This file contains the transaction data to be used for every worker. The transaction data is defined in the `submitTransaction()` function and in the given `swap.js` example it is set to call the `swapAtoB()` by providing number 1 as the only parameter in this function call. The function call is executed on the `"swapper"` contract defined in the network config.

Hint: To use different wallets for every of the spawned workers, `fromAddressSeed` field must be defined in the network config. If only the `fromAddressPrivateKey` is defined, then all of the workers will use the same wallet for the transactions and the nonce issues might occur when generating large number of transactions. [See here]() for more info on how to define blockchain network configuration.

## Run the benchmark

Make sure you've got [**npm**](https://www.npmjs.com/) and the [**npx**](https://www.npmjs.com/package/npx) installed before following the next steps.


### 1. Configure the Blockchain Network

```bash
cp ./networks/networkconfig.json.example ./networks/networkconfig.json
```
and then edit the `networkconfig.json` file with the actual data, blockchain network params and the contract to be tested.

### 2. Configure the Transaction

Edit the files in `./benchmarks` to enable calling the function on the contract of your choice. This step might include adding new contracts in `./src`, then defining the contract id and the deployed address in the `./networks/networkconfig.json`. The function name and arguments to be called for each transaction in this example are defined in the `./benchmarks/workloads/swap.js`.

### 3. Install dependencies

```bash
npm install
```

### 4. Bind SUT

```bash
npx caliper bind --caliper-bind-sut ethereum:latest
```

### 5. Start tests

```bash
npx caliper launch manager \
    --caliper-workspace . \
    --caliper-networkconfig ./networks/networkconfig.json \
    --caliper-benchconfig ./benchmarks/config.yaml \
    --caliper-flow-only-test \
    -v
```

Once the test is completed, the resulting html report will be generated in the project root folder.

## Reports

The reports generated for the AMPnet private chain can be found in the `./reports` .
