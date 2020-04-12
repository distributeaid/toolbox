import React from 'react'
import { NavLink, NavLinkProps } from 'react-router-dom'
import { classnames } from './classnames'

export const ShadowButtonLink: React.FC<NavLinkProps> = ({
  children,
  className,
  ...props
}) => (
  <NavLink
    className={classnames(
      'inline-block mx-auto w-full px-8 py-4 rounded font-mono font-bold text-xl sm:text-2xl text-center text-white shadow-button',
      className,
    )}
    {...props}>
    {children}
  </NavLink>
)
