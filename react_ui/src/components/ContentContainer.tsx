import React from 'react'

import { classnames } from './classnames'

export const ContentContainer: React.FC<{ className?: string }> = ({
  children,
  className,
}) => (
  <div
    className={classnames(
      'container w-full max-w-6xl p-6 px-12 md:mx-auto overflow-hidden',
      className
    )}>
    {children}
  </div>
)
