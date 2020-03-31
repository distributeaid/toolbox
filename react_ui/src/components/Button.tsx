import React from 'react'

type Props = {
  title: string
}

export const Button: React.FC<Props> = ({ title }) => (
  <span className="block w-full rounded-md shadow-sm">
    <button
      type="submit"
      className="flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-black"
    >
      {title}
    </button>
  </span>
)
