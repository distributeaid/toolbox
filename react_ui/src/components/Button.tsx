import React from 'react'

export const Button: React.FC<React.ButtonHTMLAttributes<
  HTMLButtonElement
>> = ({ children, ...buttonProps }) => (
  <span className="block w-full rounded-md">
    <button
      {...buttonProps}
      type="submit"
      className="flex justify-center py-2 px-4 text-sm font-medium rounded-md text-white bg-black">
      {children}
    </button>
  </span>
)
