import React from 'react'
import { NavLink, NavLinkProps } from 'react-router-dom'

export const ShadowButtonLink: React.FC<NavLinkProps> = ({
  children,
  className,
  ...props
}) => (
  <NavLink
    className={[
      'inline-block mx-auto px-8 py-4 rounded font-mono font-bold text-2xl text-center text-white shadow-button',
      className,
    ].filter((x) => !!x).join(' ')}
    {...props}>
    {children}
  </NavLink>
)
