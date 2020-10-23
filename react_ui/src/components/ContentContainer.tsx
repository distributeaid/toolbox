import React from 'react'

import { classnames } from './classnames'

export const ContentContainer: React.FC<{ className?: string }> = ({
  children,
  className,
}) => (
  <div
    className={classnames(
      'sidebar-container w-full overflow-hidden',
      className
    )}>
    {children}
  </div>
)
