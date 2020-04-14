import { Field, FieldProps } from 'formik'
import React from 'react'

import { FormErrorMessage } from './FormErrorMessage'
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
            <FormErrorMessage name={name} />
          </>
        )
      }}
    </Field>
  )
}
