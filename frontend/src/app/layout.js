import { Poppins } from "next/font/google";
import "./globals.css";
import Navbar from "@/modules/navbar";
import AptosWalletProvider from "@/wallet-provider/aptos-wallet-provider";
import PrivyWrapper from "@/privy/privyProvider";
import ConnectWallet from "@/components/wallet-checker";

const poppins = Poppins({
  subsets: ["latin"],
  weight: ["100", "200", "300", "400", "500", "600", "700", "800", "900"],
});

export const metadata = {
  title: "What are MemeCoins",
  description: "Find memes and creating your own meme coins in seconds",
};

export default function RootLayout({ children }) {
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
