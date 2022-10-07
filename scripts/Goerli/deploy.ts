/* eslint-disable node/no-missing-import */
import { ethers } from "hardhat";
import { Contract, ContractFactory } from "ethers";

import { USDCAddress, OwnershipAddress, VaultAddress } from "./deployments";
import { defaultMaxRebateRate } from "./config";

async function main() {
  // define
  let Referral: ContractFactory;
  let referral: Contract;

  // import
  Referral = await ethers.getContractFactory("Referral");

  console.log("defaultMaxRebateRate", defaultMaxRebateRate);

  referral = await Referral.deploy(USDCAddress, OwnershipAddress, VaultAddress, defaultMaxRebateRate);

  console.log("Referral deployed to:", referral.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
