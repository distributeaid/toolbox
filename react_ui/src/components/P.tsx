import React from 'react'

import { classnames } from './classnames'

export const P: React.FC<React.HTMLProps<HTMLParagraphElement>> = ({
  children,
  className,
  ...props
}) => (
  <p
    className={classnames('pb-4 font-body text-sm sm:text-lg', className)}
    {...props}>
    {children}
  </p>
)
