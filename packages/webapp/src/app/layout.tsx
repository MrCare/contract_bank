/*
 * @Author: Mr.Car
 * @Date: 2025-07-16 15:13:26
 */

import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";
import Providers from '../components/Providers';
import NoSSR from '../components/NoSSR';

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "TokenBank DApp",
  description: "Cartoken CTK",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className={`${geistSans.variable} ${geistMono.variable}`}>
        <NoSSR>
          <Providers>
            {children}
          </Providers>
        </NoSSR>
      </body>
    </html>
  );
}
