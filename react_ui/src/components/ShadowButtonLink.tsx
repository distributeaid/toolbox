import React from 'react'
import { NavLink } from 'react-router-dom'

import { classnames } from './classnames'

type ShadowButtonLinkProps = {
  className: string
  to: string
  external?: boolean
}

export const ShadowButtonLink: React.FC<ShadowButtonLinkProps> = ({
  children,
  external,
  className,
  to,
}) => {
  const classes = classnames(
    'inline-block mx-auto px-4 py-4 rounded font-mono font-bold text-xl sm:text-2xl text-center text-white shadow-button',
    className
  )

  return external ? (
    <a className={classes} href={to} target="_blank" rel="noopener noreferrer">
      {children}
    </a>
  ) : (
    <NavLink className={classes} to={to}>
      {children}
    </NavLink>
  )
}
