/*
 * @Author: Mr.Car
 * @Date: 2025-07-16 17:02:08
 */
export const cyberpunkTheme = {
  colors: {
    // 主色调
    primary: '#00f5ff', // 青色霓虹
    secondary: '#ff00ff', // 紫色霓虹
    accent: '#00ff41', // 绿色霓虹
    warning: '#ffff00', // 黄色霓虹
    danger: '#ff0040', // 红色霓虹
    
    // 背景色
    background: '#0a0a0a',
    surface: '#1a1a1a',
    card: '#0f0f0f',
    
    // 文字色
    text: '#ffffff',
    textSecondary: '#a0a0a0',
    textMuted: '#606060',
    
    // 边框和分割线
    border: '#333333',
    borderGlow: '#00f5ff',
  },
  
  effects: {
    glow: 'drop-shadow(0 0 8px var(--glow-color))',
    textGlow: 'text-shadow: 0 0 10px currentColor',
    neonBorder: 'border: 1px solid var(--border-color); box-shadow: 0 0 10px var(--border-color)',
  },
  
  fonts: {
    mono: 'var(--font-geist-mono)',
    sans: 'var(--font-geist-sans)',
  },
} as const;
