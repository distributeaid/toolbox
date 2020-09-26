import { Field, FieldProps } from 'formik'
import React from 'react'

import { FormErrorMessage } from './FormErrorMessage'
import { Input } from './Input'

type Props = {
  name: string
  title: string
  type?: string
}

export const FormInput: React.FC<Props> = ({ name, title, type }) => {
  return (
    <Field name={name}>
      {({ field }: FieldProps) => {
        return (
          <>
            <Input {...field} id={name} title={title} type={type} />
            <FormErrorMessage name={name} />
          </>
        )
      }}
    </Field>
  )
}
