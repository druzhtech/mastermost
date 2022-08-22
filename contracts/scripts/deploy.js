async function main() {
    const Mastermost = await hre.ethers.getContractFactory("Mastermost");
    const mastermost = await Mastermost.deploy();

    await mastermost.deployed();

    console.log("Mastermost deployed to:", mastermost.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
