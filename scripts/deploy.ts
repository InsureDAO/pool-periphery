/* eslint-disable node/no-missing-import */
import { ethers, run } from "hardhat";

function delay(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function main() {
  const USDC_ADDRESS = "0xf1485Aa729DF94083ab61B2C65EeA99894Aabdb3";
  const OwnershipAddress = "0x7D5A12D2d1F9CCbDfd3eC16F8156B2Dc0dB2EB8A";
  const VaultAddress = "0x0666Ff78b8785Fa495D1c33E3CBCFACB2fd6da00";
  const defaultMaxRebateRate = "100000";

  // define
  const Referral = await ethers.getContractFactory("Referral");
  const referral = await Referral.deploy(USDC_ADDRESS, OwnershipAddress, VaultAddress, defaultMaxRebateRate);

  console.log("Referral deployed to:", referral.address);

  await delay(30000);

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
