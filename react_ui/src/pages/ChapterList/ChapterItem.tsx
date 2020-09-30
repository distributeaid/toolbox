import React from 'react'
import { NavLink } from 'react-router-dom'

import { provinceLongName } from './utils'

export const ChapterItem: React.FC<{
  chapter: {
    name: string
    slug: string
    location: { province: string; countryCode: string }
  }
}> = ({ chapter }) => (
  <li className="border border-collapse border-gray-200 bg-white font-heading fill-black hover:border-blue-500 hover:shadow-xl hover:relative hover:z-10 hover:border hover:fill-pink">
    <NavLink
      to={`/${chapter.slug}`}
      className="p-6 flex flex-row text-black text-sm">
      <div className="leading-5 font-semibold w-4/12">
        {provinceLongName(chapter.location)}
      </div>
      <div className="leading-5 font-medium w-4/12">{chapter.name}</div>
      <div className="leading-5 w-4/12 flex justify-end">
        <svg
          width="17"
          height="17"
          viewBox="0 0 17 17"
          fill="none"
          xmlns="http://www.w3.org/2000/svg">
          <g clipPath="url(#clip0)">
            <path d="M1.82846 7.4855V9.4852L10.6065 9.4852L10.6065 13.4351L15.5562 8.48535L10.6065 3.5356L10.6065 7.4855L1.82846 7.4855Z" />
          </g>
          <defs>
            <clipPath id="clip0">
              <rect
                y="8.48535"
                width="12"
                height="12"
                transform="rotate(-45 0 8.48535)"
                fill="white"
              />
            </clipPath>
          </defs>
        </svg>
      </div>
    </NavLink>
  </li>
)
