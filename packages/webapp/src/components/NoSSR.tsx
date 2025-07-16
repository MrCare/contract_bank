/*
 * @Author: Mr.Car
 * @Date: 2025-07-16 16:58:49
 */
'use client';

import { useEffect, useState } from 'react';

interface NoSSRProps {
  children: React.ReactNode;
}

export default function NoSSR({ children }: NoSSRProps) {
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  if (!mounted) {
    return null;
  }

  return <>{children}</>;
}
