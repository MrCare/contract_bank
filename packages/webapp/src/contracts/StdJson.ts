export const StdJsonConfig = {
  abi: [],
  bytecode: "[object Object]",
} as const;

export type StdJsonABI = typeof StdJsonConfig.abi;
