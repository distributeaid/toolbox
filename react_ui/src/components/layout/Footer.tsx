import React from 'react'

// TODO: factor out buttons into reusable component - add the appropriate props to Button.tsx

export const Footer: React.FC = () => (
  <footer className="mt-5 pt-24 pb-14 pl-3 pl-2 md:px-3 lg:pl-14 lg:pr-14 bg-gray-900 text-gray-100">
    <div className="block md:flex md:space-between">
      <div className="column flex-1 mr-3">
        <div className="heading whitespace-no-wrap text-gray-200 mb-3 text-3xl text-white">
          Let's get PPE to <br />
          workers on the <br />
          frontlines.
        </div>
        <div style={{ width: 200 }}>
          <button
            type="button"
            className="mb-5 w-full bg-blue-600 hover:border-transparent hover:text-blue-900 hover:bg-white text-white font-medium shadow-button-white py-2 px-3 flex justify-center rounded-sm">
            Request Supplies
          </button>
          <button
            type="button"
            className="w-full bg-orange-100 hover:border-transparent hover:text-orange-700 hover:bg-white text-black font-medium shadow-button-white py-2 px-3 flex justify-center rounded-sm">
            Get Involved
          </button>
        </div>
      </div>

      <div className="flex-1 mt-10 md:mt-0 flex">
        <div className="flex-1 flex space-around flex">
          <div className="column flex-1 pr-5">
            <div className="heading text-gray-200 mb-7 text-sm text-white uppercase semi-bold">
              About Us
            </div>
            <div className="item text-xs font-light mb-3">
              <a href="/mission">Our Mission</a>
            </div>
            <div className="item text-xs font-light mb-3">
              <a href="/whoweare">Who We Are</a>
            </div>
            <div className="item text-xs font-light mb-3">
              <a href="/success-stories">Success Stories</a>
            </div>
          </div>
          <div className="column flex-1 px-5">
            <div className="heading text-gray-200 mb-7 text-sm text-white uppercase semi-bold">
              Resources
            </div>
            <div className="item text-xs font-light mb-3">
              <a href="/covid10-updates" target="_blank">
                COVID-19 Updates
              </a>
            </div>
            <div className="item text-xs font-light mb-3">
              <a href="/field-guides" target="_blank">
                Field Guies
              </a>
            </div>
            <div className="item text-xs font-light mb-3">
              <a href="/local-chapters" target="_blank">
                Local Chapters
              </a>
            </div>
            <div className="item text-xs font-light mb-3">
              <a href="/login" target="_blank">
                Local Lead Login
              </a>
            </div>
          </div>
          <div className="column flex-1 px-5">
            <div className="heading text-gray-200 mb-7 text-sm text-white uppercase semi-bold">
              More
            </div>
            <div className="item text-xs font-light mb-3">
              <a href="/tos" target="_blank">
                Terms of Use
              </a>
            </div>
            <div className="item text-xs font-light mb-3">
              <a href="/privacy" target="_blank">
                Privacy Policy
              </a>
            </div>
            <div className="item text-xs font-light mb-3">
              <a href="/code-of-conduct" target="_blank">
                Code of Conduct
              </a>
            </div>
            <div className="item text-xs font-light mb-3">
              <a href="/contact" target="_blank">
                Contact Us
              </a>
            </div>
            <div className="heading text-gray-200 mt-10 text-lg">
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
      <div className="flex items-center">
        &copy; 2020 Masks For Docs Foundation
      </div>
      <div className="flex justify-end flex-1 pr-14">
        {/* <div className="m-2">
          <a href="https://.com/discover/popular#recent" target="_blank">
            <img
              className="w-6 h-6"
              src="https://d3e54v103j8qbb.cloudfront.net/img/-black.ef3f174957.svg"
            />
          </a>
        </div>
        <div className="m-2">
          <a href="https://www.youtube.com/" target="_blank">
            <img
              className="w-6 h-6"
              src="https://d3e54v103j8qbb.cloudfront.net/img/youtube-black.68dd269ade.svg"
            />
          </a>
        </div> */}
        <div className="m-2">
          <a href="https://twitter.com/MasksForDocs" target="_blank">
            <img
              className="w-6 h-6"
              src="https://d3e54v103j8qbb.cloudfront.net/img/twitter-black.596d4717a4.svg"
            />
          </a>
        </div>
        <div className="m-2">
          <a href="https://www.facebook.com/MasksForDocs/" target="_blank">
            <img
              className="w-6 h-6"
              src="https://d3e54v103j8qbb.cloudfront.net/img/fb-black.2aa4f89c90.svg"
            />
          </a>
        </div>
        <div className="m-2">
          <a href="https://www.instagram.com/masksfordocs/" target="_blank">
            <img
              className="w-6 h-6"
              src="https://d3e54v103j8qbb.cloudfront.net/img/insta-black.7a9a600ec2.svg"
            />
          </a>
        </div>
      </div>
    </div>
  </footer>
)
