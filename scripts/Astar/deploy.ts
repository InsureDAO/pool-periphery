import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Contract, ContractFactory, constants, BigNumber, Bytes } from "ethers";

import { OwnershipArtifact, USDCArtifact, VaultArtifact } from "../../test/Utils/artifacts";
import { USDCAddress, OwnershipAddress, VaultAddress } from "./deployments";
import { defaultMaxRebateRate } from "./config";

async function main() {
  //define
  let creator: SignerWithAddress;
  let Referral: ContractFactory;
  let referral: Contract;

  //import
  [creator] = await ethers.getSigners();
  Referral = await ethers.getContractFactory("Referral");

  console.log("USDCAddress", USDCAddress);
  console.log("OwnershipAddress", OwnershipAddress);
  console.log("VaultAddress", VaultAddress);
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
