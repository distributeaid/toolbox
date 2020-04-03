import React, { SyntheticEvent } from 'react'

// QUESTION: is there a better way to get these props?
interface Props
  extends React.DetailedHTMLProps<
    React.ButtonHTMLAttributes<HTMLButtonElement>,
    HTMLButtonElement
  > {
  moreClassNames?: string
}

export const Button: React.FC<Props> = ({
  children,
  moreClassNames,
  ...buttonProps
}) => (
  <span className="block w-full rounded-md">
    <button
      type="submit"
      className={`flex justify-center py-2 px-4 text-sm font-medium rounded-md text-white bg-black ${moreClassNames}`}
      {...buttonProps}>
      {children}
    </button>
  </span>
)
