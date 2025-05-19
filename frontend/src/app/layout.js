'use client';
import { Poppins } from "next/font/google";
import "./globals.css";
import Navbar from "@/modules/navbar";
import PrivyWrapper from "@/privy/privyProvider";
import ConnectWallet from "@/components/wallet-checker";
import { useEffect } from 'react';

const poppins = Poppins({
  subsets: ["latin"],
  weight: ["100", "200", "300", "400", "500", "600", "700", "800", "900"],
});

// Metadata needs to be handled differently for client components
// Create a separate metadata.js file in the app directory
function RootLayout({ children }) {
  // Update metadata on client-side
  useEffect(() => {
    document.title = "What are MemeCoins";
    document.querySelector('meta[name="description"]')?.setAttribute(
      "content",
      "Find memes and creating your own meme coins in seconds"
    );
  }, []);

  return (
    <html lang="en">
      <body className={poppins.className}>
        <PrivyWrapper>
          <ConnectWallet>
            <>
              <Navbar />
              {children}
            </>
          </ConnectWallet>
        </PrivyWrapper>
      </body>
    </html>
  );
}

export default RootLayout;