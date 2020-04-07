import React from 'react'

// QUESTION: is there a better way to get these props?
type Props = React.DetailedHTMLProps<
  React.ButtonHTMLAttributes<HTMLButtonElement>,
  HTMLButtonElement
>

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
