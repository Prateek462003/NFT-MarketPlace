require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
const {API_KEY, PRIVATE_KEY} = process.env ;

module.exports = {
  solidity: "0.8.18",
  networks:{
    mumbai:{
      url : API_KEY,
      accounts : [`0x${PRIVATE_KEY}`]
    }
  }
};
