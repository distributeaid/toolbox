import React, { SyntheticEvent } from 'react'

type Props = {
  onClick?: (event: SyntheticEvent) => void
}

export const Button: React.FC<Props> = ({ children, ...buttonProps }) => (
  <span className="block w-full rounded-md">
    <button
      type="submit"
      className="flex justify-center py-2 px-4 text-sm font-medium rounded-md text-white bg-black"
      {...buttonProps}>
      {children}
    </button>
  </span>
)
