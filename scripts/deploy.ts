/* eslint-disable node/no-missing-import */
import { ethers, run } from "hardhat";

function delay(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function main() {
  const USDC_ADDRESS = "0xA2025B15a1757311bfD68cb14eaeFCc237AF5b43";
  const OwnershipAddress = "0x2D78C205955154Fe58beb123ACE93A8aDca86dBC";
  const VaultAddress = "0x39c04722F1030ACe40d98546883BfB8f919fc837";
  const defaultMaxRebateRate = "100000";

  // define
  const Referral = await ethers.getContractFactory("Referral");
  const referral = await Referral.deploy(USDC_ADDRESS, OwnershipAddress, VaultAddress, defaultMaxRebateRate);
  await referral.deployed();

  console.log("Referral deployed to:", referral.address);

  await delay(30000); // wait for etherscan to register the bytecode

  try {
    await run("verify:verify", {
      address: referral.address,
      constructorArguments: [USDC_ADDRESS, OwnershipAddress, VaultAddress, defaultMaxRebateRate],
    });
  } catch (e) {
    console.log("Verify for referral is skipped reason for: ", e);
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
