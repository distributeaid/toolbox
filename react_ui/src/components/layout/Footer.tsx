import React from 'react'

// TODO: factor out buttons into reusable component - add the appropriate props to Button.tsx
// TODO use our own social icons assets

export const Footer: React.FC = () => (
  <footer className="mt-5 pt-24 pb-14 pl-3 pl-2 md:px-8 lg:px-14 bg-gray-900 text-gray-100">
    <div className="block md:flex md:space-between">
      <div className="flex-1 mr-3">
        <div className="whitespace-no-wrap text-gray-200 mb-3 text-3xl text-white">
          Let's get PPE to <br />
          workers on the <br />
          frontlines.
        </div>
        {/* <div style={{ width: 200 }}>
          <button
            type="button"
            className="shadow-button-white mb-5 w-full bg-blue-600 hover:border-transparent hover:text-blue-900 hover:bg-white text-white font-medium py-2 px-3 flex justify-center rounded-sm">
            Request Supplies
          </button>
          <button
            type="button"
            className="shadow-button-white w-full bg-orange-100 hover:border-transparent hover:text-orange-700 hover:bg-white text-black font-medium py-2 px-3 flex justify-center rounded-sm">
            Get Involved
          </button>
        </div> */}
      </div>

      <div className="flex-1 mt-10 md:mt-0 flex">
        <div className="flex-1 flex space-around flex">
          <div className="flex-1 pr-5">
            <div className="text-gray-200 mb-7 text-sm text-white uppercase semi-bold">
              About Us
            </div>
            <div className="text-xs font-light mb-3">
              <a href="/mission">Our Mission</a>
            </div>
            <div className="text-xs font-light mb-3">
              <a href="/whoweare">Who We Are</a>
            </div>
            <div className="text-xs font-light mb-3">
              <a href="/success-stories">Success Stories</a>
            </div>
          </div>
          <div className="flex-1 px-5">
            <div className="text-gray-200 mb-7 text-sm text-white uppercase semi-bold">
              Resources
            </div>
            <div className="text-xs font-light mb-3">
              <a href="/covid10-updates">COVID-19 Updates</a>
            </div>
            <div className="text-xs font-light mb-3">
              <a href="/field-guides">Field Guides</a>
            </div>
            <div className="text-xs font-light mb-3">
              <a href="/local-chapters">Local Chapters</a>
            </div>
            <div className="text-xs font-light mb-3">
              <a href="/login">Local Lead Login</a>
            </div>
          </div>
          <div className="flex-1 px-5">
            <div className="text-gray-200 mb-7 text-sm text-white uppercase semi-bold">
              More
            </div>
            <div className="text-xs font-light mb-3">
              <a href="/tos">Terms of Use</a>
            </div>
            <div className="text-xs font-light mb-3">
              <a href="/privacy">Privacy Policy</a>
            </div>
            <div className="text-xs font-light mb-3">
              <a href="/code-of-conduct">Code of Conduct</a>
            </div>
            <div className="text-xs font-light mb-3">
              <a href="/contact">Contact Us</a>
            </div>
            <div className="text-gray-200 mt-10 text-lg">
              <a
                href="/donate"
                className="bg-pink-500 inline-block text-sm px-4 py-2 leading-none rounded hover:border-transparent hover:text-pink-700 hover:bg-white mt-4 lg:mt-0">
                Donate
              </a>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div className="mt-20 text-xs flex space-between">
      <div className="flex items-center mr-3">
        &copy; 2020 Masks For Docs Foundation
      </div>
      <div className="flex justify-end flex-1 pr-3 sm:pr-14">
        {/* <div className="m-2">
          <a href="https://.com/discover/popular#recent">
            <img
              className="w-6 h-6"
              src="https://d3e54v103j8qbb.cloudfront.net/img/-black.ef3f174957.svg"
            />
          </a>
        </div>
        <div className="m-2">
          <a href="https://www.youtube.com/">
            <img
              className="w-6 h-6"
              src="https://d3e54v103j8qbb.cloudfront.net/img/youtube-black.68dd269ade.svg"
            />
          </a>
        </div> */}
        <div className="rounded-full bg-white w-8 h-8 flex items-center justify-center m-2">
          <a href="https://twitter.com/MasksForDocs">
            <img
              alt="twitter-social"
              className="w-6 h-6"
              src="https://d3e54v103j8qbb.cloudfront.net/img/twitter-black.596d4717a4.svg"
            />
          </a>
        </div>
        <div className="rounded-full bg-white w-8 h-8 flex items-center justify-center m-2">
          <a href="https://www.facebook.com/MasksForDocs/">
            <img
              alt="facebook-social"
              className="w-6 h-6"
              src="https://d3e54v103j8qbb.cloudfront.net/img/fb-black.2aa4f89c90.svg"
            />
          </a>
        </div>
        <div className="rounded-full bg-white w-8 h-8 flex items-center justify-center m-2">
          <a href="https://www.instagram.com/masksfordocs/">
            <img
              alt="instagram-social"
              className="w-6 h-6"
              src="https://d3e54v103j8qbb.cloudfront.net/img/insta-black.7a9a600ec2.svg"
            />
          </a>
        </div>
      </div>
    </div>
  </footer>
)
