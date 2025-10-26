const hre = require("hardhat");

async function main() {
  console.log("🚀 Starting ChainVertex deployment...\n");

  try {
    const [deployer] = await hre.ethers.getSigners();
    console.log("📝 Deploying contract with account:", deployer.address);
    console.log("Account balance:", (await deployer.getBalance()).toString());

    const Project = await hre.ethers.getContractFactory("Project");
    console.log("\n⏳ Deploying Project contract...");

    const project = await Project.deploy();
    await project.waitForDeployment();

    const contractAddress = await project.getAddress();
    console.log("\n✅ ChainVertex (Project) deployed successfully!");
    console.log("📍 Contract Address:", contractAddress);

    console.log("\n" + "=".repeat(60));
    console.log("DEPLOYMENT SUMMARY");
    console.log("=".repeat(60));
    console.log("Contract Name:     Project (ChainVertex)");
    console.log("Deployed Address:  " + contractAddress);
    console.log("Deployer Address:  " + deployer.address);
    console.log("=".repeat(60));

  } catch (error) {
    console.error("\n❌ Deployment failed:");
    console.error(error);
    process.exitCode = 1;
  }
}

main();