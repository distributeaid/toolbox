import React from 'react'

type Props = {
  title: string
}

export const Button: React.FC<Props> = ({ title }) => (
  <span className="block w-full rounded-md">
    <button
      type="submit"
      className="flex justify-center py-2 px-4 text-sm font-medium rounded-md text-white bg-black">
      {title}
    </button>
  </span>
)
