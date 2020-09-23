import React from 'react'

import { classnames } from './classnames'

export const BorderBlock: React.FC<{ className?: string }> = ({
  children,
  className,
}) => (
  <div
    className={classnames(
      'border-gray-400 border-t border-b w-full',
      className
    )}>
    {children}
  </div>
)
