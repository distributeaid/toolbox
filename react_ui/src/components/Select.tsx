import React from 'react'

type SelectProps = {
  id: string
  label: string
  onChange: (value: React.ChangeEvent<HTMLSelectElement>) => void
  options: { name: string; value: string }[]
  value: string
  includeBlank?: boolean
}

export const Select: React.FC<SelectProps> = ({
  id,
  label,
  options,
  includeBlank,
  onChange,
  value,
}) => (
  <div>
    <label
      htmlFor={id}
      className="block text-sm font-medium leading-5 text-gray-700">
      {label}
    </label>
    <div className="relative">
      <select
        id={id}
        className="block appearance-none w-full border border-gray-200 text-gray-700 py-3 px-4 pr-8 rounded leading-tight focus:outline-none focus:bg-white focus:border-gray-500 truncate"
        value={value}
        onChange={onChange}>
        {includeBlank && <option key="blank" value="" />}
        {options.map((option) => (
          <option key={option.value} value={option.value}>
            {option.name}
          </option>
        ))}
      </select>
      <div className="pointer-events-none absolute inset-y-0 right-0 flex items-center px-2 text-gray-700">
        <svg
          className="fill-current h-4 w-4"
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 20 20">
          <path d="M9.293 12.95l.707.707L15.657 8l-1.414-1.414L10 10.828 5.757 6.586 4.343 8z" />
        </svg>
      </div>
    </div>
  </div>
)
