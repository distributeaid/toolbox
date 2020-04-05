import React from 'react'

type SelectProps = {
  label: string
  onChange: (value: React.ChangeEvent<HTMLSelectElement>) => void
  options: JSX.Element[]
  includeBlank?: boolean
}

export const Select: React.FC<SelectProps> = ({
  label,
  options,
  includeBlank,
  onChange,
}) => (
  <label>
    {label}

    <div>
      <select className="border border-gray-300 rounded-md" onChange={onChange}>
        {includeBlank && <option key="blank" value="" />}
        {options}
      </select>
    </div>
  </label>
)
