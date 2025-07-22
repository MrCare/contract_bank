export const ScriptConfig = {
  abi: [
  {
    "type": "function",
    "name": "IS_SCRIPT",
    "inputs": [],
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

export type ScriptABI = typeof ScriptConfig.abi;
