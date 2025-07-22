export const StringsConfig = {
  abi: [
  {
    "type": "error",
    "name": "StringsInsufficientHexLength",
    "inputs": [
      {
        "name": "value",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "length",
        "type": "uint256",
        "internalType": "uint256"
      }
    ]
  },
  {
    "type": "error",
    "name": "StringsInvalidAddressFormat",
    "inputs": []
  },
  {
    "type": "error",
    "name": "StringsInvalidChar",
    "inputs": []
  }
],
  bytecode: "[object Object]",
} as const;

export type StringsABI = typeof StringsConfig.abi;
