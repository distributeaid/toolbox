import { Input } from './Input'
import React from 'react'
import { Field, FieldProps, ErrorMessage } from 'formik'

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
