require("hardhat-deploy")
require("@nomiclabs/hardhat-waffle")
/**q
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  networks: {
    rinkeby: {
      url: "https://rinkeby.infura.io/v3/46b4277f47404a41a92f2b9c0264f7ca",
      accounts: ["8bf99d4e9c94e347832581f69cce6e96919151d5cb3147da05c7aed565bb25ae"],
      chainId: 4,
      saveDeployments: true,
    }
  },
  namedAccounts:{
    deployer: {
      default: 0,
    },
  },
  solidity: "0.8.7",
};
