import React from 'react'

type Props = {
  title: string
  id: string
  type: 'email' | 'text' | 'password'
  onChange?: (event: React.ChangeEvent<HTMLInputElement>) => void
}

export const Input: React.FC<Props> = ({ id, title, type, onChange }) => (
  <div>
    <label
      htmlFor={id}
      className="block text-sm font-medium leading-5 text-gray-700">
      {title}
    </label>
    <div className="mt-1 rounded-md shadow-sm">
      <input
        id={id}
        type={type}
        required
        onChange={onChange}
        className="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md placeholder-gray-400 focus:outline-none focus:shadow-outline-blue focus:border-blue-300 transition duration-150 ease-in-out sm:text-sm sm:leading-5"
      />
    </div>
  </div>
)
