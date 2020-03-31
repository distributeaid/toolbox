import React from 'react'

type Props = {
  title: string
  id: string
  onChange?: (event: React.ChangeEvent<HTMLInputElement>) => void
}

export const Checkbox: React.FC<Props> = ({ title, id, onChange }) => (
  <div className="flex items-center">
    <input
      id={id}
      type="checkbox"
      className="form-checkbox h-4 w-4 text-black transition duration-150 ease-in-out"
      onChange={onChange}
    />
    <label
      htmlFor={id}
      className="ml-2 block text-sm leading-5 text-gray-900"
    >
      {title}
    </label>
  </div>
);
