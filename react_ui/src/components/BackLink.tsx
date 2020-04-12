import React from 'react'
import { NavLink, NavLinkProps } from 'react-router-dom'

export const BackLink: React.FC<NavLinkProps> = ({ children, ...props }) => (
  <NavLink className="font-body text-sm leading-3" {...props}>
    <svg
      className="inline mr-4 mb-1"
      width="9"
      height="13"
      viewBox="0 0 9 13"
      fill="none"
      xmlns="http://www.w3.org/2000/svg">
      <path
        d="M8.33792 11.4776C8.74305 11.0847 8.74306 10.4347 8.33792 10.0418L5.44758 7.23902C5.04245 6.84616 5.04245 6.19608 5.44758 5.80322L8.33792 3.00045C8.74306 2.60759 8.74306 1.95752 8.33792 1.56465L7.42079 0.675304C7.0329 0.299168 6.41638 0.299167 6.02849 0.675303L0.740359 5.80322C0.335224 6.19608 0.335223 6.84616 0.740358 7.23902L6.02849 12.3669C6.41637 12.7431 7.0329 12.7431 7.42078 12.3669L8.33792 11.4776Z"
        fill="#ED2E69"
      />
    </svg>
    {children}
  </NavLink>
)
