/*
 * @Author: Mr.Car
 * @Date: 2025-07-16 14:24:26
 */
const fs = require('fs');
const path = require('path');

const OUT_DIR = path.join(__dirname, '../out');
const CONTRACTS_DIR = path.join(__dirname, '../packages/webapp/src/contracts');

// 确保输出目录存在
if (!fs.existsSync(CONTRACTS_DIR)) {
  fs.mkdirSync(CONTRACTS_DIR, { recursive: true });
}

// 获取所有合约
const contracts = fs.readdirSync(OUT_DIR, { withFileTypes: true })
  .filter(dirent => dirent.isDirectory())
  .map(dirent => dirent.name.replace('.sol', ''));

contracts.forEach(name => {
  try {
    const artifactPath = path.join(OUT_DIR, `${name}.sol`, `${name}.json`);
    if (!fs.existsSync(artifactPath)) return;
    
    const { abi, bytecode } = JSON.parse(fs.readFileSync(artifactPath, 'utf8'));
    
    // 生成TS文件
    const content = `export const ${name}Config = {
  abi: ${JSON.stringify(abi, null, 2)},
  bytecode: "${bytecode}",
} as const;

export type ${name}ABI = typeof ${name}Config.abi;
`;
    
    fs.writeFileSync(path.join(CONTRACTS_DIR, `${name}.ts`), content);
    console.log(`✅ ${name}`);
  } catch (e) {
    console.log(`❌ ${name}: ${e.message}`);
  }
});

// 生成统一导出
const indexContent = contracts.map(name => 
  `export * from './${name}';`
).join('\n');

fs.writeFileSync(path.join(CONTRACTS_DIR, 'index.ts'), indexContent);
console.log(`🎉 Generated ${contracts.length} contracts`);
