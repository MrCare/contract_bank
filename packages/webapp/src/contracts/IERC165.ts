export const IERC165Config = {
  abi: [
  {
    "type": "function",
    "name": "supportsInterface",
    "inputs": [
      {
        "name": "interfaceId",
        "type": "bytes4",
        "internalType": "bytes4"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "bool",
        "internalType": "bool"
      }
    ],
    "stateMutability": "view"
  }
],
  bytecode: "[object Object]",
} as const;

export type IERC165ABI = typeof IERC165Config.abi;
