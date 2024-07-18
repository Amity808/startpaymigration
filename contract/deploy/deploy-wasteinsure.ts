import { deployContract } from "./utils";


export default async function () {
    const contractArtifactName = "WasteInsured";
    // const constructorArguments = ["0x0000000000000000000000000000000000000000"];
    await deployContract(contractArtifactName);
}

// "GeneralPaymaster" was successfully deployed:
//  - Contract address: 0x7afF0B53fe17231195968869c39B1D33599eDaB1
//  - Contract source: contracts/paymasters/GeneralPaymaster.sol:GeneralPaymaster
//  - Encoded constructor arguments: 0x

// Starting deployment process of "WasteInsured"...
// Estimated deployment cost: 0.00043778425 ETH

// "WasteInsured" was successfully deployed:
//  - Contract address: 0xeE571028e2889e4e0a4c10Ad60Fbf177A2932462
//  - Contract source: contracts/WasteInsured/WasteInsured.sol:WasteInsured
//  - Encoded constructor arguments: 0x

// Requesting contract verification...
// Your verification ID is: 18140