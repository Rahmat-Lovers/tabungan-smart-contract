require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config()

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.18",
  networks: {
    fuji: {
      url: `https://avalanche-fuji.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts: [process.env.ETH_PRIVATE_KEY]
    }
  }
};
