import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-verify";
import dotenv from 'dotenv';

dotenv.config ();

const PRIVATE_KEY: string = process.env.PRIVATE_KEY as string;

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 100,
      },
      viaIR: true,
    },
  },
  // defaultNetwork: "sepolia",
  networks: {
    sepolia: {
      url: process.env.SEPOLIA_URL,
      accounts: [PRIVATE_KEY],
    },
    goerli: {
      url: process.env.GOERLI_URL,
      accounts: [PRIVATE_KEY],
    },
    mantle: {
      url: process.env.MANTLE_URL,
      accounts: [PRIVATE_KEY]
    },
    etc: {
      url: process.env.ETC_URL,
      accounts: [PRIVATE_KEY]
    },
    polygon: {
      url: process.env.POLYGON_URL,
      accounts: [PRIVATE_KEY]
    },
    opt: {
      url: process.env.OPTIMISM_URL,
      accounts: [PRIVATE_KEY]
    },
    arbitrum: {
      url: process.env.ARBITRUM_URL,
      accounts: [PRIVATE_KEY]
    },
    base: {
      url: process.env.BASE_URL,
      accounts: [PRIVATE_KEY]
    },
    bsc: {
      url: process.env.BSC_URL,
      accounts: [PRIVATE_KEY]
    },
    scroll: {
      url: process.env.SCROLL_URL,
      accounts: [PRIVATE_KEY]
    },
    artio_testnet: {
      url: process.env.ARTIO_URL,
      accounts: [PRIVATE_KEY]
    },
  },
  etherscan: {
    apiKey: {
      goerli: process.env.ETHERSCAN_KEY!,
      sepolia: process.env.ETHERSCAN_KEY!,
      polygon: process.env.POLYGONSCAN_KEY!,
      mantle: "any",
      etc: process.env.ETCSCAN_KEY!,
      bsc: process.env.BSCSCAN_API_KEY!,
      scroll: process.env.SCROLLSCAN_KEY!,
      artio_testnet: "artio_testnet"
    },
    customChains: [
      {
        network: "mantle",
        chainId: 5000,
        urls: {
          apiURL: "https://api.routescan.io/v2/network/mainnet/evm/5000/etherscan",
          browserURL: "https://mantlescan.info"
        }
      },
      {
        network: "etc",
        chainId: 61,
        urls: {
          apiURL: "https://etc.blockscout.com/api",
          browserURL: "https://etc.blockscout.com/"
        }
      },
      {
        network: "polygon",
        chainId: 137,
        urls: {
          apiURL: "https://api.polygonscan.com/api",
          browserURL: "https://polygonscan.com/"
        }
      },
      {
        network: "artio_testnet",
        chainId: 80085,
        urls: {
          apiURL: "https://api.routescan.io/v2/network/testnet/evm/80085/etherscan",
          browserURL: "https://artio.beratrail.io"
        }
      },
      {
        network: "scroll",
        chainId: 534352,
        urls: {
          apiURL: "https://api.scrollscan.com/api",
          browserURL: "https://api.scrollscan.com"
        }
      }
    ]
  },
  sourcify: {
    enabled: true,
  },
};

export default config;