import { Dela_Gothic_One } from "next/font/google";
import React from "react";
import HeroSearchField from "./hero-search";

const delaGothicOne = Dela_Gothic_One({
  subsets: ["latin"],
  weight: ["400"],
});

const Hero = ({ inputTxt, handleSubmit, setInputTxt }) => {
  return (
    <div className="relative pb-10 rounded-md overflow-hidden">
      <div className="absolute inset-0 z-0"></div>

      {/* Main content */}
      <div className="relative z-10 pt-20 w-full grid place-items-center">
        <div className={delaGothicOne.className}>
          <p
            className={`text-3xl md:max-w-lg text-center font-extrabold relative`}
          >
            Find Your Memes in Seconds and{" "}
            <span className="relative">
              <span className="relative z-10 text-[#3300FF]">Launch Your Own MemeCoins.</span>
              <svg
                className="absolute bottom-[-10px] left-0 w-full h-[20px] z-0"
                viewBox="0 0 200 20"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  d="M0,10 C40,0 60,20 100,10 C140,0 160,20 200,10"
                  fill="none"
                  stroke="#3300FF"
                  strokeWidth="3"
                  strokeLinecap="round"
                />
              </svg>
            </span>
          </p>
        </div>
        <p className="mt-6 px-10 md:px-0 text-center">
          Explore over 1M+ memes and create your own meme coins in seconds.
        </p>

        <HeroSearchField
          handleSubmit={handleSubmit}
          searchQuery={inputTxt}
          setSearchQuery={setInputTxt}
        />
      </div>
    </div>
  );
};

export default Hero;
