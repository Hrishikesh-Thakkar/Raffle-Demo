const ENTRANCE_FEE = ethers.utils.parseEther("0.1")
console.log("Entrance FEE: "+ENTRANCE_FEE);

module.exports = async ({getNamedAccounts, deployments}) => {
    const {deploy,log} = deployments
    const {deployer} = await getNamedAccounts();

    const args = 
    [ENTRANCE_FEE,
    "300",
    "0x6168499c0cFfCaCD319c818142124B7A15E857ab", 
    "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc",
    "3748",
    "500000",]

 //deploy
 const raffle = await deploy("Raffle", {
     from: deployer,
     args: args,
     log: true,
     waitConfirmations: 6,
 })
}