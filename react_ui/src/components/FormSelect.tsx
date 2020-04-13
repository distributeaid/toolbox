import { ErrorMessage, Field, FieldProps } from 'formik'
import React from 'react'

import { Select } from './Select'

type Props = {
  name: string
  label: string
  options: { name: string; value: string }[]
  value: string
  includeBlank?: boolean
}

export const FormSelect: React.FC<Props> = ({
  name,
  label,
  options,
  value,
  includeBlank,
}) => {
  return (
    <Field name={name}>
      {({ field, form: { setFieldValue } }: FieldProps) => {
        return (
          <>
            <Select
              {...field}
              id={name}
              onChange={(evt) => setFieldValue(name, evt.target.value)}
              label={label}
              options={options}
              value={value}
              includeBlank={includeBlank}
            />
            <ErrorMessage name={name}>
              {(msg) => (
                <span className="text-red-600 text-sm -mt-2">{msg}</span>
              )}
            </ErrorMessage>
          </>
        )
      }}
    </Field>
  )
}
